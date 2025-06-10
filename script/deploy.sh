#!/bin/bash

# Load environment variables
source .env

# Function to deploy factory to a network
deploy_factory() {
    local network=$1
    local rpc_url=$2
    echo "Deploying Create2Factory to $network..."
    
    forge script script/Create2Factory.s.sol:Create2FactoryScript \
        --rpc-url $rpc_url \
        --broadcast \
        --verify
}

# Function to deploy forwarder to a network
deploy_forwarder() {
    local network=$1
    local rpc_url=$2
    local usdc_address=$3
    
    echo "Deploying USDCAutoForwarder to $network..."
    
    # Temporarily set the USDC_TOKEN_ADDRESS for this deployment
    export USDC_TOKEN_ADDRESS=$usdc_address
    
    forge script script/DeployForwarder.s.sol:DeployForwarderScript \
        --rpc-url $rpc_url \
        --broadcast \
        --verify
}

# Deploy to Arbitrum Sepolia
echo "=== Deploying to Arbitrum Sepolia ==="
factory_address=$(deploy_factory "arbitrum-sepolia" $ARBITRUM_SEPOLIA_RPC_URL)
export FACTORY_ADDRESS=$factory_address
deploy_forwarder "arbitrum-sepolia" $ARBITRUM_SEPOLIA_RPC_URL $USDC_TOKEN_ADDRESS_ARBITRUM

# Deploy to Optimism Sepolia
echo "=== Deploying to Optimism Sepolia ==="
factory_address=$(deploy_factory "optimism-sepolia" $OPTIMISM_SEPOLIA_RPC_URL)
export FACTORY_ADDRESS=$factory_address
deploy_forwarder "optimism-sepolia" $OPTIMISM_SEPOLIA_RPC_URL $USDC_TOKEN_ADDRESS_OPTIMISM

# Deploy to Base Sepolia
echo "=== Deploying to Base Sepolia ==="
factory_address=$(deploy_factory "base-sepolia" $BASE_SEPOLIA_RPC_URL)
export FACTORY_ADDRESS=$factory_address
deploy_forwarder "base-sepolia" $BASE_SEPOLIA_RPC_URL $USDC_TOKEN_ADDRESS_BASE

echo "=== Deployment Complete ===" 