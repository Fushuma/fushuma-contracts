// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {Vault} from "../src/infinity-core/Vault.sol";
import {CLPoolManager} from "../src/infinity-core/pool-cl/CLPoolManager.sol";
import {BinPoolManager} from "../src/infinity-core/pool-bin/BinPoolManager.sol";
import {IVault} from "../src/infinity-core/interfaces/IVault.sol";

/**
 * Fushuma DeFi Core Deployment Script
 * 
 * Deploys:
 * 1. Vault - Central liquidity vault
 * 2. CLPoolManager - Concentrated Liquidity pools
 * 3. BinPoolManager - Bin-based pools
 * 
 * Usage:
 * forge script script/FushumaDeployCore.s.sol:FushumaDeployCore \
 *     --rpc-url https://rpc.fushuma.com \
 *     --broadcast \
 *     --legacy
 */
contract FushumaDeployCore is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer address:", deployer);
        console.log("Starting Fushuma DeFi Core deployment...");
        console.log("===========================================");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy Vault
        console.log("\n1. Deploying Vault...");
        Vault vault = new Vault();
        console.log("   Vault deployed at:", address(vault));
        console.log("   Owner:", vault.owner());
        
        // 2. Deploy CLPoolManager
        console.log("\n2. Deploying CLPoolManager...");
        CLPoolManager clPoolManager = new CLPoolManager(IVault(address(vault)));
        console.log("   CLPoolManager deployed at:", address(clPoolManager));
        console.log("   Owner:", clPoolManager.owner());
        
        // 3. Register CLPoolManager with Vault
        console.log("\n3. Registering CLPoolManager with Vault...");
        vault.registerApp(address(clPoolManager));
        console.log("   CLPoolManager registered");
        
        // 4. Deploy BinPoolManager
        console.log("\n4. Deploying BinPoolManager...");
        BinPoolManager binPoolManager = new BinPoolManager(IVault(address(vault)));
        console.log("   BinPoolManager deployed at:", address(binPoolManager));
        console.log("   Owner:", binPoolManager.owner());
        
        // 5. Register BinPoolManager with Vault
        console.log("\n5. Registering BinPoolManager with Vault...");
        vault.registerApp(address(binPoolManager));
        console.log("   BinPoolManager registered");
        
        vm.stopBroadcast();
        
        console.log("\n===========================================");
        console.log("Deployment Complete!");
        console.log("===========================================");
        console.log("\nDeployed Contracts:");
        console.log("  Vault:           ", address(vault));
        console.log("  CLPoolManager:   ", address(clPoolManager));
        console.log("  BinPoolManager:  ", address(binPoolManager));
        console.log("\nSave these addresses for frontend integration!");
    }
}
