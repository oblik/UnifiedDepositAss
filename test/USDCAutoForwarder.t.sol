// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/USDCAutoForwarder.sol";
import "./mocks/MockUSDC.sol";

contract USDCAutoForwarderTest is Test {
    USDCAutoForwarder public forwarder;
    MockUSDC public usdc;
    address public recipient;
    address public user;
    uint256 public constant INITIAL_BALANCE = 1000 * 1e6; // 1000 USDC

    function setUp() public {
        // Deploy mock USDC
        usdc = new MockUSDC();

        // Set up test addresses
        recipient = makeAddr("recipient");
        user = makeAddr("user");

        // Deploy forwarder
        forwarder = new USDCAutoForwarder(address(usdc), recipient);

        // Give user some USDC
        usdc.transfer(user, INITIAL_BALANCE);

        // Label addresses for better trace output
        vm.label(address(usdc), "USDC");
        vm.label(address(forwarder), "Forwarder");
        vm.label(recipient, "Recipient");
        vm.label(user, "User");
    }

    function test_InitialState() public {
        assertEq(address(forwarder.usdc()), address(usdc));
        assertEq(forwarder.recipient(), recipient);
        assertEq(forwarder.owner(), address(this));
        assertEq(usdc.balanceOf(user), INITIAL_BALANCE);
        assertEq(usdc.balanceOf(recipient), 0);
    }

    function test_DepositAndForward() public {
        uint256 depositAmount = 100 * 1e6; // 100 USDC

        // Approve and deposit as user
        vm.startPrank(user);
        usdc.approve(address(forwarder), depositAmount);

        vm.expectEmit(true, false, false, true);
        emit USDCAutoForwarder.USDCDeposited(user, depositAmount, block.timestamp);
        forwarder.depositUSDC(depositAmount);
        vm.stopPrank();

        // Check balances after deposit
        assertEq(usdc.balanceOf(address(forwarder)), depositAmount);
        assertEq(usdc.balanceOf(user), INITIAL_BALANCE - depositAmount);

        // Forward USDC
        vm.expectEmit(true, false, false, true);
        emit USDCAutoForwarder.USDCForwarded(recipient, depositAmount, block.timestamp);
        forwarder.forwardUSDC(depositAmount);

        // Check final balances
        assertEq(usdc.balanceOf(address(forwarder)), 0);
        assertEq(usdc.balanceOf(recipient), depositAmount);
    }

    function test_RevertZeroDeposit() public {
        vm.startPrank(user);
        usdc.approve(address(forwarder), 1);
        vm.expectRevert(USDCAutoForwarder.ZeroAmount.selector);
        forwarder.depositUSDC(0);
        vm.stopPrank();
    }

    function test_RevertZeroForward() public {
        vm.expectRevert(USDCAutoForwarder.ZeroAmount.selector);
        forwarder.forwardUSDC(0);
    }

    function test_RevertInsufficientBalance() public {
        vm.startPrank(user);
        usdc.approve(address(forwarder), 100 * 1e6);
        forwarder.depositUSDC(100 * 1e6);
        vm.stopPrank();

        vm.expectRevert(USDCAutoForwarder.InsufficientBalance.selector);
        forwarder.forwardUSDC(101 * 1e6);
    }

    function test_UpdateRecipient() public {
        address newRecipient = makeAddr("newRecipient");

        vm.expectEmit(true, true, false, false);
        emit USDCAutoForwarder.RecipientUpdated(recipient, newRecipient);
        forwarder.updateRecipient(newRecipient);

        assertEq(forwarder.recipient(), newRecipient);
    }

    function test_RevertUpdateRecipientZeroAddress() public {
        vm.expectRevert(USDCAutoForwarder.ZeroAddress.selector);
        forwarder.updateRecipient(address(0));
    }

    function test_GetBalance() public {
        assertEq(forwarder.getBalance(), 0);

        uint256 depositAmount = 100 * 1e6;
        vm.startPrank(user);
        usdc.approve(address(forwarder), depositAmount);
        forwarder.depositUSDC(depositAmount);
        vm.stopPrank();

        assertEq(forwarder.getBalance(), depositAmount);
    }
}
