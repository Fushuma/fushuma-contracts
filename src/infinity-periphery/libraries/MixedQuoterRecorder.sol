// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
// Modified for Shanghai EVM compatibility - replaced transient storage with regular storage
pragma solidity ^0.8.20;

import {PoolKey} from "infinity-core/types/PoolKey.sol";

/// @dev Record all token accumulation and swap direction of the transaction for non-infinity pools.
/// @dev Record infinity swap history list for infinity pools.
/// @dev Uses regular storage for Shanghai EVM compatibility
library MixedQuoterRecorder {
    /// @dev Storage slot base constants
    uint256 internal constant SWAP_DIRECTION = 0xb0f06de75a159c2e5b201989bb638560c4da40f1013ffa15ae273c1aacd0b1ec;
    uint256 internal constant SWAP_TOKEN0_ACCUMULATION = 0xdd36ccee28e08f88ea49f37da1132de3fa87e3999eb39d32d845d1a9e6df570e;
    uint256 internal constant SWAP_TOKEN1_ACCUMULATION = 0xeb727bd6f9cd36df610586f04563199d7b9247371b12adddd4ce4ef58c98b70f;
    uint256 internal constant SWAP_SS = 0x76c65e24a745cd499bb38f9bf6184bd12a32fe0a1fb9ccbe731eaf961f0f7375;
    uint256 internal constant SWAP_V2 = 0x83bc665dbc6d5e2d26bc1bd704c7074fa59ce4ffcbb0e79e1f3f1b42cd3a319e;
    uint256 internal constant SWAP_V3 = 0x9c2a62db7b9839e1a4c2e3aeab833ff2e00a5e631274627c528f583dd4840055;
    uint256 internal constant SWAP_INFI_CL = 0x04f1a3884a635216eda49df43c2e8a4765868cddc5025abab4e0e173a7eb2d13;
    uint256 internal constant SWAP_INFI_BIN = 0xf4a7c012c4d325571f0df742acb241e78457dc3771381a93b5500b55b9680034;
    uint256 internal constant SWAP_INFI_LIST = 0x408922c3dc9bbcc36d47965143afcd6a6380450e2f63cca1ba4de53e98ca6b21;

    enum SwapDirection {
        NONE,
        ZeroForOne,
        OneForZero
    }

    error INVALID_SWAP_DIRECTION();

    /// @dev Record and check the swap direction of the transaction.
    /// @dev Only support one direction for same non-infinity pool in one transaction.
    /// @param poolHash The hash of the pool.
    /// @param isZeroForOne The direction of the swap.
    function setAndCheckSwapDirection(bytes32 poolHash, bool isZeroForOne) internal {
        uint256 swapDirection = isZeroForOne ? uint256(SwapDirection.ZeroForOne) : uint256(SwapDirection.OneForZero);

        uint256 currentDirection = getSwapDirection(poolHash);
        if (currentDirection == uint256(SwapDirection.NONE)) {
            bytes32 directionSlot = keccak256(abi.encode(poolHash, SWAP_DIRECTION));
            assembly ("memory-safe") {
                sstore(directionSlot, swapDirection)
            }
        } else if (currentDirection != swapDirection) {
            revert INVALID_SWAP_DIRECTION();
        }
    }

    /// @dev Get the swap direction of the transaction.
    /// @param poolHash The hash of the pool.
    /// @return swapDirection The direction of the swap.
    function getSwapDirection(bytes32 poolHash) internal view returns (uint256 swapDirection) {
        bytes32 directionSlot = keccak256(abi.encode(poolHash, SWAP_DIRECTION));
        assembly ("memory-safe") {
            swapDirection := sload(directionSlot)
        }
    }

    /// @dev Record the swap token accumulation of the pool.
    /// @param poolHash The hash of the pool.
    /// @param amountIn The amount of tokenIn.
    /// @param amountOut The amount of tokenOut.
    /// @param isZeroForOne The direction of the swap.
    function setPoolSwapTokenAccumulation(bytes32 poolHash, uint256 amountIn, uint256 amountOut, bool isZeroForOne)
        internal
    {
        bytes32 token0Slot = keccak256(abi.encode(poolHash, SWAP_TOKEN0_ACCUMULATION));
        bytes32 token1Slot = keccak256(abi.encode(poolHash, SWAP_TOKEN1_ACCUMULATION));
        uint256 amount0;
        uint256 amount1;
        if (isZeroForOne) {
            amount0 = amountIn;
            amount1 = amountOut;
        } else {
            amount0 = amountOut;
            amount1 = amountIn;
        }
        assembly ("memory-safe") {
            sstore(token0Slot, amount0)
            sstore(token1Slot, amount1)
        }
    }

    // @dev Get the swap token accumulation of the pool.
    // @param poolHash The hash of the pool.
    // @param isZeroForOne The direction of the swap.
    // @return accAmountIn The accumulation amount of tokenIn.
    // @return accAmountOut The accumulation amount of tokenOut.
    function getPoolSwapTokenAccumulation(bytes32 poolHash, bool isZeroForOne)
        internal
        view
        returns (uint256, uint256)
    {
        bytes32 token0Slot = keccak256(abi.encode(poolHash, SWAP_TOKEN0_ACCUMULATION));
        bytes32 token1Slot = keccak256(abi.encode(poolHash, SWAP_TOKEN1_ACCUMULATION));
        uint256 amount0;
        uint256 amount1;
        assembly ("memory-safe") {
            amount0 := sload(token0Slot)
            amount1 := sload(token1Slot)
        }
        if (isZeroForOne) {
            return (amount0, amount1);
        } else {
            return (amount1, amount0);
        }
    }

    /// @dev Record the swap history list of infinity pool.
    /// @param poolHash The hash of the pool.
    /// @param swapListBytes The swap history list bytes.
    function setInfiPoolSwapList(bytes32 poolHash, bytes memory swapListBytes) internal {
        bytes32 swapListSlot = keccak256(abi.encode(poolHash, SWAP_INFI_LIST));
        assembly ("memory-safe") {
            // save the length of the bytes
            sstore(swapListSlot, mload(swapListBytes))

            // save data in next slot
            let dataSlot := add(swapListSlot, 1)
            for { let i := 0 } lt(i, mload(swapListBytes)) { i := add(i, 32) } {
                sstore(add(dataSlot, div(i, 32)), mload(add(swapListBytes, add(0x20, i))))
            }
        }
    }

    /// @dev Get the swap history list of infinity pool.
    /// @param poolHash The hash of the pool.
    /// @return swapListBytes The swap history list bytes.
    function getInfiPoolSwapList(bytes32 poolHash) internal view returns (bytes memory swapListBytes) {
        bytes32 swapListSlot = keccak256(abi.encode(poolHash, SWAP_INFI_LIST));
        assembly ("memory-safe") {
            // get the length of the bytes
            let length := sload(swapListSlot)
            swapListBytes := mload(0x40)
            mstore(swapListBytes, length)
            let dataSlot := add(swapListSlot, 1)
            for { let i := 0 } lt(i, length) { i := add(i, 32) } {
                mstore(add(swapListBytes, add(0x20, i)), sload(add(dataSlot, div(i, 32))))
            }
            mstore(0x40, add(swapListBytes, add(0x20, length)))
        }
    }

    /// @dev Clear all recorded data for a pool
    /// @param poolHash The hash of the pool.
    function clearPoolData(bytes32 poolHash) internal {
        bytes32 directionSlot = keccak256(abi.encode(poolHash, SWAP_DIRECTION));
        bytes32 token0Slot = keccak256(abi.encode(poolHash, SWAP_TOKEN0_ACCUMULATION));
        bytes32 token1Slot = keccak256(abi.encode(poolHash, SWAP_TOKEN1_ACCUMULATION));
        bytes32 swapListSlot = keccak256(abi.encode(poolHash, SWAP_INFI_LIST));
        
        assembly ("memory-safe") {
            sstore(directionSlot, 0)
            sstore(token0Slot, 0)
            sstore(token1Slot, 0)
            
            // Clear swap list
            let length := sload(swapListSlot)
            sstore(swapListSlot, 0)
            let dataSlot := add(swapListSlot, 1)
            for { let i := 0 } lt(i, length) { i := add(i, 32) } {
                sstore(add(dataSlot, div(i, 32)), 0)
            }
        }
    }

    /// @dev Get the stable swap pool hash.
    /// @param token0 The address of token0.
    /// @param token1 The address of token1.
    /// @return poolHash The hash of the pool.
    function getSSPoolHash(address token0, address token1) internal pure returns (bytes32) {
        if (token0 == token1) revert();
        (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);
        return keccak256(abi.encode(token0, token1, SWAP_SS));
    }

    /// @dev Get the v2 pool hash.
    /// @param token0 The address of token0.
    /// @param token1 The address of token1.
    /// @return poolHash The hash of the pool.
    function getV2PoolHash(address token0, address token1) internal pure returns (bytes32) {
        if (token0 == token1) revert();
        (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);
        return keccak256(abi.encode(token0, token1, SWAP_V2));
    }

    /// @dev Get the v3 pool hash.
    /// @param token0 The address of token0.
    /// @param token1 The address of token1.
    /// @param fee The fee of the pool.
    function getV3PoolHash(address token0, address token1, uint24 fee) internal pure returns (bytes32) {
        if (token0 == token1) revert();
        (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);
        return keccak256(abi.encode(token0, token1, fee, SWAP_V3));
    }

    /// @dev Get the infinity cl pool hash.
    /// @param key The pool key.
    /// @return poolHash The hash of the pool.
    function getInfiCLPoolHash(PoolKey memory key) internal pure returns (bytes32) {
        return keccak256(abi.encode(key, SWAP_INFI_CL));
    }

    /// @dev Get the infinity bin pool hash.
    /// @param key The pool key.
    /// @return poolHash The hash of the pool.
    function getInfiBinPoolHash(PoolKey memory key) internal pure returns (bytes32) {
        return keccak256(abi.encode(key, SWAP_INFI_BIN));
    }
}
