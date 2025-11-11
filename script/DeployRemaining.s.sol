// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GovernanceCouncil.sol";
import "../contracts/governance/FushumaGovernor.sol";
import "../contracts/governance/EpochManager.sol";
import "../contracts/governance/GaugeController.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract DeployRemaining is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address council1 = vm.envAddress("COUNCIL_MEMBER_1");
        address council2 = vm.envAddress("COUNCIL_MEMBER_2");
        address council3 = vm.envAddress("COUNCIL_MEMBER_3");
        address veProxy = 0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f; // Already deployed
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("=== DEPLOYING REMAINING GOVERNANCE CONTRACTS ===");
        console.log("");
        
        // 1. Deploy EpochManager
        console.log("1. Deploying EpochManager...");
        EpochManager epochImpl = new EpochManager();
        MinimalProxy epochProxy = new MinimalProxy(address(epochImpl));
        EpochManager epochManager = EpochManager(address(epochProxy));
        epochManager.initialize(block.timestamp);
        console.log("   Proxy:", address(epochProxy));
        console.log("");
        
        // 2. Deploy GovernanceCouncil
        console.log("2. Deploying GovernanceCouncil...");
        GovernanceCouncil councilImpl = new GovernanceCouncil();
        MinimalProxy councilProxy = new MinimalProxy(address(councilImpl));
        GovernanceCouncil council = GovernanceCouncil(address(councilProxy));
        council.initialize(admin, 2, 172800, 86400, 43200);
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council1);
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council2);
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council3);
        console.log("   Proxy:", address(councilProxy));
        console.log("");
        
        // 3. Deploy FushumaGovernor
        console.log("3. Deploying FushumaGovernor...");
        FushumaGovernor govImpl = new FushumaGovernor();
        MinimalProxy govProxy = new MinimalProxy(address(govImpl));
        FushumaGovernor governor = FushumaGovernor(payable(address(govProxy)));
        governor.initialize(admin, veProxy, address(councilProxy), 1000 ether, 1000, 50400, 7200, 172800);
        console.log("   Proxy:", address(govProxy));
        console.log("");
        
        // 4. Deploy GaugeController
        console.log("4. Deploying GaugeController...");
        GaugeController gcImpl = new GaugeController();
        MinimalProxy gcProxy = new MinimalProxy(address(gcImpl));
        GaugeController gaugeController = GaugeController(address(gcProxy));
        gaugeController.initialize(veProxy, address(epochProxy));
        console.log("   Proxy:", address(gcProxy));
        console.log("");
        
        // 5. Deploy GrantGauge
        console.log("5. Deploying GrantGauge...");
        GrantGauge ggImpl = new GrantGauge();
        MinimalProxy ggProxy = new MinimalProxy(address(ggImpl));
        GrantGauge grantGauge = GrantGauge(address(ggProxy));
        grantGauge.initialize(address(gcProxy), address(epochProxy), wfuma, 0, "Fushuma Grant Gauge");
        console.log("   Proxy:", address(ggProxy));
        console.log("");
        
        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("VotingEscrow:", veProxy);
        console.log("EpochManager:", address(epochProxy));
        console.log("GovernanceCouncil:", address(councilProxy));
        console.log("FushumaGovernor:", address(govProxy));
        console.log("GaugeController:", address(gcProxy));
        console.log("GrantGauge:", address(ggProxy));
        
        vm.stopBroadcast();
    }
}
