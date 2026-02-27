// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract LaunchCampaign is Script {
    function run() external {
        // Required: deployed crowdfunding contract
        address crowdfundingAddress = vm.envAddress("CROWDFUNDING_ADDRESS");
        
        // Optional inputs (can also hardcode while testing)
        uint256 goal = vm.envUint("GOAL"); // e.g. 100 ether
        uint32 startAt = uint32(vm.envUint("START_AT"));
        uint32 endAt = uint32(vm.envUint("END_AT"));
        bool isFlexibleFunding = vm.envBool("FLEXIBLE");

        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddress);

        vm.startBroadcast();

        uint256 campaignId = crowdfunding.launch(
            goal,
            startAt,
            endAt,
            isFlexibleFunding
        );

        vm.stopBroadcast();

        console.log("Campaign launched!");
        console.log("Campaign ID:", campaignId);
    }
}
