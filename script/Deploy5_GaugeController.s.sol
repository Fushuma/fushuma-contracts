// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GaugeController.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract Deploy5_GaugeController is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        
        vm.startBroadcast(pk);
        
        console.log("Deploying GaugeController...");
        GaugeController impl = new GaugeController();
        MinimalProxy proxy = new MinimalProxy(address(impl));
        GaugeController gc = GaugeController(address(proxy));
        
        gc.initialize(
            0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f, // VotingEscrow
            0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453  // EpochManager
        );
        
        console.log("GaugeController Proxy:", address(proxy));
        
        vm.stopBroadcast();
    }
}
