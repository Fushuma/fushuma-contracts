// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/governance/GaugeController.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract Deploy7_GrantGaugeFinal is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        
        address gaugeControllerProxy = 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466;
        address epochManagerProxy = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        
        vm.startBroadcast(pk);
        
        console.log("Step 1: Deploying GrantGauge implementation and proxy...");
        GrantGauge impl = new GrantGauge();
        MinimalProxy proxy = new MinimalProxy(address(impl));
        console.log("   Implementation:", address(impl));
        console.log("   Proxy:", address(proxy));
        
        console.log("Step 2: Registering gauge with GaugeController...");
        GaugeController gc = GaugeController(gaugeControllerProxy);
        uint256 gaugeId = gc.addGauge(
            address(proxy),
            "Fushuma Grant Gauge",
            "grant"
        );
        console.log("   Gauge ID:", gaugeId);
        
        console.log("Step 3: Initializing GrantGauge...");
        GrantGauge gg = GrantGauge(address(proxy));
        gg.initialize(
            gaugeControllerProxy,
            epochManagerProxy,
            wfuma,
            gaugeId,  // Use the actual gauge ID from registration
            "Fushuma Grant Gauge"
        );
        console.log("   Initialized successfully!");
        
        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("GrantGauge Proxy:", address(proxy));
        console.log("Gauge ID:", gaugeId);
        
        vm.stopBroadcast();
    }
}
