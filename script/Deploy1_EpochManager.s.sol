// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/EpochManager.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract Deploy1_EpochManager is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying EpochManager...");
        EpochManager impl = new EpochManager();
        MinimalProxy proxy = new MinimalProxy(address(impl));
        EpochManager epochManager = EpochManager(address(proxy));
        epochManager.initialize(block.timestamp + 3600); // Start in 1 hour
        
        console.log("EpochManager Proxy:", address(proxy));
        console.log("Current Epoch:", epochManager.currentEpoch());
        
        vm.stopBroadcast();
    }
}
