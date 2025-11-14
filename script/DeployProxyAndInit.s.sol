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
    function name() external view returns (string memory);
    function token() external view returns (address);
    function gaugeId() external view returns (uint256);
}

interface IGaugeController {
    function addGauge(address _gaugeAddress, string memory _name, string memory _gaugeType) external returns (uint256);
}

contract DeployProxyAndInit is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address implementation = 0xB03bB1EC617604653cDeA00027d8814FC7617eED;
        address gaugeController = 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466;
        address epochManager = 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453;
        address wfuma = 0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E;
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Step 2: Deploying MinimalProxy...");
        MinimalProxy proxy = new MinimalProxy(implementation);
        console.log("Proxy deployed at:", address(proxy));
        
        console.log("\nStep 3: Initializing GrantGauge...");
        IGrantGauge(address(proxy)).initialize(
            gaugeController,
            epochManager,
            wfuma,
            0,
            "Fushuma Grant Gauge"
        );
        console.log("GrantGauge initialized!");
        
        console.log("\nStep 4: Registering with GaugeController...");
        uint256 gaugeId = IGaugeController(gaugeController).addGauge(
            address(proxy),
            "Fushuma Grant Gauge",
            "grant"
        );
        console.log("GrantGauge registered with ID:", gaugeId);
        
        vm.stopBroadcast();
        
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("GrantGauge Proxy:", address(proxy));
        console.log("Name:", IGrantGauge(address(proxy)).name());
        console.log("Token:", IGrantGauge(address(proxy)).token());
        console.log("Gauge ID:", IGrantGauge(address(proxy)).gaugeId());
    }
}
