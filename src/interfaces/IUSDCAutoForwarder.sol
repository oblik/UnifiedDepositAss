// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/**
 * @title IUSDCAutoForwarder
 * @dev Interface for the USDCAutoForwarder contract
 */
interface IUSDCAutoForwarder {
    // Events
    event USDCDeposited(address indexed sender, uint256 amount, uint256 timestamp);
    event USDCForwarded(address indexed recipient, uint256 amount, uint256 timestamp);
    event RecipientUpdated(address indexed oldRecipient, address indexed newRecipient);

    // Custom errors
    error ZeroAmount();
    error ZeroAddress();
    error TransferFailed();
    error InsufficientBalance();
    error USDCAlreadySet();

    /**
     * @dev Returns the USDC token contract
     */
    function usdc() external view returns (IERC20);

    /**
     * @dev Returns the current recipient address
     */
    function recipient() external view returns (address);

    /**
     * @dev Returns the USDC set status
     */
    function usdcSetStatus() external view returns (bool);

    /**
     * @dev Sets the USDC token address
     * @param _usdcToken Address of the USDC token contract
     */
    function setUSDCAddress(address _usdcToken) external;

    /**
     * @dev Deposits USDC to the contract (backend will forward automatically)
     * @param amount Amount of USDC to deposit
     */
    function depositUSDC(uint256 amount) external;

    /**
     * @dev Forwards USDC to recipient (called by backend service)
     * @param amount Amount to forward
     */
    function forwardUSDC(uint256 amount) external;

    /**
     * @dev Updates the recipient address (only owner)
     * @param newRecipient New recipient address
     */
    function updateRecipient(address newRecipient) external;

    /**
     * @dev Returns the current USDC balance of this contract
     */
    function getBalance() external view returns (uint256);

    /**
     * @dev Returns the owner of the contract (from Ownable)
     */
    function owner() external view returns (address);

    /**
     * @dev Transfers ownership of the contract (from Ownable)
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) external;

    /**
     * @dev Renounces ownership of the contract (from Ownable)
     */
    function renounceOwnership() external;
}