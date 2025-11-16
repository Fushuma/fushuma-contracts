// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
// Modified for Paris EVM compatibility (Fushuma Network)
pragma solidity ^0.8.24;

/// @notice A reentrancy lock using regular storage instead of transient storage for Paris EVM compatibility
contract ReentrancyLock {
    // The slot holding the locker state in regular storage
    address private _locker;

    error ContractLocked();

    modifier isNotLocked() {
        if (_locker != address(0)) revert ContractLocked();
        _locker = msg.sender;
        _;
        _locker = address(0);
    }

    function _setLocker(address locker) internal {
        _locker = locker;
    }

    function _getLocker() internal view returns (address) {
        return _locker;
    }
}
