// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../contracts/governance/VotingEscrow.sol";
import "../contracts/governance/GovernanceCouncil.sol";
import "../contracts/governance/FushumaGovernor.sol";
import "../contracts/governance/EpochManager.sol";
import "../contracts/governance/GaugeController.sol";
import "../contracts/governance/GrantGauge.sol";
import "../contracts/tokens/WFUMA.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title DeployGovernance
 * @notice Deployment script for Fushuma governance contracts
 * @dev Deploys all governance contracts in the correct order with UUPS proxies
 */
contract DeployGovernance is Script {
    // Deployment addresses (will be set after deployment)
    address public constant EXISTING_WFUMA = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
    address public wfuma;
    address public votingEscrowImpl;
    address public votingEscrowProxy;
    address public governanceCouncilImpl;
    address public governanceCouncilProxy;
    address public fushumaGovernorImpl;
    address public fushumaGovernorProxy;
    address public epochManagerImpl;
    address public epochManagerProxy;
    address public gaugeControllerImpl;
    address public gaugeControllerProxy;
    address public grantGaugeImpl;
    address public grantGaugeProxy;

    // Configuration parameters
    struct DeploymentConfig {
        address admin;
        address fumaToken;
        address[] councilMembers;
        uint256 minDeposit;
        uint256 warmupPeriod;
        uint256 cooldownPeriod;
        uint256 maxLockDuration;
        uint256 maxMultiplier;
        uint256 proposalThreshold;
        uint256 quorumBps;
        uint256 votingPeriod;
        uint256 votingDelay;
        uint256 timelockDelay;
        uint256 requiredApprovals;
        uint256 vetoPeriod;
        uint256 vetoVotingPeriod;
        uint256 speedupVotingPeriod;
        uint256 epochStartTime;
    }

    function run() external {
        // Load configuration from environment or use defaults
        DeploymentConfig memory config = loadConfig();

        // Start broadcasting transactions
        vm.startBroadcast();

        console.log("=== Fushuma Governance Deployment ===");
        console.log("Admin:", config.admin);
        console.log("FUMA Token:", config.fumaToken);
        console.log("");

        // Step 1: Use existing WFUMA
        if (config.fumaToken == address(0)) {
            console.log("1. Using existing WFUMA...");
            wfuma = EXISTING_WFUMA;
            console.log("   WFUMA address:", wfuma);
            config.fumaToken = wfuma;
        } else {
            console.log("1. Using specified FUMA token:", config.fumaToken);
            wfuma = config.fumaToken;
        }

        // Step 2: Deploy VotingEscrow
        console.log("2. Deploying VotingEscrow...");
        votingEscrowImpl = address(new VotingEscrow());
        bytes memory votingEscrowInitData = abi.encodeWithSelector(
            VotingEscrow.initialize.selector,
            config.fumaToken,
            config.admin,
            config.minDeposit,
            config.warmupPeriod,
            config.cooldownPeriod,
            config.maxLockDuration,
            config.maxMultiplier
        );
        votingEscrowProxy = address(new ERC1967Proxy(votingEscrowImpl, votingEscrowInitData));
        console.log("   Implementation:", votingEscrowImpl);
        console.log("   Proxy:", votingEscrowProxy);

        // Step 3: Deploy GovernanceCouncil
        console.log("3. Deploying GovernanceCouncil...");
        governanceCouncilImpl = address(new GovernanceCouncil());
        bytes memory councilInitData = abi.encodeWithSelector(
            GovernanceCouncil.initialize.selector,
            config.admin,
            config.requiredApprovals,
            config.vetoPeriod,
            config.vetoVotingPeriod,
            config.speedupVotingPeriod
        );
        governanceCouncilProxy = address(new ERC1967Proxy(governanceCouncilImpl, councilInitData));
        console.log("   Implementation:", governanceCouncilImpl);
        console.log("   Proxy:", governanceCouncilProxy);

        // Step 4: Deploy FushumaGovernor
        console.log("4. Deploying FushumaGovernor...");
        fushumaGovernorImpl = address(new FushumaGovernor());
        bytes memory governorInitData = abi.encodeWithSelector(
            FushumaGovernor.initialize.selector,
            config.admin,
            votingEscrowProxy,
            governanceCouncilProxy,
            config.proposalThreshold,
            config.quorumBps,
            config.votingPeriod,
            config.votingDelay,
            config.timelockDelay
        );
        fushumaGovernorProxy = address(new ERC1967Proxy(fushumaGovernorImpl, governorInitData));
        console.log("   Implementation:", fushumaGovernorImpl);
        console.log("   Proxy:", fushumaGovernorProxy);

        // Step 5: Deploy EpochManager
        console.log("5. Deploying EpochManager...");
        epochManagerImpl = address(new EpochManager());
        bytes memory epochInitData = abi.encodeWithSelector(
            EpochManager.initialize.selector,
            config.epochStartTime
        );
        epochManagerProxy = address(new ERC1967Proxy(epochManagerImpl, epochInitData));
        console.log("   Implementation:", epochManagerImpl);
        console.log("   Proxy:", epochManagerProxy);

        // Step 6: Deploy GaugeController
        console.log("6. Deploying GaugeController...");
        gaugeControllerImpl = address(new GaugeController());
        bytes memory gaugeControllerInitData = abi.encodeWithSelector(
            GaugeController.initialize.selector,
            votingEscrowProxy,
            epochManagerProxy
        );
        gaugeControllerProxy = address(new ERC1967Proxy(gaugeControllerImpl, gaugeControllerInitData));
        console.log("   Implementation:", gaugeControllerImpl);
        console.log("   Proxy:", gaugeControllerProxy);

        // Step 7: Deploy GrantGauge
        console.log("7. Deploying GrantGauge...");
        grantGaugeImpl = address(new GrantGauge());
        bytes memory grantGaugeInitData = abi.encodeWithSelector(
            GrantGauge.initialize.selector,
            gaugeControllerProxy,
            epochManagerProxy,
            config.fumaToken,
            1, // gaugeId will be set by GaugeController
            "Development Grants"
        );
        grantGaugeProxy = address(new ERC1967Proxy(grantGaugeImpl, grantGaugeInitData));
        console.log("   Implementation:", grantGaugeImpl);
        console.log("   Proxy:", grantGaugeProxy);

        // Step 8: Add council members
        console.log("8. Adding council members...");
        GovernanceCouncil council = GovernanceCouncil(governanceCouncilProxy);
        for (uint256 i = 0; i < config.councilMembers.length; i++) {
            council.grantRole(council.COUNCIL_MEMBER_ROLE(), config.councilMembers[i]);
            console.log("   Added member:", config.councilMembers[i]);
        }

        // Step 9: Add GrantGauge to GaugeController
        console.log("9. Registering GrantGauge...");
        GaugeController gaugeController = GaugeController(gaugeControllerProxy);
        gaugeController.addGauge(grantGaugeProxy, "Development Grants", "grant");
        console.log("   GrantGauge registered");

        vm.stopBroadcast();

        // Print deployment summary
        console.log("");
        console.log("=== Deployment Summary ===");
        console.log("WFUMA:", wfuma);
        console.log("VotingEscrow:", votingEscrowProxy);
        console.log("GovernanceCouncil:", governanceCouncilProxy);
        console.log("FushumaGovernor:", fushumaGovernorProxy);
        console.log("EpochManager:", epochManagerProxy);
        console.log("GaugeController:", gaugeControllerProxy);
        console.log("GrantGauge:", grantGaugeProxy);
        console.log("");
        console.log("=== Next Steps ===");
        console.log("1. Verify contracts on block explorer");
        console.log("2. Update frontend with contract addresses");
        console.log("3. Test all functionality on testnet");
        console.log("4. Transfer admin role to governance (after testing)");

        // Deployment addresses printed above
        // saveDeploymentAddresses(); // Disabled to allow broadcast
    }

    function loadConfig() internal view returns (DeploymentConfig memory) {
        DeploymentConfig memory config;

        // Load from environment variables
        config.admin = vm.envOr("ADMIN_ADDRESS", msg.sender);
        // Default to existing WFUMA if not specified
        config.fumaToken = vm.envOr("FUMA_TOKEN_ADDRESS", EXISTING_WFUMA);

        // Load council members (comma-separated)
        string memory councilMembersStr = vm.envOr("COUNCIL_MEMBERS", string(""));
        if (bytes(councilMembersStr).length > 0) {
            // Parse comma-separated addresses
            // For simplicity, using default addresses if not provided
            config.councilMembers = new address[](5);
            // These should be replaced with actual council member addresses
            config.councilMembers[0] = vm.envOr("COUNCIL_MEMBER_1", address(0));
            config.councilMembers[1] = vm.envOr("COUNCIL_MEMBER_2", address(0));
            config.councilMembers[2] = vm.envOr("COUNCIL_MEMBER_3", address(0));
            config.councilMembers[3] = vm.envOr("COUNCIL_MEMBER_4", address(0));
            config.councilMembers[4] = vm.envOr("COUNCIL_MEMBER_5", address(0));
        } else {
            config.councilMembers = new address[](0);
        }

        // VotingEscrow parameters
        config.minDeposit = vm.envOr("MIN_DEPOSIT", uint256(100 ether)); // 100 FUMA
        config.warmupPeriod = vm.envOr("WARMUP_PERIOD", uint256(7 days));
        config.cooldownPeriod = vm.envOr("COOLDOWN_PERIOD", uint256(14 days));
        config.maxLockDuration = vm.envOr("MAX_LOCK_DURATION", uint256(365 days));
        config.maxMultiplier = vm.envOr("MAX_MULTIPLIER", uint256(4));

        // Governor parameters
        config.proposalThreshold = vm.envOr("PROPOSAL_THRESHOLD", uint256(1000 ether));
        config.quorumBps = vm.envOr("QUORUM_BPS", uint256(1000)); // 10%
        config.votingPeriod = vm.envOr("VOTING_PERIOD", uint256(7 days));
        config.votingDelay = vm.envOr("VOTING_DELAY", uint256(1 days));
        config.timelockDelay = vm.envOr("TIMELOCK_DELAY", uint256(2 days));

        // Council parameters
        config.requiredApprovals = vm.envOr("REQUIRED_APPROVALS", uint256(3));
        config.vetoPeriod = vm.envOr("VETO_PERIOD", uint256(3 days));
        config.vetoVotingPeriod = vm.envOr("VETO_VOTING_PERIOD", uint256(3 days));
        config.speedupVotingPeriod = vm.envOr("SPEEDUP_VOTING_PERIOD", uint256(2 days));

        // Epoch parameters
        config.epochStartTime = vm.envOr("EPOCH_START_TIME", block.timestamp + 1 days);

        return config;
    }

    function saveDeploymentAddresses() internal {
        string memory json = string(abi.encodePacked(
            '{\n',
            '  "wfuma": "', vm.toString(wfuma), '",\n',
            '  "votingEscrow": "', vm.toString(votingEscrowProxy), '",\n',
            '  "governanceCouncil": "', vm.toString(governanceCouncilProxy), '",\n',
            '  "fushumaGovernor": "', vm.toString(fushumaGovernorProxy), '",\n',
            '  "epochManager": "', vm.toString(epochManagerProxy), '",\n',
            '  "gaugeController": "', vm.toString(gaugeControllerProxy), '",\n',
            '  "grantGauge": "', vm.toString(grantGaugeProxy), '"\n',
            '}'
        ));

        vm.writeFile("deployments/governance-addresses.json", json);
        console.log("Deployment addresses saved to: deployments/governance-addresses.json");
    }
}
