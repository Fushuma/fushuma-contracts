// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/GovernanceCouncil.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract Deploy2_GovernanceCouncil is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address council1 = vm.envAddress("COUNCIL_MEMBER_1");
        address council2 = vm.envAddress("COUNCIL_MEMBER_2");
        address council3 = vm.envAddress("COUNCIL_MEMBER_3");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying GovernanceCouncil...");
        GovernanceCouncil impl = new GovernanceCouncil();
        MinimalProxy proxy = new MinimalProxy(address(impl));
        GovernanceCouncil council = GovernanceCouncil(address(proxy));
        
        council.initialize(msg.sender, 2, 172800, 86400, 43200);
        
        console.log("Granting council member roles...");
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council1);
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council2);
        council.grantRole(council.COUNCIL_MEMBER_ROLE(), council3);
        
        console.log("Transferring admin role to:", admin);
        council.grantRole(council.DEFAULT_ADMIN_ROLE(), admin);
        council.grantRole(council.COUNCIL_ADMIN_ROLE(), admin);
        council.renounceRole(council.DEFAULT_ADMIN_ROLE(), msg.sender);
        
        console.log("GovernanceCouncil Proxy:", address(proxy));
        console.log("Required Approvals:", council.requiredApprovals());
        
        vm.stopBroadcast();
    }
}
