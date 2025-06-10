const { ethers } = require("ethers");
const logger = require("./logger");

// ABI for the USDCAutoForwarder contract
const FORWARDER_ABI = [
  "event USDCDeposited(address indexed sender, uint256 amount, uint256 timestamp)",
  "event USDCForwarded(address indexed recipient, uint256 amount, uint256 timestamp)",
  "function forwardUSDC(uint256 amount) external nonReentrant",
  "function getBalance() external view returns (uint256)",
];

class ChainMonitor {
  constructor(network, forwarderAddress, forwarderPrivateKey, gasSettings) {
    this.network = network;
    this.forwarderAddress = forwarderAddress;
    this.provider = new ethers.JsonRpcProvider(network.rpcUrl);
    this.wallet = new ethers.Wallet(forwarderPrivateKey, this.provider);
    this.contract = new ethers.Contract(
      forwarderAddress,
      FORWARDER_ABI,
      this.wallet
    );
    this.gasSettings = gasSettings;
  }

  async start() {
    logger.info(`Starting monitor for ${this.network.name}`);

    try {
      // Listen for deposit events
      this.contract.on(
        "USDCDeposited",
        async (sender, amount, timestamp, event) => {
          logger.info(`New deposit detected on ${this.network.name}:`, {
            sender,
            amount: amount.toString(),
            timestamp: timestamp.toString(),
            transactionHash: event.transactionHash,
          });

          await this.handleDeposit(amount);
        }
      );

      // Initial check for any pending deposits
      await this.checkPendingDeposits();
    } catch (error) {
      logger.error(`Error starting monitor for ${this.network.name}:`, error);
      throw error;
    }
  }

  async stop() {
    logger.info(`Stopping monitor for ${this.network.name}`);
    await this.contract.removeAllListeners();
  }

  async checkPendingDeposits() {
    try {
      const balance = await this.contract.getBalance();
      if (balance > 0) {
        logger.info(`Found pending balance on ${this.network.name}:`, {
          balance: balance.toString(),
        });
        await this.handleDeposit(balance);
      }
    } catch (error) {
      logger.error(
        `Error checking pending deposits for ${this.network.name}:`,
        error
      );
    }
  }

  async handleDeposit(amount) {
    try {
      // Get current gas price
      const gasPrice = await this.provider.getFeeData();

      // Check if gas price is acceptable
      if (
        gasPrice.gasPrice >
        ethers.parseUnits(this.gasSettings.maxGasPrice, "gwei")
      ) {
        logger.warn(
          `Gas price too high on ${this.network.name}. Waiting for lower price.`
        );
        return;
      }

      // Forward the USDC
      const tx = await this.contract.forwardUSDC(amount, {
        gasLimit: this.gasSettings.gasLimit,
      });

      logger.info(`Forwarding transaction sent on ${this.network.name}:`, {
        transactionHash: tx.hash,
        amount: amount.toString(),
      });

      // Wait for transaction confirmation
      const receipt = await tx.wait();

      logger.info(`Forwarding completed on ${this.network.name}:`, {
        transactionHash: receipt.hash,
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed.toString(),
      });
    } catch (error) {
      logger.error(`Error forwarding USDC on ${this.network.name}:`, error);
    }
  }
}

module.exports = ChainMonitor;
