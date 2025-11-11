// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/governance/GaugeController.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract Deploy9_FinalGrantGauge is Script {
    function run() external {
        address wfuma = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
        address gaugeControllerProxy = 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466;
        address epochManagerProxy = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        
        vm.startBroadcast();
        
        console.log("Step 1: Deploying new GrantGauge implementation...");
        GrantGauge impl = new GrantGauge();
        console.log("   Implementation:", address(impl));
        
        console.log("Step 2: Deploying new MinimalProxy...");
        MinimalProxy proxy = new MinimalProxy(address(impl));
        console.log("   Proxy:", address(proxy));
        
        console.log("Step 3: Registering gauge with GaugeController...");
        GaugeController gc = GaugeController(gaugeControllerProxy);
        uint256 gaugeId = gc.addGauge(
            address(proxy),
            "Fushuma Grant Gauge",
            "grant"
        );
        console.log("   Gauge ID:", gaugeId);
        
        console.log("Step 4: Initializing GrantGauge with correct gaugeId...");
        GrantGauge gg = GrantGauge(address(proxy));
        gg.initialize(
            gaugeControllerProxy,
            epochManagerProxy,
            wfuma,
            gaugeId,  // Use the ID we just got from registration
            "Fushuma Grant Gauge"
        );
        console.log("   Initialized!");
        
        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("GrantGauge Proxy:", address(proxy));
        console.log("Gauge ID:", gaugeId);
        
        vm.stopBroadcast();
    }
}
