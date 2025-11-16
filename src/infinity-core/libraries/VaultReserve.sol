// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
// Modified for Paris EVM compatibility (Fushuma Network)
pragma solidity ^0.8.24;

import {Currency} from "../types/Currency.sol";

/// @notice Paris EVM compatible version - uses regular storage instead of transient storage
/// @dev It records a single reserve for a currency each time, this is helpful for
/// calculating how many tokens has been transferred to the vault right after the sync
library VaultReserve {
    // Storage slots (same as original for compatibility)
    uint256 internal constant RESERVE_TYPE_SLOT = 0x52a1be34b47478d7c75e2b6c3eea1e05dcb8dbb8c6a42c6482d0dca0df53cb27;
    uint256 internal constant RESERVE_AMOUNT_SLOT = 0xb0879d96d58bcff08d1fd45590200072d5a8c380da0b5aa1052b48b84e115207;

    /// @notice Store the currency reserve in storage
    /// @param currency The currency to be saved
    /// @param amount The amount of the currency to be saved
    function setVaultReserve(Currency currency, uint256 amount) internal {
        assembly ("memory-safe") {
            // record <currency, amount> in storage
            sstore(RESERVE_TYPE_SLOT, and(currency, 0xffffffffffffffffffffffffffffffffffffffff))
            sstore(RESERVE_AMOUNT_SLOT, amount)
        }
    }

    /// @notice Load the currency reserve from storage
    /// @return currency The currency that was most recently saved
    /// @return amount The amount of the currency that was most recently saved
    function getVaultReserve() internal view returns (Currency currency, uint256 amount) {
        assembly ("memory-safe") {
            currency := sload(RESERVE_TYPE_SLOT)
            amount := sload(RESERVE_AMOUNT_SLOT)
        }
    }
}
