// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Script.sol";
import {Vault} from "../src/infinity-core/Vault.sol";
import {CLPoolManager} from "../src/infinity-core/pool-cl/CLPoolManager.sol";
import {BinPoolManager} from "../src/infinity-core/pool-bin/BinPoolManager.sol";
import {CLPositionDescriptorOffChain} from "../src/infinity-periphery/pool-cl/CLPositionDescriptorOffChain.sol";
import {CLPositionManager} from "../src/infinity-periphery/pool-cl/CLPositionManager.sol";
import {CLQuoter} from "../src/infinity-periphery/pool-cl/lens/CLQuoter.sol";
import {IVault} from "../src/infinity-core/interfaces/IVault.sol";
import {ICLPoolManager} from "../src/infinity-core/pool-cl/interfaces/ICLPoolManager.sol";
import {IBinPoolManager} from "../src/infinity-core/pool-bin/interfaces/IBinPoolManager.sol";
import {IPermit2} from "../lib/permit2/src/interfaces/IPermit2.sol";

contract DeployV4Paris is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address wfuma = vm.envAddress("WFUMA_ADDRESS");
        address permit2 = vm.envAddress("PERMIT2_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("=== Deploying Paris-Compatible PancakeSwap V4 ===");
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("WFUMA:", wfuma);
        console.log("Permit2:", permit2);
        console.log("");
        
        // 1. Deploy Vault
        console.log("1. Deploying Vault...");
        Vault vault = new Vault();
        console.log("   Vault deployed at:", address(vault));
        console.log("");
        
        // 2. Deploy CLPoolManager
        console.log("2. Deploying CLPoolManager...");
        CLPoolManager clPoolManager = new CLPoolManager(IVault(address(vault)));
        console.log("   CLPoolManager deployed at:", address(clPoolManager));
        console.log("");
        
        // 3. Deploy BinPoolManager
        console.log("3. Deploying BinPoolManager...");
        BinPoolManager binPoolManager = new BinPoolManager(IVault(address(vault)));
        console.log("   BinPoolManager deployed at:", address(binPoolManager));
        console.log("");
        
        // 4. Register pool managers with Vault
        console.log("4. Registering pool managers with Vault...");
        vault.registerApp(address(clPoolManager));
        vault.registerApp(address(binPoolManager));
        console.log("   Pool managers registered");
        console.log("");
        
        // 5. Deploy CLPositionDescriptorOffChain
        console.log("5. Deploying CLPositionDescriptorOffChain...");
        string memory baseTokenURI = "https://nft.fushuma.com/v4/positions/";
        CLPositionDescriptorOffChain descriptor = new CLPositionDescriptorOffChain(baseTokenURI);
        console.log("   CLPositionDescriptorOffChain deployed at:", address(descriptor));
        console.log("");
        
        // 6. Deploy CLPositionManager
        console.log("6. Deploying CLPositionManager...");
        CLPositionManager clPositionManager = new CLPositionManager(
            IVault(address(vault)),
            ICLPoolManager(address(clPoolManager)),
            IPermit2(permit2),
            wfuma,
            address(descriptor)
        );
        console.log("   CLPositionManager deployed at:", address(clPositionManager));
        console.log("");
        
        // 7. Deploy CLQuoter
        console.log("7. Deploying CLQuoter...");
        CLQuoter clQuoter = new CLQuoter(address(clPoolManager));
        console.log("   CLQuoter deployed at:", address(clQuoter));
        console.log("");
        
        vm.stopBroadcast();
        
        // Print summary
        console.log("=== Deployment Complete ===");
        console.log("");
        console.log("Contract Addresses:");
        console.log("-------------------");
        console.log("Vault:", address(vault));
        console.log("CLPoolManager:", address(clPoolManager));
        console.log("BinPoolManager:", address(binPoolManager));
        console.log("CLPositionDescriptorOffChain:", address(descriptor));
        console.log("CLPositionManager:", address(clPositionManager));
        console.log("CLQuoter:", address(clQuoter));
        console.log("");
        console.log("Save these addresses to your .env file and update the governance hub configuration.");
    }
}
