// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
// Modified for Shanghai EVM compatibility - replaced transient storage with regular storage
pragma solidity ^0.8.20;

/// @notice A reentrancy lock using regular storage for Shanghai EVM compatibility
/// @dev Stores the caller's address as the lock
contract ReentrancyLock {
    /// @dev Storage slot for the locker state - computed from keccak256
    uint256 private constant LOCKED_BY_SLOT = 0xae6c4170a39a4e4c8c7ddf414bd8c6056a32cc8228e8b6e142a7e2952556988e;

    error ContractLocked();

    modifier isNotLocked() {
        if (_getLocker() != address(0)) revert ContractLocked();
        _setLocker(msg.sender);
        _;
        _setLocker(address(0));
    }

    function _setLocker(address locker) internal {
        assembly ("memory-safe") {
            sstore(LOCKED_BY_SLOT, locker)
        }
    }

    function _getLocker() internal view returns (address locker) {
        assembly ("memory-safe") {
            locker := sload(LOCKED_BY_SLOT)
        }
    }
}
