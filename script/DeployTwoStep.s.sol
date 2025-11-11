// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/VotingEscrow.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract DeployTwoStep is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address wfuma = vm.envAddress("FUMA_TOKEN_ADDRESS");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Step 1: Deploying VotingEscrow implementation...");
        VotingEscrow implementation = new VotingEscrow();
        console.log("Implementation deployed at:", address(implementation));
        
        console.log("Step 2: Deploying ProxyAdmin...");
        ProxyAdmin proxyAdmin = new ProxyAdmin(msg.sender);
        console.log("ProxyAdmin deployed at:", address(proxyAdmin));
        
        console.log("Step 3: Deploying TransparentUpgradeableProxy with empty init...");
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementation),
            address(proxyAdmin),
            "" // Empty initialization data
        );
        console.log("Proxy deployed at:", address(proxy));
        
        console.log("Step 4: Initializing through proxy...");
        VotingEscrow ve = VotingEscrow(address(proxy));
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
