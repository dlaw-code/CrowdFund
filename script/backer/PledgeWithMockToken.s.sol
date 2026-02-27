// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract PledgeWithMockToken is Script {
    function run() external {
        // Using the OLD Crowdfunding contract that was initialized with MockERC20
        address tokenAddress = 0xf0E24f4437c40c247e34403b8A727E9bb28646Aa; // MockERC20
        address crowdfundingAddress = 0x0fcD5851717194C93E6696936dd4432bfDe6BAFc; // OLD Crowdfunding
        uint256 campaignId = 1; // Campaign 1 from old contract
        uint256 amount = 10 ether; // 10 tokens

        IERC20 token = IERC20(tokenAddress);
        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddress);

        vm.startBroadcast();

        // Approve the crowdfunding contract to spend tokens
        console.log("Approving 10 tokens from MockERC20...");
        token.approve(crowdfundingAddress, amount);

        // Pledge to campaign
        console.log("Pledging to campaign...");
        crowdfunding.pledge(campaignId, amount);

        vm.stopBroadcast();

        console.log("=== PLEDGE SUCCESSFUL ===");
        console.log("Campaign ID:", campaignId);
        console.log("Amount pledged:", amount / 1e18, "tokens");
        console.log("Token:", tokenAddress);
        console.log("Crowdfunding:", crowdfundingAddress);
    }
}
