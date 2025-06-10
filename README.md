# Unified Deposit Backend Service

This backend service monitors USDC deposits across three different test networks (Arbitrum Sepolia, Optimism Sepolia, and Base Sepolia) and automatically forwards them to a specified recipient address.

## Features

- Monitors USDC deposits on multiple chains simultaneously
- Automatically forwards deposits to the specified recipient
- Gas price monitoring to ensure cost-effective transactions
- Comprehensive logging system
- Graceful shutdown handling
- Environment-based configuration

## Prerequisites

- Node.js v16 or higher
- Access to RPC endpoints for all three networks
- Private key with sufficient native tokens for gas fees
- Deployed USDCAutoForwarder contract addresses
- USDC token contract addresses for each network

## Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd unified-deposit
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Create and configure environment variables:

   ```bash
   cp .env.example .env
   ```

   Edit the `.env` file and fill in all required values:

   - RPC URLs for each network
   - Private key for the forwarder account
   - Contract addresses
   - Optional gas settings

## Configuration

The following environment variables are required:

- `ARBITRUM_SEPOLIA_RPC_URL`: RPC endpoint for Arbitrum Sepolia
- `OPTIMISM_SEPOLIA_RPC_URL`: RPC endpoint for Optimism Sepolia
- `BASE_SEPOLIA_RPC_URL`: RPC endpoint for Base Sepolia
- `FORWARDER_PRIVATE_KEY`: Private key of the account that will trigger forwarding
- `USDC_FORWARDER_ADDRESS`: Address of the deployed USDCAutoForwarder contract
- `USDC_TOKEN_ADDRESS_ARBITRUM`: USDC token address on Arbitrum Sepolia
- `USDC_TOKEN_ADDRESS_OPTIMISM`: USDC token address on Optimism Sepolia
- `USDC_TOKEN_ADDRESS_BASE`: USDC token address on Base Sepolia

Optional configuration:

- `MAX_GAS_PRICE`: Maximum gas price in gwei (default: 50)
- `GAS_LIMIT`: Gas limit for forwarding transactions (default: 300000)

## Running the Service

1. Start the service in production mode:

   ```bash
   npm start
   ```

2. Start the service in development mode (with auto-reload):
   ```bash
   npm run dev
   ```

## Monitoring and Logs

The service uses Winston for logging and creates two log files:

- `combined.log`: Contains all log levels
- `error.log`: Contains only error logs

Logs are also output to the console with color coding based on log level.

## Architecture

The service consists of several key components:

1. `ChainMonitor`: Handles monitoring and forwarding for a single chain
2. `UnifiedDepositMonitor`: Manages multiple chain monitors
3. Configuration management with environment variables
4. Logging system for tracking operations and errors

## Error Handling

The service includes comprehensive error handling:

- Network connectivity issues
- Contract interaction errors
- Gas price monitoring
- Graceful shutdown on process termination

## Development

To contribute or modify the service:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[MIT License](LICENSE)

## Support

For support or questions, please open an issue in the repository.
