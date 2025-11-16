// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {IVault} from "infinity-core/interfaces/IVault.sol";
import {ICLPoolManager} from "infinity-core/pool-cl/interfaces/ICLPoolManager.sol";
import {IBinPoolManager} from "infinity-core/pool-bin/interfaces/IBinPoolManager.sol";
import {CLPositionDescriptorOffChain} from "infinity-periphery/pool-cl/CLPositionDescriptorOffChain.sol";
import {CLPositionManager} from "infinity-periphery/pool-cl/CLPositionManager.sol";
import {BinPositionManager} from "infinity-periphery/pool-bin/BinPositionManager.sol";
import {CLQuoter} from "infinity-periphery/pool-cl/lens/CLQuoter.sol";
import {BinQuoter} from "infinity-periphery/pool-bin/lens/BinQuoter.sol";
import {MixedQuoter} from "infinity-periphery/MixedQuoter.sol";

contract DeployPeriphery is Script {
    // Deployed core contracts on Fushuma Network
    address constant VAULT = 0xd1AF417B5C2a1DEd602dE9068bf90Af0A8b93E27;
    address constant CL_POOL_MANAGER = 0x103C72dB83e413B787596b2524a07dd6856C6bBf;
    address constant BIN_POOL_MANAGER = 0xCd9BE698a24f70Cc9903E3C59fd48B56dd565425;
    address constant WFUMA = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
    
    // Permit2 canonical address (to be deployed separately)
    address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy CL Position Descriptor
        console.log("\n=== Deploying CLPositionDescriptorOffChain ===");
        CLPositionDescriptorOffChain clDescriptor = new CLPositionDescriptorOffChain(
            WFUMA,
            bytes32("FUMA")
        );
        console.log("CLPositionDescriptorOffChain:", address(clDescriptor));
        
        // 2. Deploy CL Position Manager
        console.log("\n=== Deploying CLPositionManager ===");
        CLPositionManager clPositionManager = new CLPositionManager(
            IVault(VAULT),
            ICLPoolManager(CL_POOL_MANAGER),
            PERMIT2,
            300_000, // unsubscribeGasLimit
            address(clDescriptor)
        );
        console.log("CLPositionManager:", address(clPositionManager));
        
        // 3. Deploy Bin Position Manager
        console.log("\n=== Deploying BinPositionManager ===");
        BinPositionManager binPositionManager = new BinPositionManager(
            IVault(VAULT),
            IBinPoolManager(BIN_POOL_MANAGER),
            PERMIT2
        );
        console.log("BinPositionManager:", address(binPositionManager));
        
        // 4. Deploy CL Quoter
        console.log("\n=== Deploying CLQuoter ===");
        CLQuoter clQuoter = new CLQuoter(ICLPoolManager(CL_POOL_MANAGER));
        console.log("CLQuoter:", address(clQuoter));
        
        // 5. Deploy Bin Quoter
        console.log("\n=== Deploying BinQuoter ===");
        BinQuoter binQuoter = new BinQuoter(IBinPoolManager(BIN_POOL_MANAGER));
        console.log("BinQuoter:", address(binQuoter));
        
        // 6. Deploy Mixed Quoter
        console.log("\n=== Deploying MixedQuoter ===");
        MixedQuoter mixedQuoter = new MixedQuoter(
            ICLPoolManager(CL_POOL_MANAGER),
            IBinPoolManager(BIN_POOL_MANAGER)
        );
        console.log("MixedQuoter:", address(mixedQuoter));
        
        vm.stopBroadcast();
        
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("CLPositionDescriptorOffChain:", address(clDescriptor));
        console.log("CLPositionManager:", address(clPositionManager));
        console.log("BinPositionManager:", address(binPositionManager));
        console.log("CLQuoter:", address(clQuoter));
        console.log("BinQuoter:", address(binQuoter));
        console.log("MixedQuoter:", address(mixedQuoter));
        console.log("\nNOTE: Permit2 must be deployed at:", PERMIT2);
    }
}
