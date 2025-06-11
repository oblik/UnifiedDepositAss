// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/USDCAutoForwarder.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MockUSDC} from "./mocks/MockUSDC.sol";

contract USDCAutoForwarderTest is Test {
    USDCAutoForwarder forwarder;
    MockUSDC usdc;
    address owner;
    address user;
    address recipient;

    function setUp() public {
        owner = address(this);
        user = vm.addr(1);
        recipient = vm.addr(2);

        forwarder = new USDCAutoForwarder(recipient);
        usdc = new MockUSDC();

        // Set USDC address in forwarder
        forwarder.setUSDCAddress(address(usdc));

        // Mint USDC to user
        usdc.mint(user, 1_000e6); // 1,000 USDC (6 decimals)
    }

    function testDepositUSDC() public {
        uint256 depositAmount = 100e6; // 100 USDC
        
        vm.startPrank(user);
        
        // Check initial balances
        assertEq(usdc.balanceOf(user), 1_000e6);
        assertEq(usdc.balanceOf(address(forwarder)), 0);
        
        // Approve forwarder to spend USDC
        usdc.approve(address(forwarder), depositAmount);
        
        // Deposit USDC
        vm.expectEmit(true, true, true, true);
        emit USDCAutoForwarder.USDCDeposited(user, depositAmount, block.timestamp);
        
        forwarder.depositUSDC(depositAmount);
        
        // Check balances after deposit
        assertEq(usdc.balanceOf(user), 900e6); // 1000 - 100
        assertEq(usdc.balanceOf(address(forwarder)), depositAmount);
        assertEq(forwarder.getBalance(), depositAmount);
        
        vm.stopPrank();
    }

    function testUpdateRecipient() public {
        address newRecipient = vm.addr(3);
        forwarder.updateRecipient(newRecipient);
        assertEq(forwarder.recipient(), newRecipient);
    }

    function testDepositZeroReverts() public {
        vm.startPrank(user);
        vm.expectRevert(USDCAutoForwarder.ZeroAmount.selector);
        forwarder.depositUSDC(0);
        vm.stopPrank();
    }
}
