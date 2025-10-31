// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test} from "forge-std/Test.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract CrowdfundingTest is Test {
    Crowdfunding public crowdfunding;
    address public alice = makeAddr("alice"); 
    address public bob = makeAddr("bob");     

    
    receive() external payable {}

    function setUp() public {
        crowdfunding = new Crowdfunding();
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
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
        crowdfunding.contribute{value: 0.5 ether}(campaignId);
        assertEq(crowdfunding.getCampaign(campaignId).totalFunds, 0.5 ether);
    }

    function testClaimFundsSuccess() public {
        vm.prank(alice);
        uint256 campaignId = crowdfunding.createCampaign(1 ether, 1 days, false);
        
        vm.prank(bob);
        crowdfunding.contribute{value: 1 ether}(campaignId);

        vm.warp(block.timestamp + 1 days + 1);

        // Store balances before claim
        uint256 initialAliceBalance = alice.balance;
        uint256 initialAdminBalance = address(this).balance;

        vm.prank(alice);
        crowdfunding.claimFunds(campaignId);

        // Check that Alice received 0.95 ETH
        assertEq(alice.balance, initialAliceBalance + 0.95 ether);
        // Check that admin (test contract) received 0.05 ETH
        assertEq(address(this).balance, initialAdminBalance + 0.05 ether);
        // Check that crowdfunding contract balance is 0
        assertEq(address(crowdfunding).balance, 0);
    }

    function testRefund() public {
        vm.prank(alice);
        uint256 campaignId = crowdfunding.createCampaign(2 ether, 1 days, false);
        vm.prank(bob);
        crowdfunding.contribute{value: 1 ether}(campaignId);
        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(bob);
        crowdfunding.refund(campaignId);
        assertEq(address(crowdfunding).balance, 0);
    }
}