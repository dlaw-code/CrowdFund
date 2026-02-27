// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract PledgeCampaign2 is Script {
    function run() external {
        // Note: The Crowdfunding contract at 0x60E7D551... uses a different token than the MockERC20 we deployed
        // The error shows it's trying to use token at 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        // For now, using environment variables to set these addresses
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address crowdfundingAddress = vm.envAddress("CROWDFUNDING_ADDRESS");
        uint256 campaignId = vm.envUint("CAMPAIGN_ID");
        uint256 amount = vm.envUint("PLEDGE_AMOUNT");

        IERC20 token = IERC20(tokenAddress);
        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddress);

        vm.startBroadcast();

        // Approve the crowdfunding contract to spend tokens
        console.log("Approving tokens...");
        token.approve(crowdfundingAddress, amount);

        // Pledge to campaign 2
        console.log("Pledging to campaign 2...");
        crowdfunding.pledge(campaignId, amount);

        vm.stopBroadcast();

        console.log("=== PLEDGE SUCCESSFUL ===");
        console.log("Campaign ID:", campaignId);
        console.log("Amount pledged:", amount / 1e18, "tokens");
        console.log("Token address:", tokenAddress);
        console.log("Crowdfunding address:", crowdfundingAddress);
    }
}
