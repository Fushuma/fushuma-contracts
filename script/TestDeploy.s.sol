// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/VotingEscrow.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TestDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying VotingEscrow implementation...");
        VotingEscrow implementation = new VotingEscrow();
        console.log("Implementation deployed at:", address(implementation));
        
        console.log("Creating proxy with initialization...");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        
        bytes memory initData = abi.encodeWithSelector(
            VotingEscrow.initialize.selector,
            wfuma,                    // _token
            admin,                    // _admin
            100 ether,                // _minDeposit (100 WFUMA)
            604800,                   // _warmupPeriod (7 days)
            1209600,                  // _cooldownPeriod (14 days)
            31536000,                 // _maxLockDuration (1 year)
            4                         // _maxMultiplier
        );
        
        console.log("Init data length:", initData.length);
        
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );
        
        console.log("Proxy deployed at:", address(proxy));
        console.log("SUCCESS!");
        
        vm.stopBroadcast();
    }
}
