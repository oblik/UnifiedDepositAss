// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/USDCAutoForwarder.sol";
import "forge-std/console.sol";
import "forge-std/Script.sol";

/**
 * @title MultiChainDeploymentScript
 * @dev Script to deploy USDCAutoForwarder at the same deterministic address across multiple chains
 */
contract MultiChainDeploymentScript is Script {
    // Configuration struct for each chain
    struct ChainConfig {
        uint256 chainId;
        string name;
        address usdcToken;
        address recipient;
    }

    // Events
    event ContractDeployed(
        uint256 indexed chainId,
        string chainName,
        address indexed contractAddress,
        bytes32 indexed salt,
        address deployer
    );

    event USDCAddressSet(
        uint256 indexed chainId,
        address indexed contractAddress,
        address indexed usdcToken
    );

    // Constants
    bytes32 public constant DEPLOYMENT_SALT = 0x0000000000000000000000000000000000000000000000000000000000000007;

    // Chain configurations
    function getChainConfigs() internal pure returns (ChainConfig[] memory) {
        ChainConfig[] memory configs = new ChainConfig[](3);

        // Arbitrum Sepolia Testnet
        configs[0] = ChainConfig({
            chainId: 421614,
            name: "Arbitrum Sepolia",
            usdcToken: 0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d, // USDC on Arbitrum Sepolia (bridged from Ethereum Sepolia)
            recipient: 0xF8591FaFE75eE95499D0169E2d19142f27de6542
        });

        // Optimism Sepolia Testnet
        configs[1] = ChainConfig({
            chainId: 11155420,
            name: "Optimism Sepolia",
            usdcToken: 0x5fd84259d66Cd46123540766Be93DFE6D43130D7, // USDC on Optimism Sepolia
            recipient: 0xF8591FaFE75eE95499D0169E2d19142f27de6542
        });

        // Base Sepolia Testnet
        configs[2] = ChainConfig({
            chainId: 84532,
            name: "Base Sepolia",
            usdcToken: 0x036CbD53842c5426634e7929541eC2318f3dCF7e, // USDC on Base Sepolia
            recipient: 0xF8591FaFE75eE95499D0169E2d19142f27de6542
        });

        return configs;
    }

    function run() external {
        // Get current chain ID
        uint256 currentChainId = block.chainid;
        console.log("Current Chain ID:", currentChainId);

        // Get configurations
        ChainConfig[] memory configs = getChainConfigs();

        // Find configuration for current chain
        ChainConfig memory currentConfig;
        bool found = false;

        for (uint256 i = 0; i < configs.length; i++) {
            if (configs[i].chainId == currentChainId) {
                currentConfig = configs[i];
                found = true;
                break;
            }
        }

        require(found, "Chain configuration not found for current chain");

        console.log("Deploying on:", currentConfig.name);
        console.log("USDC Token:", currentConfig.usdcToken);

        // Deploy the contract
        address deployedAddress = deployForwarder(DEPLOYMENT_SALT, currentConfig.recipient);

        // Set USDC address after deployment (must be done by the same account that deployed)
        setUSDCAddress(payable(deployedAddress), currentConfig.usdcToken);

        // Verify the address is the same across all chains
        console.log("\n=== Address Verification ===");
        for (uint256 i = 0; i < configs.length; i++) {
            address predictedAddress = computeAddress(DEPLOYMENT_SALT, configs[i].recipient, msg.sender);

        }

        console.log("\n=== Deployment Complete ===");
        console.log("Contract Address:", deployedAddress);
        console.log("USDC Token Set:", currentConfig.usdcToken);
    }

    /**
     * @dev Deploys USDCAutoForwarder using CREATE2 for deterministic address
     */
    function deployForwarder(bytes32 salt, address recipient) public returns (address deployed) {
        // Check if contract already exists first (before starting broadcast)
        address predictedAddress = computeAddress(salt, recipient, msg.sender);

        if (predictedAddress.code.length > 0) {
            console.log("Contract already deployed at:", predictedAddress);
            return predictedAddress;
        }

        vm.startBroadcast();

        deployed = address(new USDCAutoForwarder{salt: salt}(recipient));

        console.log("Contract deployed at:", deployed);

        vm.stopBroadcast();

        emit ContractDeployed(block.chainid, "Current Chain", deployed, salt, msg.sender);

        return deployed;
    }

    /**
     * @dev Sets the USDC address after deployment
     */
    function setUSDCAddress(address payable contractAddress, address usdcToken) public {
        USDCAutoForwarder forwarder = USDCAutoForwarder(payable(contractAddress));
        
        // Check if USDC address is already set
        try forwarder.usdc() returns (IERC20 currentUsdc) {
            if (address(currentUsdc) != address(0)) {
                console.log("USDC address already set to:", address(currentUsdc));
                return;
            }
        } catch {
            // USDC not set yet, continue
        }

        // Verify we are the owner before attempting to set USDC address
        address contractOwner = forwarder.owner();
        address currentSender = msg.sender;
        console.log("Contract owner:", contractOwner);
        console.log("Current sender:", currentSender);
        

        vm.startBroadcast();
        
        // Set USDC address
        forwarder.setUSDCAddress(usdcToken);
        console.log("USDC address set to:", usdcToken);

        vm.stopBroadcast();

        emit USDCAddressSet(block.chainid, contractAddress, usdcToken);
    }

    /**
     * @dev Computes the deterministic address where a contract will be deployed
     * @notice Updated to only use recipient since USDC is set after deployment
     */
    function computeAddress(bytes32 salt, address recipient, address deployer) public pure returns (address predicted) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                deployer,
                salt,
                keccak256(abi.encodePacked(type(USDCAutoForwarder).creationCode, abi.encode(recipient)))
            )
        );
        predicted = address(uint160(uint256(hash)));
    }

}