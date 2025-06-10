const config = require("./config");
const ChainMonitor = require("./chainMonitor");
const logger = require("./logger");

class UnifiedDepositMonitor {
  constructor() {
    this.monitors = new Map();
  }

  async start() {
    logger.info("Starting Unified Deposit Monitor");

    try {
      // Initialize monitors for each network
      for (const [networkKey, network] of Object.entries(config.networks)) {
        const monitor = new ChainMonitor(
          network,
          config.forwarderAddress,
          config.forwarderPrivateKey,
          config.gasSettings
        );

        await monitor.start();
        this.monitors.set(networkKey, monitor);
      }

      // Handle graceful shutdown
      process.on("SIGINT", async () => {
        await this.stop();
        process.exit(0);
      });

      process.on("SIGTERM", async () => {
        await this.stop();
        process.exit(0);
      });

      logger.info("Unified Deposit Monitor started successfully");
    } catch (error) {
      logger.error("Error starting Unified Deposit Monitor:", error);
      process.exit(1);
    }
  }

  async stop() {
    logger.info("Stopping Unified Deposit Monitor");

    for (const [networkKey, monitor] of this.monitors) {
      try {
        await monitor.stop();
        logger.info(`Stopped monitor for ${networkKey}`);
      } catch (error) {
        logger.error(`Error stopping monitor for ${networkKey}:`, error);
      }
    }
  }
}

// Start the monitor
const monitor = new UnifiedDepositMonitor();
monitor.start().catch((error) => {
  logger.error("Fatal error:", error);
  process.exit(1);
});
