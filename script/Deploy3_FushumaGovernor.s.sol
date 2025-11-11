// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/governance/FushumaGovernor.sol";
import "../contracts/proxy/MinimalProxy.sol";

contract Deploy3_FushumaGovernor is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address veProxy = 0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f;
        address councilProxy = 0x92bCcdcae7B73A5332429e517D26515D447e9997;
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying FushumaGovernor...");
        FushumaGovernor impl = new FushumaGovernor();
        MinimalProxy proxy = new MinimalProxy(address(impl));
        FushumaGovernor governor = FushumaGovernor(payable(address(proxy)));
        
        governor.initialize(
            msg.sender,      // temp admin
            veProxy,
            councilProxy,
            1000 ether,      // proposalThreshold
            1000,            // quorumBps (10%)
            50400,           // votingPeriod (7 days)
            7200,            // votingDelay (1 day)
            172800           // timelockDelay (2 days)
        );
        
        console.log("Transferring admin role to:", admin);
        governor.grantRole(governor.DEFAULT_ADMIN_ROLE(), admin);
        governor.grantRole(governor.PROPOSER_ROLE(), admin);
        governor.grantRole(governor.EXECUTOR_ROLE(), admin);
        governor.renounceRole(governor.DEFAULT_ADMIN_ROLE(), msg.sender);
        
        console.log("FushumaGovernor Proxy:", address(proxy));
        console.log("Proposal Threshold:", governor.proposalThreshold());
        
        vm.stopBroadcast();
    }
}
