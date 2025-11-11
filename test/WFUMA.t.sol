// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/tokens/WFUMA.sol";

contract WFUMATest is Test {
    WFUMA public wfuma;
    address public user1;
    address public user2;

    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Approval(address indexed src, address indexed guy, uint wad);

    function setUp() public {
        wfuma = new WFUMA();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Fund test users
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function testDeposit() public {
        vm.startPrank(user1);
        
        uint256 depositAmount = 1 ether;
        
        vm.expectEmit(true, false, false, true);
        emit Deposit(user1, depositAmount);
        
        wfuma.deposit{value: depositAmount}();
        
        assertEq(wfuma.balanceOf(user1), depositAmount);
        assertEq(wfuma.totalSupply(), depositAmount);
        
        vm.stopPrank();
    }

    function testDepositViaReceive() public {
        vm.startPrank(user1);
        
        uint256 depositAmount = 1 ether;
        
        vm.expectEmit(true, false, false, true);
        emit Deposit(user1, depositAmount);
        
        (bool success, ) = address(wfuma).call{value: depositAmount}("");
        assertTrue(success);
        
        assertEq(wfuma.balanceOf(user1), depositAmount);
        
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(user1);
        
        uint256 depositAmount = 1 ether;
        wfuma.deposit{value: depositAmount}();
        
        uint256 balanceBefore = user1.balance;
        
        vm.expectEmit(true, false, false, true);
        emit Withdrawal(user1, depositAmount);
        
        wfuma.withdraw(depositAmount);
        
        assertEq(wfuma.balanceOf(user1), 0);
        assertEq(user1.balance, balanceBefore + depositAmount);
        
        vm.stopPrank();
    }

    function testWithdrawInsufficientBalance() public {
        vm.startPrank(user1);
        
        vm.expectRevert("Insufficient balance");
        wfuma.withdraw(1 ether);
        
        vm.stopPrank();
    }

    function testTransfer() public {
        vm.startPrank(user1);
        
        uint256 depositAmount = 1 ether;
        wfuma.deposit{value: depositAmount}();
        
        uint256 transferAmount = 0.5 ether;
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, user2, transferAmount);
        
        bool success = wfuma.transfer(user2, transferAmount);
        assertTrue(success);
        
        assertEq(wfuma.balanceOf(user1), depositAmount - transferAmount);
        assertEq(wfuma.balanceOf(user2), transferAmount);
        
        vm.stopPrank();
    }

    function testTransferInsufficientBalance() public {
        vm.startPrank(user1);
        
        vm.expectRevert("Insufficient balance");
        wfuma.transfer(user2, 1 ether);
        
        vm.stopPrank();
    }

    function testApprove() public {
        vm.startPrank(user1);
        
        uint256 approvalAmount = 1 ether;
        
        vm.expectEmit(true, true, false, true);
        emit Approval(user1, user2, approvalAmount);
        
        bool success = wfuma.approve(user2, approvalAmount);
        assertTrue(success);
        
        assertEq(wfuma.allowance(user1, user2), approvalAmount);
        
        vm.stopPrank();
    }

    function testTransferFrom() public {
        vm.startPrank(user1);
        uint256 depositAmount = 1 ether;
        wfuma.deposit{value: depositAmount}();
        wfuma.approve(user2, depositAmount);
        vm.stopPrank();
        
        vm.startPrank(user2);
        
        uint256 transferAmount = 0.5 ether;
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, user2, transferAmount);
        
        bool success = wfuma.transferFrom(user1, user2, transferAmount);
        assertTrue(success);
        
        assertEq(wfuma.balanceOf(user1), depositAmount - transferAmount);
        assertEq(wfuma.balanceOf(user2), transferAmount);
        assertEq(wfuma.allowance(user1, user2), depositAmount - transferAmount);
        
        vm.stopPrank();
    }

    function testTransferFromInsufficientAllowance() public {
        vm.startPrank(user1);
        uint256 depositAmount = 1 ether;
        wfuma.deposit{value: depositAmount}();
        vm.stopPrank();
        
        vm.startPrank(user2);
        
        vm.expectRevert("Insufficient allowance");
        wfuma.transferFrom(user1, user2, depositAmount);
        
        vm.stopPrank();
    }

    function testTransferFromInsufficientBalance() public {
        vm.startPrank(user1);
        wfuma.approve(user2, 1 ether);
        vm.stopPrank();
        
        vm.startPrank(user2);
        
        vm.expectRevert("Insufficient balance");
        wfuma.transferFrom(user1, user2, 1 ether);
        
        vm.stopPrank();
    }

    function testTransferFromUnlimitedAllowance() public {
        vm.startPrank(user1);
        uint256 depositAmount = 1 ether;
        wfuma.deposit{value: depositAmount}();
        wfuma.approve(user2, type(uint256).max);
        vm.stopPrank();
        
        vm.startPrank(user2);
        
        uint256 transferAmount = 0.5 ether;
        wfuma.transferFrom(user1, user2, transferAmount);
        
        // Unlimited allowance should not decrease
        assertEq(wfuma.allowance(user1, user2), type(uint256).max);
        
        vm.stopPrank();
    }

    function testTotalSupply() public {
        assertEq(wfuma.totalSupply(), 0);
        
        vm.prank(user1);
        wfuma.deposit{value: 1 ether}();
        assertEq(wfuma.totalSupply(), 1 ether);
        
        vm.prank(user2);
        wfuma.deposit{value: 2 ether}();
        assertEq(wfuma.totalSupply(), 3 ether);
        
        vm.prank(user1);
        wfuma.withdraw(0.5 ether);
        assertEq(wfuma.totalSupply(), 2.5 ether);
    }

    function testMetadata() public {
        assertEq(wfuma.name(), "Wrapped FUMA");
        assertEq(wfuma.symbol(), "WFUMA");
        assertEq(wfuma.decimals(), 18);
    }

    function testFuzzDeposit(uint96 amount) public {
        vm.assume(amount > 0);
        vm.deal(user1, amount);
        
        vm.prank(user1);
        wfuma.deposit{value: amount}();
        
        assertEq(wfuma.balanceOf(user1), amount);
        assertEq(wfuma.totalSupply(), amount);
    }

    function testFuzzWithdraw(uint96 amount) public {
        vm.assume(amount > 0);
        vm.deal(user1, amount);
        
        vm.startPrank(user1);
        wfuma.deposit{value: amount}();
        
        uint256 balanceBefore = user1.balance;
        wfuma.withdraw(amount);
        
        assertEq(wfuma.balanceOf(user1), 0);
        assertEq(user1.balance, balanceBefore + amount);
        vm.stopPrank();
    }

    function testFuzzTransfer(uint96 depositAmount, uint96 transferAmount) public {
        vm.assume(depositAmount > 0);
        vm.assume(transferAmount <= depositAmount);
        vm.deal(user1, depositAmount);
        
        vm.startPrank(user1);
        wfuma.deposit{value: depositAmount}();
        wfuma.transfer(user2, transferAmount);
        vm.stopPrank();
        
        assertEq(wfuma.balanceOf(user1), depositAmount - transferAmount);
        assertEq(wfuma.balanceOf(user2), transferAmount);
    }
}
