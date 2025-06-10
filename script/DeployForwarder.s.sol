// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "./Create2Factory.s.sol";
import "../src/USDCAutoForwarder.sol";

contract DeployForwarderScript is Script {
    // Fixed salt for deterministic deployment across all chains
    bytes32 constant SALT = bytes32(uint256(0x1234567890));

    function run() external {
        // Load environment variables
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address usdcAddress = vm.envAddress("USDC_TOKEN_ADDRESS");
        address recipientAddress = vm.envAddress("RECIPIENT_ADDRESS");
        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");

        // Get the Create2Factory instance
        Create2Factory factory = Create2Factory(factoryAddress);

        // Prepare the bytecode with constructor arguments
        bytes memory constructorArgs = abi.encode(usdcAddress, recipientAddress);
        bytes memory bytecode = abi.encodePacked(type(USDCAutoForwarder).creationCode, constructorArgs);

        // Calculate the expected address
        address expectedAddress = factory.computeAddress(bytecode, SALT);
        console.log("Expected Forwarder Address:", expectedAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the forwarder using CREATE2
        address deployedAddress = factory.deploy(bytecode, SALT);
        require(deployedAddress == expectedAddress, "Deployment address mismatch");

        vm.stopBroadcast();

        console.log("USDCAutoForwarder deployed at:", deployedAddress);
        console.log("Chain ID:", block.chainid);
    }
}

// Helper script to compute the expected address without deploying
contract ComputeForwarderAddress is Script {
    bytes32 constant SALT = bytes32(uint256(0x1234567890));

    function run() external view {
        address usdcAddress = vm.envAddress("USDC_TOKEN_ADDRESS");
        address recipientAddress = vm.envAddress("RECIPIENT_ADDRESS");
        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");

        Create2Factory factory = Create2Factory(factoryAddress);

        bytes memory constructorArgs = abi.encode(usdcAddress, recipientAddress);
        bytes memory bytecode = abi.encodePacked(type(USDCAutoForwarder).creationCode, constructorArgs);

        address expectedAddress = factory.computeAddress(bytecode, SALT);
        console.log("Expected Forwarder Address:", expectedAddress);
    }
}
