// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/governance/GaugeController.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract DeployGrantGaugeFresh is Script {
    function run() external {
        address wfuma = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
        address gaugeControllerProxy = 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466;
        address epochManagerProxy = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        
        vm.startBroadcast();
        
        console.log("=== DEPLOYING FRESH GRANTGAUGE ===");
        console.log("Deployer:", msg.sender);
        console.log("Balance:", msg.sender.balance);
        
        // Step 1: Deploy implementation
        console.log("\n[1/4] Deploying GrantGauge implementation...");
        GrantGauge impl = new GrantGauge();
        console.log("   Implementation deployed:", address(impl));
        
        // Step 2: Deploy proxy
        console.log("\n[2/4] Deploying MinimalProxy...");
        MinimalProxy proxy = new MinimalProxy(address(impl));
        console.log("   Proxy deployed:", address(proxy));
        
        // Step 3: Register with GaugeController
        console.log("\n[3/4] Registering gauge with GaugeController...");
        GaugeController gc = GaugeController(gaugeControllerProxy);
        
        try gc.addGauge(address(proxy), "Fushuma Grant Gauge", "grant") returns (uint256 gaugeId) {
            console.log("   SUCCESS! Gauge ID:", gaugeId);
            
            // Step 4: Initialize GrantGauge
            console.log("\n[4/4] Initializing GrantGauge...");
            GrantGauge gg = GrantGauge(address(proxy));
            
            try gg.initialize(
                gaugeControllerProxy,
                epochManagerProxy,
                wfuma,
                gaugeId,
                "Fushuma Grant Gauge"
            ) {
                console.log("   SUCCESS! GrantGauge initialized!");
                console.log("\n=== DEPLOYMENT COMPLETE ===");
                console.log("GrantGauge Proxy:", address(proxy));
                console.log("Gauge ID:", gaugeId);
            } catch Error(string memory reason) {
                console.log("   FAILED! Reason:", reason);
            } catch (bytes memory lowLevelData) {
                console.log("   FAILED! Low-level error");
                console.logBytes(lowLevelData);
            }
            
        } catch Error(string memory reason) {
            console.log("   FAILED! Reason:", reason);
        } catch (bytes memory lowLevelData) {
            console.log("   FAILED! Low-level error");
            console.logBytes(lowLevelData);
        }
        
        vm.stopBroadcast();
    }
}
