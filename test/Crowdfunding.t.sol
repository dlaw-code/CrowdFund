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
    
    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice"); 
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");
    
    uint256 constant PLATFORM_FEE = 5; // 5%
    
    function setUp() public {
        // Deploy mock ERC20 and crowdfunding with token address
        token = new MockERC20("TestToken", "TTK");
        
        // Deploy as admin
        vm.prank(admin);
        crowdfunding = new Crowdfunding(address(token));
        
        // Mint tokens to participants
        token.mint(alice, 100 ether);
        token.mint(bob, 100 ether);
        token.mint(charlie, 100 ether);
        
        // Approve crowdfunding contract to spend tokens
        vm.prank(alice);
        token.approve(address(crowdfunding), type(uint256).max);
        
        vm.prank(bob);
        token.approve(address(crowdfunding), type(uint256).max);
        
        vm.prank(charlie);
        token.approve(address(crowdfunding), type(uint256).max);
    }
    
    function testLaunchCampaign() public {
        uint32 startAt = uint32(block.timestamp + 1 hours);
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
        
        (address creator, uint256 goal, uint256 pledged, uint32 sAt, uint32 eAt, bool claimed, bool isFlexible) = 
            _getCampaignDetails(campaignId);
        
        assertEq(creator, alice);
        assertEq(goal, 10 ether);
        assertEq(pledged, 0);
        assertEq(sAt, startAt);
        assertEq(eAt, endAt);
        assertFalse(claimed);
        assertFalse(isFlexible);
    }
    
    // ... in testPledge function, fix line 105:
