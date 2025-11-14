// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract DebugGrantGauge is Script {
    function run() external view {
        address wfuma = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
        address gaugeControllerProxy = 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466;
        address epochManagerProxy = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        address grantGaugeProxy = 0x48Ec52aC4A8154141D95fF3d7bE7057A37908724;
        
        console.log("=== Testing GrantGauge Initialization ===");
        
        // Test if we can create the initialization calldata
        bytes memory initData = abi.encodeWithSignature(
            "initialize(address,address,address,uint256,string)",
            gaugeControllerProxy,
            epochManagerProxy,
            wfuma,
            uint256(0),
            "Fushuma Grant Gauge"
        );
        
        console.log("Init data length:", initData.length);
        console.logBytes(initData);
        
        // Try to simulate the call
        console.log("\nAttempting to call initialize on proxy...");
        (bool success, bytes memory returnData) = grantGaugeProxy.staticcall(initData);
        
        if (success) {
            console.log("SUCCESS!");
        } else {
            console.log("FAILED!");
            console.log("Return data length:", returnData.length);
            if (returnData.length > 0) {
                console.logBytes(returnData);
            }
        }
    }
}
