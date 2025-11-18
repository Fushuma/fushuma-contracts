// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
// Modified for Shanghai EVM compatibility - replaced transient storage with regular storage
pragma solidity ^0.8.20;

import {Currency} from "../types/Currency.sol";

/// @notice Vault reserve management using regular storage for Shanghai EVM compatibility
/// @dev Records a single reserve for a currency each time, helpful for
/// calculating how many tokens have been transferred to the vault right after the sync
library VaultReserve {
    /// @dev Storage slots for vault reserve data - computed from keccak256
    uint256 internal constant RESERVE_TYPE_SLOT = 0x9c731a97d73e2a3d3bf141114bfa56b636b46529a917b5c0f19704d5a25b7842;
    uint256 internal constant RESERVE_AMOUNT_SLOT = 0xec8e1b1a98222ae1e6546f3dc6f616c0e4aa9436a7944ca28b8d729b7e5c8c2f;

    /// @notice Store the currency reserve
    /// @param currency The currency to be saved
    /// @param amount The amount of the currency to be saved
    function setVaultReserve(Currency currency, uint256 amount) internal {
        assembly ("memory-safe") {
            // record <currency, amount> in storage
            sstore(RESERVE_TYPE_SLOT, and(currency, 0xffffffffffffffffffffffffffffffffffffffff))
            sstore(RESERVE_AMOUNT_SLOT, amount)
        }
    }

    /// @notice Load the currency reserve
    /// @return currency The currency that was most recently saved
    /// @return amount The amount of the currency that was most recently saved
    function getVaultReserve() internal view returns (Currency currency, uint256 amount) {
        assembly ("memory-safe") {
            currency := sload(RESERVE_TYPE_SLOT)
            amount := sload(RESERVE_AMOUNT_SLOT)
        }
    }

    /// @notice Clear the vault reserve
    /// @dev This must be called to clean up storage after operations complete
    function clearVaultReserve() internal {
        assembly ("memory-safe") {
            sstore(RESERVE_TYPE_SLOT, 0)
            sstore(RESERVE_AMOUNT_SLOT, 0)
        }
    }
}
