// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract Deploy6_GrantGauge is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        
        vm.startBroadcast(pk);
        
        console.log("Deploying GrantGauge...");
        GrantGauge impl = new GrantGauge();
        MinimalProxy proxy = new MinimalProxy(address(impl));
        GrantGauge gg = GrantGauge(address(proxy));
        
        gg.initialize(
            0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466, // GaugeController
            0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453, // EpochManager
            wfuma,
            0,
            "Fushuma Grant Gauge"
        );
        
        console.log("GrantGauge Proxy:", address(proxy));
        
        vm.stopBroadcast();
    }
}
