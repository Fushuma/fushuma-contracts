// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IVault} from "../src/infinity-core/interfaces/IVault.sol";
import {ICLPoolManager} from "../src/infinity-core/pool-cl/interfaces/ICLPoolManager.sol";
import {IBinPoolManager} from "../src/infinity-core/pool-bin/interfaces/IBinPoolManager.sol";
import {IAllowanceTransfer} from "../lib/permit2/src/interfaces/IAllowanceTransfer.sol";
import {CLPositionManager} from "../src/infinity-periphery/pool-cl/CLPositionManager.sol";
import {BinPositionManager} from "../src/infinity-periphery/pool-bin/BinPositionManager.sol";
import {CLPositionDescriptorOffChain} from "../src/infinity-periphery/pool-cl/CLPositionDescriptorOffChain.sol";
import {ICLPositionDescriptor} from "../src/infinity-periphery/pool-cl/interfaces/ICLPositionDescriptor.sol";
import {IWETH9} from "../src/infinity-periphery/interfaces/external/IWETH9.sol";

contract DeployPositionManagers is Script {
    // Deployed contract addresses
    address constant VAULT = 0xd1AF417B5C2a1DEd602dE9068bf90Af0A8b93E27;
    address constant CL_POOL_MANAGER = 0x103C72dB83e413B787596b2524a07dd6856C6bBf;
    address constant BIN_POOL_MANAGER = 0xCd9BE698a24f70Cc9903E3C59fd48B56dd565425;
    address constant PERMIT2 = 0x7c343F6aB66975f349026eE98aFF45c3D8108423;
    address constant WFUMA = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
    
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying Position Managers to Fushuma Network");
        console.log("Deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);
        console.log("\nUsing deployed contracts:");
        console.log("Vault:", VAULT);
        console.log("CLPoolManager:", CL_POOL_MANAGER);
        console.log("BinPoolManager:", BIN_POOL_MANAGER);
        console.log("Permit2:", PERMIT2);
        console.log("WFUMA:", WFUMA);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy CLPositionDescriptor with base URI
        console.log("\nDeploying CLPositionDescriptorOffChain...");
        string memory baseURI = "https://nft.fushuma.com/v1/";
        CLPositionDescriptorOffChain clDescriptor = new CLPositionDescriptorOffChain(baseURI);
        console.log("CLPositionDescriptor deployed at:", address(clDescriptor));
        
        // Deploy CLPositionManager
        console.log("\nDeploying CLPositionManager...");
        CLPositionManager clPositionManager = new CLPositionManager(
            IVault(VAULT),
            ICLPoolManager(CL_POOL_MANAGER),
            IAllowanceTransfer(PERMIT2),
            300000, // unsubscribeGasLimit
            ICLPositionDescriptor(address(clDescriptor)),
            IWETH9(WFUMA)
        );
        console.log("CLPositionManager deployed at:", address(clPositionManager));
        
        // Deploy BinPositionManager
        console.log("\nDeploying BinPositionManager...");
        BinPositionManager binPositionManager = new BinPositionManager(
            IVault(VAULT),
            IBinPoolManager(BIN_POOL_MANAGER),
            IAllowanceTransfer(PERMIT2),
            IWETH9(WFUMA)
        );
        console.log("BinPositionManager deployed at:", address(binPositionManager));
        
        vm.stopBroadcast();
        
        console.log("\n=== POSITION MANAGERS DEPLOYMENT COMPLETE ===");
        console.log("CLPositionDescriptor:", address(clDescriptor));
        console.log("CLPositionManager:", address(clPositionManager));
        console.log("BinPositionManager:", address(binPositionManager));
        console.log("\nUpdate these addresses in the governance hub!");
    }
}
