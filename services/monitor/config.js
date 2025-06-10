require("dotenv").config();

const networks = {
  arbitrumSepolia: {
    name: "Arbitrum Sepolia",
    rpcUrl: process.env.ARBITRUM_SEPOLIA_RPC_URL,
    chainId: 421614,
    usdcAddress: process.env.USDC_TOKEN_ADDRESS_ARBITRUM,
  },
  optimismSepolia: {
    name: "Optimism Sepolia",
    rpcUrl: process.env.OPTIMISM_SEPOLIA_RPC_URL,
    chainId: 11155420,
    usdcAddress: process.env.USDC_TOKEN_ADDRESS_OPTIMISM,
  },
  baseSepolia: {
    name: "Base Sepolia",
    rpcUrl: process.env.BASE_SEPOLIA_RPC_URL,
    chainId: 84532,
    usdcAddress: process.env.USDC_TOKEN_ADDRESS_BASE,
  },
};

const config = {
  networks,
  forwarderAddress: process.env.USDC_FORWARDER_ADDRESS,
  forwarderPrivateKey: process.env.FORWARDER_PRIVATE_KEY,
  gasSettings: {
    maxGasPrice: process.env.MAX_GAS_PRICE || "50", // gwei
    gasLimit: process.env.GAS_LIMIT || "300000",
  },
};

// Validate required environment variables
const requiredEnvVars = [
  "ARBITRUM_SEPOLIA_RPC_URL",
  "OPTIMISM_SEPOLIA_RPC_URL",
  "BASE_SEPOLIA_RPC_URL",
  "FORWARDER_PRIVATE_KEY",
  "USDC_FORWARDER_ADDRESS",
  "USDC_TOKEN_ADDRESS_ARBITRUM",
  "USDC_TOKEN_ADDRESS_OPTIMISM",
  "USDC_TOKEN_ADDRESS_BASE",
];

for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`Missing required environment variable: ${envVar}`);
  }
}

module.exports = config;
