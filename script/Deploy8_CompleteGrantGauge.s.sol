// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/governance/GaugeController.sol";

contract Deploy8_CompleteGrantGauge is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        
        address gaugeControllerProxy = 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466;
        address epochManagerProxy = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        address grantGaugeProxy = 0x783d34B1fA5ebD752931b24a6BC700f6edE93e0f;
        
        vm.startBroadcast(pk);
        
        GaugeController gc = GaugeController(gaugeControllerProxy);
        bytes32 GAUGE_ADMIN_ROLE = keccak256("GAUGE_ADMIN_ROLE");
        
        console.log("Step 1: Grant GAUGE_ADMIN_ROLE to deployer...");
        gc.grantRole(GAUGE_ADMIN_ROLE, msg.sender);
        console.log("   Role granted!");
        
        console.log("Step 2: Register GrantGauge with GaugeController...");
        uint256 gaugeId = gc.addGauge(
            grantGaugeProxy,
            "Fushuma Grant Gauge",
            "grant"
        );
        console.log("   Gauge ID:", gaugeId);
        
        console.log("Step 3: Initialize GrantGauge...");
        GrantGauge gg = GrantGauge(grantGaugeProxy);
        gg.initialize(
            gaugeControllerProxy,
            epochManagerProxy,
            wfuma,
            gaugeId,
            "Fushuma Grant Gauge"
        );
        console.log("   Initialized successfully!");
        
        console.log("Step 4: Revoke GAUGE_ADMIN_ROLE from deployer (cleanup)...");
        gc.renounceRole(GAUGE_ADMIN_ROLE, msg.sender);
        console.log("   Role revoked!");
        
        console.log("=== GRANT GAUGE SETUP COMPLETE ===");
        console.log("GrantGauge Proxy:", grantGaugeProxy);
        console.log("Gauge ID:", gaugeId);
        
        vm.stopBroadcast();
    }
}
