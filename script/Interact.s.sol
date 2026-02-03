// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract Interact is Script {
    function run() external {
        address crowdfundingAddr = vm.envAddress("CROWDFUNDING_ADDRESS");

        uint256 goal = vm.envUint("GOAL");
        uint256 startAt = vm.envUint("START_AT");
        uint256 endAt = vm.envUint("END_AT");
        bool flexible = vm.envBool("FLEXIBLE");

        uint256 amount = vm.envUint("AMOUNT");
        uint256 campaignId = vm.envUint("CAMPAIGN_ID");

        vm.startBroadcast();

        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddr);

        uint256 id = crowdfunding.launch(
            goal,
            uint32(startAt),
            uint32(endAt),
            flexible
        );

        console.log("Campaign launched:", id);

        crowdfunding.pledge(campaignId, amount);
        console.log("Pledged:", amount);

        vm.stopBroadcast();
    }
}
