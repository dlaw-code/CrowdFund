// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract Unpledge is Script {
    function run() external {
        // Required environment variables
        address crowdfundingAddress = vm.envAddress("CROWDFUNDING_ADDRESS");
        uint256 campaignId = vm.envUint("CAMPAIGN_ID");
        uint256 amount = vm.envUint("AMOUNT");

        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddress);

        vm.startBroadcast();

        crowdfunding.unpledge(campaignId, amount);

        vm.stopBroadcast();

        console.log("Unpledge successful!");
        console.log("Campaign ID:", campaignId);
        console.log("Amount unpledged:", amount);
        
    }
}
