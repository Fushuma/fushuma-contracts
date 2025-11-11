// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/VotingEscrow.sol";

contract DeploySimple is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying VotingEscrow directly (no proxy)...");
        VotingEscrow ve = new VotingEscrow();
        console.log("VotingEscrow deployed at:", address(ve));
        
        console.log("Initializing...");
        ve.initialize(
            wfuma,                    // _token
            admin,                    // _admin
            100 ether,                // _minDeposit (100 WFUMA)
            604800,                   // _warmupPeriod (7 days)
            1209600,                  // _cooldownPeriod (14 days)
            31536000,                 // _maxLockDuration (1 year)
            4                         // _maxMultiplier
        );
        
        console.log("Initialized!");
        console.log("Max multiplier:", ve.maxMultiplier());
        console.log("Min deposit:", ve.minDeposit());
        
        console.log("SUCCESS!");
        
        vm.stopBroadcast();
    }
}
