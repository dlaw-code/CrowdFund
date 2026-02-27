// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Pledge is Script {
    function run() external {
        // Required inputs
        address crowdfundingAddress = vm.envAddress("CROWDFUNDING_ADDRESS");
        uint256 campaignId = vm.envUint("CAMPAIGN_ID");
        uint256 amount = vm.envUint("AMOUNT");

        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddress);

        vm.startBroadcast();

        // Pledge tokens to campaign
        crowdfunding.pledge(campaignId, amount);

        vm.stopBroadcast();

        console.log("Pledge successful!");
        console.log("Campaign ID:", campaignId);
        console.log("Amount pledged:", amount);
    }
}
