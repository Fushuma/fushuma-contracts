// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (C) 2024 PancakeSwap
pragma solidity ^0.8.20;

import {Permit2Payments} from "../../Permit2Payments.sol";
import {InfinityRouter} from "infinity-periphery/InfinityRouter.sol";
import {IVault} from "infinity-core/interfaces/IVault.sol";
import {ICLPoolManager} from "infinity-core/pool-cl/interfaces/ICLPoolManager.sol";
import {IBinPoolManager} from "infinity-core/pool-bin/interfaces/IBinPoolManager.sol";
import {Currency} from "infinity-core/types/Currency.sol";

/// @title Router for PCS Infinity Trades
abstract contract InfinitySwapRouter is InfinityRouter, Permit2Payments {
    constructor(address _vault, address _clPoolManager, address _binPoolManager)
        InfinityRouter(IVault(_vault), ICLPoolManager(_clPoolManager), IBinPoolManager(_binPoolManager))
    {}

    function _pay(Currency token, address payer, uint256 amount) internal override {
        payOrPermit2Transfer(Currency.unwrap(token), payer, address(vault), amount);
    }
}
