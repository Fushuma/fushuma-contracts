// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/FushumaGovernor.sol";
import "../contracts/governance/GaugeController.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract DeployFinal3 is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        
        address veProxy = 0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f;
        address epochProxy = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        address councilProxy = 0x92bCcdcae7B73A5332429e517D26515D447e9997;
        
        vm.startBroadcast(pk);
        
        // 1. FushumaGovernor
        console.log("1. Deploying FushumaGovernor...");
        FushumaGovernor gImpl = new FushumaGovernor();
        MinimalProxy gProxy = new MinimalProxy(address(gImpl));
        FushumaGovernor gov = FushumaGovernor(payable(address(gProxy)));
        gov.initialize(msg.sender, veProxy, councilProxy, 1000 ether, 1000, 50400, 7200, 172800);
        gov.grantRole(gov.DEFAULT_ADMIN_ROLE(), admin);
        gov.renounceRole(gov.DEFAULT_ADMIN_ROLE(), msg.sender);
        console.log("   Proxy:", address(gProxy));
        
        // 2. GaugeController
        console.log("2. Deploying GaugeController...");
        GaugeController gcImpl = new GaugeController();
        MinimalProxy gcProxy = new MinimalProxy(address(gcImpl));
        GaugeController gc = GaugeController(address(gcProxy));
        gc.initialize(veProxy, epochProxy);
        console.log("   Proxy:", address(gcProxy));
        
        // 3. GrantGauge
        console.log("3. Deploying GrantGauge...");
        GrantGauge ggImpl = new GrantGauge();
        MinimalProxy ggProxy = new MinimalProxy(address(ggImpl));
        GrantGauge gg = GrantGauge(address(ggProxy));
        gg.initialize(address(gcProxy), epochProxy, wfuma, 0, "Fushuma Grant Gauge");
        console.log("   Proxy:", address(ggProxy));
        
        console.log("=== ALL DEPLOYED ===");
        console.log("FushumaGovernor:", address(gProxy));
        console.log("GaugeController:", address(gcProxy));
        console.log("GrantGauge:", address(ggProxy));
        
        vm.stopBroadcast();
    }
}
