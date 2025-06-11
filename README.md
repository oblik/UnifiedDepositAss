# Unified Deposit - Multi-Chain USDC Auto Forwarder

## Project Description

The Unified Deposit project is a multi-chain USDC auto-forwarding system that enables seamless USDC deposits across multiple blockchain networks with automatic forwarding to a specified recipient address. The system is designed to deploy identical smart contracts at the same deterministic address across different chains using CREATE2, ensuring a unified user experience regardless of the blockchain network.


## Contract Functions

### Main Functions

- `depositUSDC(uint256 amount)`: Deposit USDC to the contract
- `forwardUSDC(uint256 amount)`: Forward USDC to recipient (called by backend)
- `setUSDCAddress(address _usdcToken)`: Set the USDC token address
- `updateRecipient(address newRecipient)`: Update the recipient address (owner only)
- `getBalance()`: Get current USDC balance in the contract

### Events

- `USDCDeposited(address indexed sender, uint256 amount, uint256 timestamp)`
- `USDCForwarded(address indexed recipient, uint256 amount, uint256 timestamp)`
- `RecipientUpdated(address indexed oldRecipient, address indexed newRecipient)`


### Workflow

1. **Deployment Phase**:

   - Deploy contracts on all target chains using the same salt
   - Configure USDC token addresses for each chain
   - Verify identical addresses across networks

2. **Operation Phase**:

   - Users deposit USDC to the contract on any supported chain
   - Backend service detects deposit events
   - Service automatically calls `forwardUSDC()` to send funds to recipient
   - All transactions are logged and monitored

3. **Monitoring Phase**:
   - Continuous blockchain monitoring via Moralis webhooks
   - Real-time balance tracking
   - Error handling and retry mechanisms


1. Clone the repository
2. Set up environment variables in `.env`:
   ```
   MORALIS_API_KEY=your_moralis_api_key
   CONTRACT_ADDRESS=deployed_contract_address
   ARBITRUM_SEPOLIA_RPC=your_arbitrum_rpc_url
   OPTIMISM_SEPOLIA_RPC=your_optimism_rpc_url
   BASE_SEPOLIA_RPC=your_base_rpc_url
   ```

## Scripts

### To Deploy Contracts

Deploy the USDCAutoForwarder contract on each supported network:

**Arbitrum Sepolia:**

```bash
forge script script/DeployCreate2.s.sol:MultiChainDeploymentScript --rpc-url "YOUR_RPC_URL_ARBITRUM" --broadcast --private-key "PRIVATE_KEY"
```

**Optimism Sepolia:**

```bash
forge script script/DeployCreate2.s.sol:MultiChainDeploymentScript --rpc-url "YOUR_RPC_URL_OPTIMISM" --broadcast --private-key "PRIVATE_KEY"
```

**Base Sepolia:**

```bash
forge script script/DeployCreate2.s.sol:MultiChainDeploymentScript --rpc-url "YOUR_RPC_URL_BASE" --broadcast --private-key "PRIVATE_KEY"
```

### To Start the Backend Service

Start the monitoring and auto-forwarding service:

```bash
node services/index.js
```

### To Run Script to Send Funds to the Contract

Send USDC to the deployed contract for testing:

```bash
forge script script/DeployCreate2.s.sol:MultiChainDeploymentScript --rpc-url "RPC_URL_RESPECTIVE_CHAIN" --private-key "PRIVATE_KEY" --broadcast
```



