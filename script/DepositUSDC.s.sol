// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {IUSDCAutoForwarder} from "../src/interfaces/IUSDCAutoForwarder.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/**
 * @title DepositUSDC Script
 * @dev Script for depositing 2 USDC tokens into the USDCAutoForwarder contract.
 */
contract DepositUSDCScript is Script {
    // Contract address
    address constant TARGET_CONTRACT = 0xaa4b4b0De774200f6000c6DAbe9Cc2a2529A06F2;
    
    address constant USDC_TOKEN = 0x036CbD53842c5426634e7929541eC2318f3dCF7e; 
    
    function run() external {
        // .env doesnt have this passing it in the terminal itself 
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY"); 
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer address:", deployer);
        console.log("Target contract:", TARGET_CONTRACT);
        
        vm.startBroadcast(deployerPrivateKey);
        IUSDCAutoForwarder targetContract = IUSDCAutoForwarder(TARGET_CONTRACT);
        IERC20 usdcToken = IERC20(USDC_TOKEN);
        
        uint256 depositAmount = 2 * 10**6; // 2 USDC
        
        console.log("Deposit amount:", depositAmount);
        
        // Check current USDC balance
        uint256 currentBalance = usdcToken.balanceOf(deployer);
        console.log("Current USDC balance of Sender:", currentBalance);
        
        require(currentBalance >= depositAmount, "Insufficient USDC balance");
        
        // Check current allowance
        uint256 currentAllowance = usdcToken.allowance(deployer, TARGET_CONTRACT);
        console.log("Current allowance:", currentAllowance);
        
        // Approve USDC spending if needed
        if (currentAllowance < depositAmount) {
            console.log("Approving USDC spending...");
            bool approvalSuccess = usdcToken.approve(TARGET_CONTRACT, depositAmount);
            require(approvalSuccess, "USDC approval failed");
            console.log("USDC approval successful");
        }
        
        // Call the depositUSDC function
        console.log("Calling depositUSDC...");
        targetContract.depositUSDC(depositAmount);
        console.log("depositUSDC call successful!");
        
        vm.stopBroadcast();
    }

}