function testPledge() public {
    uint32 startAt = uint32(block.timestamp);
    uint32 endAt = startAt + 7 days;
    
    vm.prank(alice);
    uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
    
    uint256 bobBalanceBefore = token.balanceOf(bob);
    uint256 contractBalanceBefore = token.balanceOf(address(crowdfunding));
    
    vm.prank(bob);
    crowdfunding.pledge(campaignId, 3 ether);
    
    // FIXED: Remove unused 'claimed' variable
    (,, uint256 pledged,,,,) = _getCampaignDetails(campaignId);
    assertEq(pledged, 3 ether);
    assertEq(token.balanceOf(bob), bobBalanceBefore - 3 ether);
    assertEq(token.balanceOf(address(crowdfunding)), contractBalanceBefore + 3 ether);
    assertEq(crowdfunding.pledgedAmount(campaignId, bob), 3 ether);
}
    function testUnpledge() public {
        uint32 startAt = uint32(block.timestamp);
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
        
        vm.prank(bob);
        crowdfunding.pledge(campaignId, 5 ether);
        
        uint256 bobBalanceBefore = token.balanceOf(bob);
        
        vm.prank(bob);
        crowdfunding.unpledge(campaignId, 2 ether);
        
        (,, uint256 pledged,,, bool claimed,) = _getCampaignDetails(campaignId);
        assertEq(pledged, 3 ether); // 5 - 2 = 3
        assertEq(crowdfunding.pledgedAmount(campaignId, bob), 3 ether);
        assertEq(token.balanceOf(bob), bobBalanceBefore + 2 ether);
    }
    
    function testClaimSuccessFixedFunding() public {
        uint32 startAt = uint32(block.timestamp);
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
        
        // Multiple backers
        vm.prank(bob);
        crowdfunding.pledge(campaignId, 6 ether);
        
        vm.prank(charlie);
        crowdfunding.pledge(campaignId, 4 ether); // Exactly meets goal
        
        // Fast forward past end time
        vm.warp(endAt + 1);
        
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 adminBalanceBefore = token.balanceOf(admin);
        uint256 contractBalanceBefore = token.balanceOf(address(crowdfunding));
        
        vm.prank(alice);
        crowdfunding.claim(campaignId);
        
        // Check calculations
        uint256 totalRaised = 10 ether;
        uint256 fee = (totalRaised * PLATFORM_FEE) / 100; // 0.5 ether
        uint256 toCreator = totalRaised - fee; // 9.5 ether
        
        assertEq(token.balanceOf(alice), aliceBalanceBefore + toCreator);
        assertEq(token.balanceOf(admin), adminBalanceBefore + fee);
        assertEq(token.balanceOf(address(crowdfunding)), contractBalanceBefore - totalRaised);
        
        // Campaign should be marked as claimed
        (,,, , , bool claimed, ) = _getCampaignDetails(campaignId);
        assertTrue(claimed);
    }
    
    function testClaimFlexibleFunding() public {
        uint32 startAt = uint32(block.timestamp);
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, true); // Flexible!
        
        vm.prank(bob);
        crowdfunding.pledge(campaignId, 5 ether); // Only half the goal
        
        vm.warp(endAt + 1);
        
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        
        vm.prank(alice);
        crowdfunding.claim(campaignId); // Should succeed even though goal not met
        
        uint256 totalRaised = 5 ether;
        uint256 fee = (totalRaised * PLATFORM_FEE) / 100; // 0.25 ether
        uint256 toCreator = totalRaised - fee; // 4.75 ether
        
        assertEq(token.balanceOf(alice), aliceBalanceBefore + toCreator);
    }
    
    function testRefundFixedFundingFailed() public {
        uint32 startAt = uint32(block.timestamp);
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
        
        vm.prank(bob);
        crowdfunding.pledge(campaignId, 5 ether); // Half the goal
        
        vm.warp(endAt + 1);
        
        uint256 bobBalanceBefore = token.balanceOf(bob);
        uint256 contractBalanceBefore = token.balanceOf(address(crowdfunding));
        
        vm.prank(bob);
        crowdfunding.refund(campaignId);
        
        assertEq(token.balanceOf(bob), bobBalanceBefore + 5 ether);
        assertEq(token.balanceOf(address(crowdfunding)), contractBalanceBefore - 5 ether);
        assertEq(crowdfunding.pledgedAmount(campaignId, bob), 0);
    }
    
    function testCancelBeforeStart() public {
        uint32 startAt = uint32(block.timestamp + 1 days); // Starts tomorrow
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
        
        vm.prank(alice);
        crowdfunding.cancel(campaignId);
        
        // Campaign should be deleted
        (address creator,,,,,,) = _getCampaignDetails(campaignId);
        assertEq(creator, address(0));
    }
    
    function test_RevertWhen_CancelAfterStart() public {
        uint32 startAt = uint32(block.timestamp); // Starts now
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
        
        vm.prank(alice);
        vm.expectRevert(bytes("already started"));
        crowdfunding.cancel(campaignId); // Should revert
    }
    
    function test_RevertWhen_PledgeBeforeStart() public {
        uint32 startAt = uint32(block.timestamp + 1 hours); // Starts in 1 hour
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
        
        vm.prank(bob);
        vm.expectRevert(bytes("not started"));
        crowdfunding.pledge(campaignId, 1 ether); // Should revert
    }
    
    function test_RevertWhen_ClaimBeforeEnd() public {
        uint32 startAt = uint32(block.timestamp);
        uint32 endAt = startAt + 7 days;
        
        vm.prank(alice);
        uint256 campaignId = crowdfunding.launch(10 ether, startAt, endAt, false);
        
        vm.prank(bob);
        crowdfunding.pledge(campaignId, 10 ether);
        
        vm.prank(alice);
        vm.expectRevert(bytes("not ended"));
        crowdfunding.claim(campaignId); // Should revert - not ended yet
    }
    
    // Helper function to get campaign details
    function _getCampaignDetails(uint256 campaignId) 
        internal 
        view 
        returns (
            address creator,
            uint256 goal,
            uint256 pledged,
            uint32 startAt,
            uint32 endAt,
            bool claimed,
            bool isFlexible
        ) 
    {
        Crowdfunding.Campaign memory campaign = crowdfunding.getCampaign(campaignId);
        return (
            campaign.creator,
            campaign.goal,
            campaign.pledged,
            campaign.startAt,
            campaign.endAt,
            campaign.claimed,
            campaign.isFlexibleFunding
        );
    }
}