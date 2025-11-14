// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/proxy/MinimalProxy.sol";

interface IGrantGauge {
    function initialize(
        address _gaugeController,
        address _epochManager,
        address _token,
        uint256 _gaugeId,
        string memory _name
    ) external;
}

contract DeployProxyOnly is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address implementation = 0xB03bB1EC617604653cDeA00027d8814FC7617eED;
        address gaugeController = 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466;
        address epochManager = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        address wfuma = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying MinimalProxy...");
        MinimalProxy proxy = new MinimalProxy(implementation);
        console.log("Proxy deployed at:", address(proxy));
        
        console.log("Initializing GrantGauge...");
        IGrantGauge(address(proxy)).initialize(
            gaugeController,
            epochManager,
            wfuma,
            0,
            "Fushuma Grant Gauge"
        );
        console.log("GrantGauge initialized!");
        
        vm.stopBroadcast();
        
        console.log("\n=== SUCCESS ===");
        console.log("GrantGauge Proxy:", address(proxy));
    }
}
