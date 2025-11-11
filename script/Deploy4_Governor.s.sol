// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/FushumaGovernor.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract Deploy4_Governor is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        
        vm.startBroadcast(pk);
        
        console.log("Deploying FushumaGovernor...");
        FushumaGovernor impl = new FushumaGovernor();
        MinimalProxy proxy = new MinimalProxy(address(impl));
        FushumaGovernor gov = FushumaGovernor(payable(address(proxy)));
        
        gov.initialize(
            msg.sender,
            0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f, // VotingEscrow
            0x92bCcdcae7B73A5332429e517D26515D447e9997, // GovernanceCouncil
            1000 ether,
            1000,
            50400,
            7200,
            172800
        );
        
        gov.grantRole(gov.DEFAULT_ADMIN_ROLE(), admin);
        gov.renounceRole(gov.DEFAULT_ADMIN_ROLE(), msg.sender);
        
        console.log("FushumaGovernor Proxy:", address(proxy));
        
        vm.stopBroadcast();
    }
}
