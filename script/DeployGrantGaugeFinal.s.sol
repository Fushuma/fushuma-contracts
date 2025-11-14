// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract DeployGrantGaugeFinal is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        address gaugeController = 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466;
        address epochManager = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        address wfuma = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
        
        console.log("=== Deploying GrantGauge (MCOPY-free) ===");
        console.log("Deployer:", deployer);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy implementation
        console.log("\n1. Deploying GrantGauge implementation...");
        GrantGauge implementation = new GrantGauge();
        console.log("Implementation deployed at:", address(implementation));
        
        // 2. Deploy proxy
        console.log("\n2. Deploying MinimalProxy...");
        MinimalProxy proxy = new MinimalProxy(address(implementation));
        console.log("Proxy deployed at:", address(proxy));
        
        // 3. Initialize
        console.log("\n3. Initializing GrantGauge...");
        GrantGauge grantGauge = GrantGauge(address(proxy));
        grantGauge.initialize(
            gaugeController,
            epochManager,
            wfuma,
            0, // gaugeId will be set when registered
            "Fushuma Grant Gauge"
        );
        console.log("GrantGauge initialized!");
        
        // 4. Register with GaugeController
        console.log("\n4. Registering with GaugeController...");
        (bool success, bytes memory data) = gaugeController.call(
            abi.encodeWithSignature(
                "addGauge(address,string,string)",
                address(grantGauge),
                "Fushuma Grant Gauge",
                "grant"
            )
        );
        require(success, "Failed to register gauge");
        uint256 gaugeId = abi.decode(data, (uint256));
        console.log("GrantGauge registered with ID:", gaugeId);
        
        vm.stopBroadcast();
        
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("GrantGauge Implementation:", address(implementation));
        console.log("GrantGauge Proxy:", address(proxy));
        
        // Verify
        console.log("\n=== VERIFICATION ===");
        console.log("Name:", grantGauge.name());
        console.log("Token:", address(grantGauge.token()));
        console.log("Gauge ID:", grantGauge.gaugeId());
    }
}


