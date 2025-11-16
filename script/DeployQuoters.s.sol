// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {ICLPoolManager} from "infinity-core/pool-cl/interfaces/ICLPoolManager.sol";
import {IBinPoolManager} from "infinity-core/pool-bin/interfaces/IBinPoolManager.sol";
import {CLQuoter} from "infinity-periphery/pool-cl/lens/CLQuoter.sol";
import {BinQuoter} from "infinity-periphery/pool-bin/lens/BinQuoter.sol";
import {MixedQuoter} from "infinity-periphery/MixedQuoter.sol";

contract DeployQuoters is Script {
    // Deployed core contracts on Fushuma Network
    address constant CL_POOL_MANAGER = 0x103C72dB83e413B787596b2524a07dd6856C6bBf;
    address constant BIN_POOL_MANAGER = 0xCd9BE698a24f70Cc9903E3C59fd48B56dd565425;
    
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy CL Quoter
        console.log("\n=== Deploying CLQuoter ===");
        CLQuoter clQuoter = new CLQuoter(ICLPoolManager(CL_POOL_MANAGER));
        console.log("CLQuoter deployed at:", address(clQuoter));
        
        // 2. Deploy Bin Quoter
        console.log("\n=== Deploying BinQuoter ===");
        BinQuoter binQuoter = new BinQuoter(IBinPoolManager(BIN_POOL_MANAGER));
        console.log("BinQuoter deployed at:", address(binQuoter));
        
        // 3. Deploy Mixed Quoter
        console.log("\n=== Deploying MixedQuoter ===");
        MixedQuoter mixedQuoter = new MixedQuoter(
            ICLPoolManager(CL_POOL_MANAGER),
            IBinPoolManager(BIN_POOL_MANAGER)
        );
        console.log("MixedQuoter deployed at:", address(mixedQuoter));
        
        vm.stopBroadcast();
        
        console.log("\n=== QUOTERS DEPLOYMENT COMPLETE ===");
        console.log("CLQuoter:", address(clQuoter));
        console.log("BinQuoter:", address(binQuoter));
        console.log("MixedQuoter:", address(mixedQuoter));
    }
}
