// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";  // ← Add this import

contract Interact is Script {
    function run() external {
        // ── Environment variables ────────────────────────────────────────
        address crowdfundingAddr = vm.envAddress("CROWDFUNDING_ADDRESS");
        address tokenAddr        = vm.envAddress("TOKEN_ADDRESS");          // ← You MUST add this to your .env

        uint256 goal    = vm.envUint("GOAL");
        uint256 startAt = vm.envUint("START_AT");
        uint256 endAt   = vm.envUint("END_AT");
        bool flexible   = vm.envBool("FLEXIBLE");

        uint256 amount     = vm.envUint("AMOUNT");
        uint256 campaignId = vm.envUint("CAMPAIGN_ID");                     // or use the new id below

        vm.startBroadcast();

        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddr);
        IERC20 token = IERC20(tokenAddr);                                   // ← Interface to the token

        // ── VERY IMPORTANT: Approve BEFORE pledge ────────────────────────
        // Option 1: Approve exactly what you're going to pledge
        token.approve(crowdfundingAddr, amount);

        // Option 2: Approve a very large amount once (common in tests)
        // token.approve(crowdfundingAddr, type(uint256).max);

        console.log("Approved %s tokens for Crowdfunding contract", amount);

        // ── Launch new campaign (your original code) ─────────────────────
        uint256 id = crowdfunding.launch(
            goal,
            uint32(startAt),
            uint32(endAt),
            flexible
        );

        console.log("Campaign launched:", id);

        // ── Pledge ───────────────────────────────────────────────────────
        // Choose ONE of the next two lines:

        // A) If you want to pledge to an EXISTING campaign (your original intent?)
        crowdfunding.pledge(campaignId, amount);

        // B) If you want to pledge to the campaign you JUST created (more logical for testing full flow)
        // crowdfunding.pledge(id, amount);

        console.log("Pledged: %s to campaign %s", amount, campaignId);     // adjust log if using id

        vm.stopBroadcast();
    }
}