// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
// Modified for Shanghai EVM compatibility - Storage-as-Transient pattern
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IVault, IVaultToken} from "./interfaces/IVault.sol";
import {Currency, CurrencyLibrary} from "./types/Currency.sol";
import {BalanceDelta} from "./types/BalanceDelta.sol";
import {ILockCallback} from "./interfaces/ILockCallback.sol";
import {SafeCast} from "./libraries/SafeCast.sol";
import {VaultReserve} from "./libraries/VaultReserve.sol";
import {VaultToken} from "./VaultToken.sol";

contract Vault is IVault, VaultToken, Ownable2Step {
    using SafeCast for *;
    using CurrencyLibrary for Currency;

    constructor() Ownable(msg.sender) {}

    mapping(address app => bool isRegistered) public override isAppRegistered;

    /// @dev keep track of each app's reserves
    mapping(address app => mapping(Currency currency => uint256 reserve)) public reservesOfApp;

    /// @dev Storage-as-Transient: Mock transient storage for Shanghai EVM compatibility
    /// This mapping simulates transient storage behavior using persistent storage
    mapping(bytes32 => bytes32) public transientStorageMock;

    /// @dev Track which slots have been written to for cleanup
    mapping(bytes32 => bool) private isSlotWritten;
    bytes32[] private writtenSlots;

    /// @dev Storage slots for settlement data - using namespaced storage pattern (EIP-7201)
    bytes32 private constant LOCKER_SLOT = keccak256("fushuma.vault.locker");
    bytes32 private constant UNSETTLED_DELTAS_COUNT_SLOT = keccak256("fushuma.vault.unsettled_deltas_count");
    bytes32 private constant CURRENCY_DELTA_SLOT = keccak256("fushuma.vault.currency_delta");

    /// @notice only registered app is allowed to perform accounting
    modifier onlyRegisteredApp() {
        if (!isAppRegistered[msg.sender]) revert AppUnregistered();
        _;
    }

    /// @notice revert if no locker is set
    modifier isLocked() {
        if (_getLocker() == address(0)) revert NoLocker();
        _;
    }

    /// @inheritdoc IVault
    function registerApp(address app) external override onlyOwner {
        isAppRegistered[app] = true;
        emit AppRegistered(app);
    }

    /// @inheritdoc IVault
    function getLocker() external view override returns (address) {
        return _getLocker();
    }

    /// @inheritdoc IVault
    function getUnsettledDeltasCount() external view override returns (uint256) {
        return _getUnsettledDeltasCount();
    }

    /// @inheritdoc IVault
    function currencyDelta(address settler, Currency currency) external view override returns (int256) {
        return _getCurrencyDelta(settler, currency);
    }

    /// @dev interaction must start from lock
    /// @inheritdoc IVault
    function lock(bytes calldata data) external override returns (bytes memory result) {
        // 1. Check if already locked (Reentrancy Guard)
        address currentLocker = _getLocker();
        if (currentLocker != address(0)) revert LockerAlreadySet(currentLocker);

        // 2. Set Locker (Simulated TSTORE)
        _setLocker(msg.sender);

        // 3. Execute the Callback (The "Flash" part)
        result = ILockCallback(msg.sender).lockAcquired(data);

        // 4. Solvency Check (Must be zero)
        uint256 deltaCount = _getUnsettledDeltasCount();
        if (deltaCount != 0) revert CurrencyNotSettled();

        // 5. CRITICAL: Release Lock and Cleanup Storage
        _cleanupTransientStorage();
    }

    /// @inheritdoc IVault
    function accountAppBalanceDelta(
        Currency currency0,
        Currency currency1,
        BalanceDelta delta,
        address settler,
        BalanceDelta hookDelta,
        address hook
    ) external override isLocked onlyRegisteredApp {
        (int128 delta0, int128 delta1) = (delta.amount0(), delta.amount1());
        (int128 hookDelta0, int128 hookDelta1) = (hookDelta.amount0(), hookDelta.amount1());

        /// @dev call _accountDeltaForApp once with both delta/hookDelta to save gas and prevent
        /// reservesOfApp from underflow when it deduct before addition
        _accountDeltaForApp(currency0, delta0 + hookDelta0);
        _accountDeltaForApp(currency1, delta1 + hookDelta1);

        // keep track of the balance on vault level
        _accountDelta(settler, currency0, delta0);
        _accountDelta(settler, currency1, delta1);
        _accountDelta(hook, currency0, hookDelta0);
        _accountDelta(hook, currency1, hookDelta1);
    }

    /// @inheritdoc IVault
    function accountAppBalanceDelta(Currency currency0, Currency currency1, BalanceDelta delta, address settler)
        external
        override
        isLocked
        onlyRegisteredApp
    {
        int128 delta0 = delta.amount0();
        int128 delta1 = delta.amount1();

        // keep track of the balance on app level
        _accountDeltaForApp(currency0, delta0);
        _accountDeltaForApp(currency1, delta1);

        // keep track of the balance on vault level
        _accountDelta(settler, currency0, delta0);
        _accountDelta(settler, currency1, delta1);
    }

    /// @inheritdoc IVault
    function accountAppBalanceDelta(Currency currency, int128 delta, address settler)
        external
        override
        isLocked
        onlyRegisteredApp
    {
        _accountDeltaForApp(currency, delta);
        _accountDelta(settler, currency, delta);
    }

    /// @inheritdoc IVault
    function take(Currency currency, address to, uint256 amount) external override isLocked {
        unchecked {
            _accountDelta(msg.sender, currency, -(amount.toInt128()));
            currency.transfer(to, amount);
        }
    }

    /// @inheritdoc IVault
    function mint(address to, Currency currency, uint256 amount) external override isLocked {
        unchecked {
            _accountDelta(msg.sender, currency, -(amount.toInt128()));
            _mint(to, currency, amount);
        }
    }

    function sync(Currency currency) public override {
        if (currency.isNative()) {
            VaultReserve.setVaultReserve(CurrencyLibrary.NATIVE, 0);
        } else {
            uint256 balance = currency.balanceOfSelf();
            VaultReserve.setVaultReserve(currency, balance);
        }
    }

    /// @inheritdoc IVault
    function settle() external payable override isLocked returns (uint256) {
        return _settle(msg.sender);
    }

    /// @inheritdoc IVault
    function settleFor(address recipient) external payable override isLocked returns (uint256) {
        return _settle(recipient);
    }

    /// @inheritdoc IVault
    function clear(Currency currency, uint256 amount) external isLocked {
        int256 existingDelta = _getCurrencyDelta(msg.sender, currency);
        int128 amountDelta = amount.toInt128();
        /// @dev since amount is uint256, existingDelta must be positive otherwise revert
        if (amountDelta != existingDelta) revert MustClearExactPositiveDelta();
        unchecked {
            _accountDelta(msg.sender, currency, -amountDelta);
        }
    }

    /// @inheritdoc IVault
    function burn(address from, Currency currency, uint256 amount) external override isLocked {
        _accountDelta(msg.sender, currency, amount.toInt128());
        _burnFrom(from, currency, amount);
    }

    /// @inheritdoc IVault
    function collectFee(Currency currency, uint256 amount, address recipient) external onlyRegisteredApp {
        // prevent transfer between the sync and settle balanceOfs (native settle uses msg.value)
        (Currency syncedCurrency,) = VaultReserve.getVaultReserve();
        if (!currency.isNative() && syncedCurrency == currency) revert FeeCurrencySynced();
        reservesOfApp[msg.sender][currency] -= amount;
        currency.transfer(recipient, amount);
    }

    /// @inheritdoc IVault
    function getVaultReserve() external view returns (Currency, uint256) {
        return VaultReserve.getVaultReserve();
    }

    // ============================================
    // INTERNAL FUNCTIONS - Storage-as-Transient
    // ============================================

    /// @notice Internal helper to store a value in the mock transient storage
    /// @param slot The storage slot
    /// @param value The value to store
    function _tstore(bytes32 slot, bytes32 value) internal {
        if (!isSlotWritten[slot]) {
            isSlotWritten[slot] = true;
            writtenSlots.push(slot);
        }
        transientStorageMock[slot] = value;
    }

    /// @notice Internal helper to load a value from the mock transient storage
    /// @param slot The storage slot
    /// @return value The stored value
    function _tload(bytes32 slot) internal view returns (bytes32) {
        return transientStorageMock[slot];
    }

    /// @notice Set the locker address
    /// @param newLocker The new locker address
    function _setLocker(address newLocker) internal {
        _tstore(LOCKER_SLOT, bytes32(uint256(uint160(newLocker))));
    }

    /// @notice Get the locker address
    /// @return locker The locker address
    function _getLocker() internal view returns (address locker) {
        return address(uint160(uint256(_tload(LOCKER_SLOT))));
    }

    /// @notice Get the count of non-zero (unsettled) deltas
    /// @return count The count of non-zero deltas
    function _getUnsettledDeltasCount() internal view returns (uint256 count) {
        return uint256(_tload(UNSETTLED_DELTAS_COUNT_SLOT));
    }

    /// @notice Create or update the delta record for a settler and currency
    /// @param settler The address of who is responsible for the settlement
    /// @param currency The currency of the settlement
    /// @param newlyAddedDelta The delta to be added to the existing delta
    function _accountDelta(address settler, Currency currency, int256 newlyAddedDelta) internal {
        if (newlyAddedDelta == 0) return;

        int256 currentDelta = _getCurrencyDelta(settler, currency);
        int256 nextDelta = currentDelta + newlyAddedDelta;

        unchecked {
            if (nextDelta == 0) {
                // Delta settled to zero, decrement count
                uint256 count = _getUnsettledDeltasCount();
                _tstore(UNSETTLED_DELTAS_COUNT_SLOT, bytes32(count - 1));
            } else if (currentDelta == 0) {
                // New non-zero delta, increment count
                uint256 count = _getUnsettledDeltasCount();
                _tstore(UNSETTLED_DELTAS_COUNT_SLOT, bytes32(count + 1));
            }
        }

        // Store the new delta value
        bytes32 elementSlot = keccak256(abi.encode(settler, currency, CURRENCY_DELTA_SLOT));
        _tstore(elementSlot, bytes32(uint256(nextDelta)));
    }

    /// @notice Get the current delta record for a given settler and currency
    /// @param settler The address of who is responsible for the settlement
    /// @param currency The currency of the settlement
    /// @return delta The delta value
    function _getCurrencyDelta(address settler, Currency currency) internal view returns (int256 delta) {
        bytes32 elementSlot = keccak256(abi.encode(settler, currency, CURRENCY_DELTA_SLOT));
        return int256(uint256(_tload(elementSlot)));
    }

    /// @notice Clean up all mock transient storage after transaction completes
    /// @dev This is CRITICAL for security and gas efficiency
    function _cleanupTransientStorage() internal {
        // Clear all written slots
        for (uint256 i = 0; i < writtenSlots.length; i++) {
            bytes32 slot = writtenSlots[i];
            delete transientStorageMock[slot];
            delete isSlotWritten[slot];
        }
        delete writtenSlots;
    }

    function _accountDeltaForApp(Currency currency, int128 delta) internal {
        if (delta == 0) return;

        /// @dev optimization: msg.sender will always be app address, verification should be done on caller address
        if (delta >= 0) {
            /// @dev arithmetic underflow make sure trader can't withdraw too much from app
            reservesOfApp[msg.sender][currency] -= uint128(delta);
        } else {
            /// @dev arithmetic overflow make sure trader won't deposit too much into app
            reservesOfApp[msg.sender][currency] += uint128(-delta);
        }
    }

    // if settling native, integrators should still call `sync` first to avoid DoS attack vectors
    function _settle(address recipient) internal returns (uint256 paid) {
        (Currency currency, uint256 reservesBefore) = VaultReserve.getVaultReserve();
        if (!currency.isNative()) {
            if (msg.value > 0) revert SettleNonNativeCurrencyWithValue();
            uint256 reservesNow = currency.balanceOfSelf();
            paid = reservesNow - reservesBefore;

            /// @dev reset the reserve after settled
            VaultReserve.setVaultReserve(CurrencyLibrary.NATIVE, 0);
        } else {
            // NATIVE token does not require sync call before settle
            paid = msg.value;
        }

        _accountDelta(recipient, currency, paid.toInt128());
    }
}
