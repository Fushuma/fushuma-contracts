// SPDX-License-Identifier: GPL-3.0-or-later
// Modified for Shanghai EVM compatibility - replaced transient storage with regular storage
pragma solidity ^0.8.20;

/// @notice A library to implement a reentrancy lock using regular storage for Shanghai EVM compatibility.
/// @dev Instead of storing a boolean, the locker's address is stored to allow the contract to know who locked the contract
library Locker {
    /// @dev Storage slot for the locker state - computed from keccak256
    uint256 internal constant LOCKER_SLOT = 0x2335d121f8bf4a425d7fe6732bc3d2440f693cc59aad98bf2d86991fbead5843;

    function set(address locker) internal {
        // The locker is always msg.sender or address(0) so does not need to be cleaned
        assembly ("memory-safe") {
            sstore(LOCKER_SLOT, locker)
        }
    }

    function get() internal view returns (address locker) {
        assembly ("memory-safe") {
            locker := sload(LOCKER_SLOT)
        }
    }

    function isLocked() internal view returns (bool) {
        return Locker.get() != address(0);
    }
}
