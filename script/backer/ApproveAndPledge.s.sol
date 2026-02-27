// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract ApproveAndPledge is Script {
    function run() external {
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address crowdfundingAddress = vm.envAddress("CROWDFUNDING_ADDRESS");
        uint256 campaignId = vm.envUint("CAMPAIGN_ID");
        uint256 amount = vm.envUint("AMOUNT");

        IERC20 token = IERC20(tokenAddress);
        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddress);

        vm.startBroadcast();

        // Approve the crowdfunding contract to spend tokens, then pledge
        token.approve(crowdfundingAddress, amount);
        crowdfunding.pledge(campaignId, amount);

        vm.stopBroadcast();

        console.log("Approve + Pledge completed");
        console.log("Campaign ID:", campaignId);
        console.log("Amount:", amount);
    }
}
