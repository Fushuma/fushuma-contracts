// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVault} from "infinity-core/interfaces/IVault.sol";

/// @title IPoolManager
/// @notice Interface for the PoolManager contract
interface IPoolManager {
    /// @notice Returns the vault contract
    /// @return IVault The address of the vault
    function vault() external view returns (IVault);
}
