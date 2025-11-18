// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
// Modified for Shanghai EVM compatibility - replaced transient storage with regular storage
pragma solidity ^0.8.20;

import {Currency} from "../types/Currency.sol";
import {IVault} from "../interfaces/IVault.sol";

/// @notice Settlement guard using regular storage instead of transient storage for Shanghai EVM compatibility
/// @dev This manages:
///  - address locker
///  - uint256 unsettledDeltasCount
///  - mapping(address => mapping(Currency => int256)) currencyDelta
library SettlementGuard {
    /// @dev Storage slots for settlement data - computed from keccak256
    uint256 internal constant LOCKER_SLOT = 0xadd22aa36901fa80b7bf171d667a6586a0fc10ebd31521041e637cc1d6fd7245;
    uint256 internal constant UNSETTLED_DELTAS_COUNT_SLOT = 0x17fd16651e6139cedc95e12f8fd0b66289c81d4da2bbc767bb09fc13ef34e341;
    uint256 internal constant CURRENCY_DELTA_SLOT = 0x7834cf4a8d96514a1e3c852949575be2fc0b2dafa1d97cc5b8de21580f237f3a;

    /// @notice Update the locker address stored in storage
    /// @param newLocker The new locker address
    function setLocker(address newLocker) internal {
        address currentLocker = getLocker();

        // either set from non-zero to zero (set) or from zero to non-zero (reset)
        if (currentLocker != address(0) && newLocker != address(0)) revert IVault.LockerAlreadySet(currentLocker);

        assembly ("memory-safe") {
            sstore(LOCKER_SLOT, newLocker)
        }
    }

    /// @notice Get the locker address stored in storage
    /// @return locker The locker address
    function getLocker() internal view returns (address locker) {
        assembly ("memory-safe") {
            locker := sload(LOCKER_SLOT)
        }
    }

    /// @notice Get the count of non-zero (unsettled) deltas stored in storage
    /// @return count The count of non-zero deltas
    function getUnsettledDeltasCount() internal view returns (uint256 count) {
        assembly ("memory-safe") {
            count := sload(UNSETTLED_DELTAS_COUNT_SLOT)
        }
    }

    /// @notice Create or update the delta record for a settler and currency
    /// if a new record is added then increment the count of non-zero deltas
    /// if an existing record is updated to zero then decrement the count of non-zero deltas
    /// @param settler The address of who is responsible for the settlement
    /// @param currency The currency of the settlement
    /// @param newlyAddedDelta The delta to be added to the existing delta
    function accountDelta(address settler, Currency currency, int256 newlyAddedDelta) internal {
        if (newlyAddedDelta == 0) return;

        /// @dev update the count of non-zero deltas if necessary
        int256 currentDelta = getCurrencyDelta(settler, currency);
        int256 nextDelta = currentDelta + newlyAddedDelta;
        unchecked {
            if (nextDelta == 0) {
                assembly ("memory-safe") {
                    let count := sload(UNSETTLED_DELTAS_COUNT_SLOT)
                    sstore(UNSETTLED_DELTAS_COUNT_SLOT, sub(count, 1))
                }
            } else if (currentDelta == 0) {
                assembly ("memory-safe") {
                    let count := sload(UNSETTLED_DELTAS_COUNT_SLOT)
                    sstore(UNSETTLED_DELTAS_COUNT_SLOT, add(count, 1))
                }
            }
        }

        /// @dev simulating mapping index but with a single hash
        /// save one keccak256 hash compared to built-in nested mapping
        bytes32 elementSlot = keccak256(abi.encode(settler, currency, CURRENCY_DELTA_SLOT));
        assembly ("memory-safe") {
            sstore(elementSlot, nextDelta)
        }
    }

    /// @notice Get the current delta record for a given settler and currency
    /// @param settler The address of who is responsible for the settlement
    /// @param currency The currency of the settlement
    /// @return delta The delta value
    function getCurrencyDelta(address settler, Currency currency) internal view returns (int256 delta) {
        bytes32 elementSlot = keccak256(abi.encode(settler, currency, CURRENCY_DELTA_SLOT));
        assembly ("memory-safe") {
            delta := sload(elementSlot)
        }
    }

    /// @notice Clear settlement data after transaction completes
    /// @dev This must be called to clean up storage and avoid stale data
    /// @param settler The address of the settler
    /// @param currencies Array of currencies to clear
    function clearSettlement(address settler, Currency[] memory currencies) internal {
        // Clear locker
        assembly ("memory-safe") {
            sstore(LOCKER_SLOT, 0)
        }
        
        // Clear unsettled deltas count
        assembly ("memory-safe") {
            sstore(UNSETTLED_DELTAS_COUNT_SLOT, 0)
        }
        
        // Clear currency deltas
        for (uint256 i = 0; i < currencies.length; i++) {
            bytes32 elementSlot = keccak256(abi.encode(settler, currencies[i], CURRENCY_DELTA_SLOT));
            assembly ("memory-safe") {
                sstore(elementSlot, 0)
            }
        }
    }
}
