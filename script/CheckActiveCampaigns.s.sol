// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {ICrowdfunding} from "src/interfaces/ICrowdfunding.sol";

contract CheckActiveCampaigns is Script {
    function run() external view {
        address crowdfundingAddr = vm.envAddress("CROWDFUNDING_ADDRESS");
        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddr);

        uint256 totalCampaigns = crowdfunding.count();
        uint256 currentTime = block.timestamp;

        console.log("========================================");
        console.log("CHECKING ACTIVE CAMPAIGNS");
        console.log("========================================");
        console.log("Crowdfunding Contract:");
        console.logAddress(crowdfundingAddr);
        console.log("Total Campaigns:");
        console.log(totalCampaigns);
        console.log("Current Time:");
        console.log(currentTime);
        console.log("");

        if (totalCampaigns == 0) {
            console.log("No campaigns found!");
            return;
        }

        uint256 activeCount = 0;

        for (uint256 i = 1; i <= totalCampaigns; i++) {
            ICrowdfunding.Campaign memory campaign = crowdfunding.getCampaign(i);

            // Check if campaign exists (creator != address(0))
            if (campaign.creator == address(0)) {
                continue; // Campaign doesn't exist (might have been cancelled)
            }

            // Check if campaign is active: started and not ended
            bool isActive = currentTime >= campaign.startAt && currentTime <= campaign.endAt;
            bool hasStarted = currentTime >= campaign.startAt;
            bool hasEnded = currentTime > campaign.endAt;

            if (isActive) {
                activeCount++;
                console.log("----------------------------------------");
                console.log("ACTIVE CAMPAIGN #");
                console.log(i);
                console.log("----------------------------------------");
                console.log("Creator:");
                console.logAddress(campaign.creator);
                console.log("Goal (tokens):");
                console.log(campaign.goal / 1e18);
                console.log("Pledged (tokens):");
                console.log(campaign.pledged / 1e18);
                console.log("Progress (%):");
                console.log((campaign.pledged * 100) / campaign.goal);
                console.log("Start Time:");
                console.log(campaign.startAt);
                console.log("End Time:");
                console.log(campaign.endAt);
                uint256 timeRemaining = campaign.endAt > currentTime ? campaign.endAt - currentTime : 0;
                console.log("Time Remaining (seconds):");
                console.log(timeRemaining);
                console.log("Days Remaining:");
                console.log(timeRemaining / 86400);
                console.log("Flexible Funding:");
                console.log(campaign.isFlexibleFunding);
                console.log("Claimed:");
                console.log(campaign.claimed);
                console.log("Status: ACTIVE - Ready to pledge!");
                console.log("");
            } else if (hasStarted && !hasEnded) {
                // This shouldn't happen if isActive is false, but just in case
                console.log("Campaign #");
                console.log(i);
                console.log("- Edge case detected");
            } else if (!hasStarted) {
                console.log("Campaign #");
                console.log(i);
                console.log("- Not started yet (starts at:");
                console.log(campaign.startAt);
                console.log(")");
            } else if (hasEnded) {
                console.log("Campaign #");
                console.log(i);
                console.log("- EXPIRED (ended at:");
                console.log(campaign.endAt);
                console.log(")");
                if (campaign.claimed) {
                    console.log("  -> Funds claimed by creator");
                } else if (campaign.pledged >= campaign.goal || campaign.isFlexibleFunding) {
                    console.log("  -> Goal met - Creator can claim");
                } else {
                    console.log("  -> Goal not met - Backers can refund");
                }
            }
        }

        console.log("========================================");
        console.log("SUMMARY");
        console.log("========================================");
        console.log("Total Campaigns:");
        console.log(totalCampaigns);
        console.log("Active Campaigns:");
        console.log(activeCount);
        console.log("");

        if (activeCount == 0) {
            console.log("No active campaigns found. All campaigns have expired or not started yet.");
        } else {
            console.log("You can pledge to");
            console.log(activeCount);
            console.log("active campaign(s)! Use the campaign IDs shown above.");
        }
    }
}
