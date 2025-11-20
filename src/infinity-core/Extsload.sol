// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
// Modified for Shanghai EVM compatibility - added exttload proxy
pragma solidity ^0.8.0;

/// @notice This code is adapted from
// https://github.com/RageTrade/core/blob/main/contracts/utils/Extsload.sol

import {IExtsload} from "./interfaces/IExtsload.sol";

/// @notice Allows the inheriting contract make it's state accessable to other contracts
/// https://ethereum-magicians.org/t/extsload-opcode-proposal/2410/11
abstract contract Extsload is IExtsload {
    /// @inheritdoc IExtsload
    function extsload(bytes32 slot) external view returns (bytes32) {
        assembly ("memory-safe") {
            mstore(0, sload(slot))
            return(0, 0x20)
        }
    }

    /// @inheritdoc IExtsload
    function extsload(bytes32[] calldata slots) external view returns (bytes32[] memory) {
        assembly ("memory-safe") {
            let memptr := mload(0x40)
            let start := memptr
            // for abi encoding the response - the array will be found at 0x20
            mstore(memptr, 0x20)
            // next we store the length of the return array
            mstore(add(memptr, 0x20), slots.length)
            // update memptr to the first location to hold an array entry
            memptr := add(memptr, 0x40)
            // A left bit-shift of 5 is equivalent to multiplying by 32 but costs less gas.
            let end := add(memptr, shl(5, slots.length))
            let calldataptr := slots.offset
            for {} 1 {} {
                mstore(memptr, sload(calldataload(calldataptr)))
                memptr := add(memptr, 0x20)
                calldataptr := add(calldataptr, 0x20)
                if iszero(lt(memptr, end)) { break }
            }
            return(start, sub(end, start))
        }
    }

    /// @notice Proxy function to read from Vault's transient storage mock
    /// @dev This is essential for Quoter and SDK to work on Shanghai EVM
    /// @param slot The storage slot to read from
    /// @return value The value stored at the slot
    function exttload(bytes32 slot) external view virtual returns (bytes32 value) {
        // This will be overridden in PoolManager to proxy to Vault
        // Default implementation returns 0
        return bytes32(0);
    }

    /// @notice Proxy function to read multiple slots from Vault's transient storage mock
    /// @param slots Array of storage slots to read
    /// @return values Array of values stored at the slots
    function exttload(bytes32[] calldata slots) external view virtual returns (bytes32[] memory values) {
        // This will be overridden in PoolManager to proxy to Vault
        // Default implementation returns array of zeros
        values = new bytes32[](slots.length);
        return values;
    }
}
