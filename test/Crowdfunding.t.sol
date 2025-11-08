// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test} from "forge-std/Test.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract CrowdfundingTest is Test {
    Crowdfunding public crowdfunding;
    MockERC20 public token;
    address public alice = makeAddr("alice"); 
    address public bob = makeAddr("bob");     

    
    receive() external payable {}

    function setUp() public {
        // Deploy mock ERC20 and crowdfunding with token address
        token = new MockERC20("TestToken", "TTK");
        crowdfunding = new Crowdfunding(address(token));

        // Mint tokens to participants
        token.mint(bob, 10 ether);
        token.mint(alice, 10 ether);

        vm.prank(bob);
        // approve crowdfunding contract to spend bob's tokens
        token.approve(address(crowdfunding), type(uint256).max);
    }

    function testCreateCampaign() public {
        vm.prank(alice);
        uint256 campaignId = crowdfunding.createCampaign(1 ether, 1 days, false);
        assertEq(crowdfunding.getCampaign(campaignId).creator, alice);
    }

    function testContribute() public {
        vm.prank(alice);
        uint256 campaignId = crowdfunding.createCampaign(1 ether, 1 days, false);
        vm.prank(bob);
        crowdfunding.contribute(campaignId, 0.5 ether);
        assertEq(crowdfunding.getCampaign(campaignId).totalFunds, 0.5 ether);
    }

    function testClaimFundsSuccess() public {
        vm.prank(alice);
        uint256 campaignId = crowdfunding.createCampaign(1 ether, 1 days, false);
        vm.prank(bob);
        crowdfunding.contribute(campaignId, 1 ether);

        vm.warp(block.timestamp + 1 days + 1);

        // Store token balances before claim
        uint256 initialAliceTokenBalance = token.balanceOf(alice);
        uint256 initialAdminTokenBalance = token.balanceOf(address(this));

        vm.prank(alice);
        crowdfunding.claimFunds(campaignId);

        // Check that Alice received 0.95 TTK
        assertEq(token.balanceOf(alice), initialAliceTokenBalance + 0.95 ether);
        // Check that admin (test contract) received 0.05 TTK
        assertEq(token.balanceOf(address(this)), initialAdminTokenBalance + 0.05 ether);
        // Check that crowdfunding contract token balance is 0
        assertEq(token.balanceOf(address(crowdfunding)), 0);
    }

    function testRefund() public {
        vm.prank(alice);
        uint256 campaignId = crowdfunding.createCampaign(2 ether, 1 days, false);
        vm.prank(bob);
        crowdfunding.contribute(campaignId, 1 ether);
        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(bob);
        crowdfunding.refund(campaignId);
        // crowdfunding contract token balance should be 0
        assertEq(token.balanceOf(address(crowdfunding)), 0);
    }
}