// SPDX-License-Identifier: GPL-3.0-or-later
// Modified for Shanghai EVM compatibility - replaced transient storage with regular storage
pragma solidity ^0.8.20;

/// @notice A library used to store the maximum desired amount of input tokens for exact output swaps; used for checking slippage
/// @dev Uses regular storage for Shanghai EVM compatibility
library MaxInputAmount {
    /// @dev Storage slot for the maximum desired amount of input tokens - computed from keccak256
    uint256 internal constant MAX_AMOUNT_IN_SLOT = 0xa6f2513687944fbc32ee86ee8a2d12916f5989db65fb2ffdd136b94cd6f4514e;

    function set(uint256 maxAmountIn) internal {
        assembly ("memory-safe") {
            sstore(MAX_AMOUNT_IN_SLOT, maxAmountIn)
        }
    }

    function get() internal view returns (uint256 maxAmountIn) {
        assembly ("memory-safe") {
            maxAmountIn := sload(MAX_AMOUNT_IN_SLOT)
        }
    }

    /// @notice Clear the max input amount
    /// @dev Should be called after transaction completes to clean up storage
    function clear() internal {
        assembly ("memory-safe") {
            sstore(MAX_AMOUNT_IN_SLOT, 0)
        }
    }
}
