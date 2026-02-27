// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract ClaimFunds is Script {
    function run() external {
        // Required environment variables
        address crowdfundingAddress = vm.envAddress("CROWDFUNDING_ADDRESS");
        uint256 campaignId = vm.envUint("CAMPAIGN_ID");

        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddress);

        vm.startBroadcast();

        crowdfunding.claim(campaignId);

        vm.stopBroadcast();

        console.log("Funds claimed successfully!");
        console.log("Campaign ID:", campaignId);
    }
}
