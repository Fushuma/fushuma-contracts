// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {IVault} from "../src/infinity-core/interfaces/IVault.sol";
import {ICLPoolManager} from "../src/infinity-core/pool-cl/interfaces/ICLPoolManager.sol";
import {IBinPoolManager} from "../src/infinity-core/pool-bin/interfaces/IBinPoolManager.sol";
import {CLPositionDescriptorOffChain} from "../src/infinity-periphery/pool-cl/CLPositionDescriptorOffChain.sol";
import {CLPositionManager} from "../src/infinity-periphery/pool-cl/CLPositionManager.sol";
import {BinPositionManager} from "../src/infinity-periphery/pool-bin/BinPositionManager.sol";
import {CLQuoter} from "../src/infinity-periphery/pool-cl/lens/CLQuoter.sol";
import {BinQuoter} from "../src/infinity-periphery/pool-bin/lens/BinQuoter.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";
import {IWETH9} from "../src/infinity-periphery/interfaces/external/IWETH9.sol";
import {ICLPositionDescriptor} from "../src/infinity-periphery/pool-cl/interfaces/ICLPositionDescriptor.sol";

contract DeployAllPeriphery is Script {
    function run() public {
        // Load environment variables
        address vault = vm.envAddress("VAULT_ADDRESS");
        address clPoolManager = vm.envAddress("CL_POOL_MANAGER_ADDRESS");
        address binPoolManager = vm.envAddress("BIN_POOL_MANAGER_ADDRESS");
        address wfuma = vm.envAddress("WFUMA_ADDRESS");
        address permit2 = vm.envAddress("PERMIT2_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("===========================================");
        console.log("FumaSwap V4 Periphery Deployment");
        console.log("===========================================");
        console.log("Deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);
        console.log("");
        console.log("Core Contracts:");
        console.log("  Vault:", vault);
        console.log("  CLPoolManager:", clPoolManager);
        console.log("  BinPoolManager:", binPoolManager);
        console.log("  WFUMA:", wfuma);
        console.log("  Permit2:", permit2);
        console.log("");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy CL Position Descriptor
        console.log("1. Deploying CLPositionDescriptorOffChain...");
        CLPositionDescriptorOffChain clDescriptor = new CLPositionDescriptorOffChain(
            "https://nft.fushuma.com/cl-position/"
        );
        console.log("   CLPositionDescriptorOffChain:", address(clDescriptor));
        
        // 2. Deploy CL Position Manager
        console.log("");
        console.log("2. Deploying CLPositionManager...");
        CLPositionManager clPositionManager = new CLPositionManager(
            IVault(vault),
            ICLPoolManager(clPoolManager),
            IAllowanceTransfer(permit2),
            300_000, // unsubscribeGasLimit
            ICLPositionDescriptor(address(clDescriptor)),
            IWETH9(wfuma)
        );
        console.log("   CLPositionManager:", address(clPositionManager));
        
        // 3. Deploy Bin Position Manager
        console.log("");
        console.log("3. Deploying BinPositionManager...");
        BinPositionManager binPositionManager = new BinPositionManager(
            IVault(vault),
            IBinPoolManager(binPoolManager),
            IAllowanceTransfer(permit2),
            IWETH9(wfuma)
        );
        console.log("   BinPositionManager:", address(binPositionManager));
        
        // 4. Deploy CL Quoter
        console.log("");
        console.log("4. Deploying CLQuoter...");
        CLQuoter clQuoter = new CLQuoter(clPoolManager);
        console.log("   CLQuoter:", address(clQuoter));
        
        // 5. Deploy Bin Quoter
        console.log("");
        console.log("5. Deploying BinQuoter...");
        BinQuoter binQuoter = new BinQuoter(binPoolManager);
        console.log("   BinQuoter:", address(binQuoter));
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("===========================================");
        console.log("DEPLOYMENT COMPLETE!");
        console.log("===========================================");
        console.log("");
        console.log("Deployed Contracts:");
        console.log("  CLPositionDescriptorOffChain:", address(clDescriptor));
        console.log("  CLPositionManager:", address(clPositionManager));
        console.log("  BinPositionManager:", address(binPositionManager));
        console.log("  CLQuoter:", address(clQuoter));
        console.log("  BinQuoter:", address(binQuoter));
        console.log("");
        console.log("IMPORTANT: Save these addresses for frontend integration!");
    }
}
