// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/VotingEscrow.sol";
import "../contracts/governance/GovernanceCouncil.sol";
import "../contracts/governance/FushumaGovernor.sol";
import "../contracts/governance/EpochManager.sol";
import "../contracts/governance/GaugeController.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract DeployAllGovernance is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address council1 = vm.envAddress("COUNCIL_MEMBER_1");
        address council2 = vm.envAddress("COUNCIL_MEMBER_2");
        address council3 = vm.envAddress("COUNCIL_MEMBER_3");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("=== FUSHUMA GOVERNANCE DEPLOYMENT ===");
        console.log("Network: Fushuma zkEVM+ Mainnet");
        console.log("WFUMA Token:", wfuma);
        console.log("Admin:", admin);
        console.log("");
        
        // 1. Deploy VotingEscrow
        console.log("1. Deploying VotingEscrow...");
        VotingEscrow veImpl = new VotingEscrow();
        MinimalProxy veProxy = new MinimalProxy(address(veImpl));
        VotingEscrow ve = VotingEscrow(address(veProxy));
        ve.initialize(wfuma, admin, 100 ether, 604800, 1209600, 31536000, 4);
        console.log("   Implementation:", address(veImpl));
        console.log("   Proxy:", address(veProxy));
        console.log("");
        
        // 2. Deploy EpochManager
        console.log("2. Deploying EpochManager...");
        EpochManager epochImpl = new EpochManager();
        MinimalProxy epochProxy = new MinimalProxy(address(epochImpl));
        EpochManager epochManager = EpochManager(address(epochProxy));
        epochManager.initialize(block.timestamp); // Start now
        console.log("   Implementation:", address(epochImpl));
        console.log("   Proxy:", address(epochProxy));
        console.log("");
        
        // 3. Deploy GovernanceCouncil
        console.log("3. Deploying GovernanceCouncil...");
        GovernanceCouncil councilImpl = new GovernanceCouncil();
        MinimalProxy councilProxy = new MinimalProxy(address(councilImpl));
        GovernanceCouncil council = GovernanceCouncil(address(councilProxy));
        council.initialize(
            admin,
            2,           // requiredApprovals (2 of 3)
            172800,      // vetoPeriod (2 days)
            86400,       // vetoVotingPeriod (1 day)
            43200        // speedupVotingPeriod (12 hours)
        );
        // Grant council roles to members
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council1);
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council2);
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council3);
        console.log("   Implementation:", address(councilImpl));
        console.log("   Proxy:", address(councilProxy));
        console.log("");
        
        // 4. Deploy FushumaGovernor
        console.log("4. Deploying FushumaGovernor...");
        FushumaGovernor govImpl = new FushumaGovernor();
        MinimalProxy govProxy = new MinimalProxy(address(govImpl));
        FushumaGovernor governor = FushumaGovernor(payable(address(govProxy)));
        governor.initialize(
            admin,
            address(ve),
            address(council),
            1000 ether,  // proposalThreshold
            1000,        // quorumBps (10%)
            50400,       // votingPeriod (7 days in blocks)
            7200,        // votingDelay (1 day in blocks)
            172800       // timelockDelay (2 days in seconds)
        );
        console.log("   Implementation:", address(govImpl));
        console.log("   Proxy:", address(govProxy));
        console.log("");
        
        // 5. Deploy GaugeController
        console.log("5. Deploying GaugeController...");
        GaugeController gcImpl = new GaugeController();
        MinimalProxy gcProxy = new MinimalProxy(address(gcImpl));
        GaugeController gaugeController = GaugeController(address(gcProxy));
        gaugeController.initialize(address(ve), address(epochManager));
        console.log("   Implementation:", address(gcImpl));
        console.log("   Proxy:", address(gcProxy));
        console.log("");
        
        // 6. Deploy GrantGauge
        console.log("6. Deploying GrantGauge...");
        GrantGauge ggImpl = new GrantGauge();
        MinimalProxy ggProxy = new MinimalProxy(address(ggImpl));
        GrantGauge grantGauge = GrantGauge(address(ggProxy));
        grantGauge.initialize(
            address(gaugeController),
            address(epochManager),
            wfuma,
            0,              // gaugeId (will be set by controller)
            "Fushuma Grant Gauge"
        );
        console.log("   Implementation:", address(ggImpl));
        console.log("   Proxy:", address(ggProxy));
        console.log("");
        
        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("");
        console.log("Contract Addresses:");
        console.log("-------------------");
        console.log("VotingEscrow:", address(veProxy));
        console.log("EpochManager:", address(epochProxy));
        console.log("GovernanceCouncil:", address(councilProxy));
        console.log("FushumaGovernor:", address(govProxy));
        console.log("GaugeController:", address(gcProxy));
        console.log("GrantGauge:", address(ggProxy));
        
        vm.stopBroadcast();
    }
}
