// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {MockERC20} from "test/mocks/MockERC20.sol";

contract Interact is Script {
    function run() external returns (address crowdfundingAddr, address tokenAddr) {
        // Read optional environment variables
        string memory cfEnv = vm.envString("CROWDFUNDING_ADDRESS");
        string memory tkEnv = vm.envString("TOKEN_ADDRESS");

        address crowdfundingAddress = address(0);
        address tokenAddress = address(0);

        vm.startBroadcast();

        if (bytes(cfEnv).length > 0) {
            crowdfundingAddress = vm.parseAddress(cfEnv);
            console.log("Using existing Crowdfunding at:", crowdfundingAddress);
        } else {
            // Deploy a mock token and crowdfunding locally
            MockERC20 token = new MockERC20("Test Token", "TTK");
            tokenAddress = address(token);
            console.log("Deployed MockERC20 at:", tokenAddress);

            Crowdfunding cf = new Crowdfunding(tokenAddress);
            crowdfundingAddress = address(cf);
            console.log("Deployed Crowdfunding at:", crowdfundingAddress);

            // Mint some tokens to deployer and approve the crowdfunding contract
            token.mint(msg.sender, 1000 ether);
            token.approve(crowdfundingAddress, type(uint256).max);
            console.log("Minted tokens and approved Crowdfunding for deployer:", msg.sender);
        }

        // If token env var provided and tokenAddress not set yet, use it
        if (tokenAddress == address(0) && bytes(tkEnv).length > 0) {
            tokenAddress = vm.parseAddress(tkEnv);
            console.log("Using token address from env:", tokenAddress);
        }

        Crowdfunding crowdfunding = Crowdfunding(crowdfundingAddress);

        // Create a campaign (creator is the broadcast sender)
        uint256 campaignId = crowdfunding.createCampaign(1 ether, 7 days, false);
        console.log("Created campaign id:", campaignId);

        // Contribute (assumes approval already done if using mock)
        uint256 contributionAmount = 0.1 ether;
        crowdfunding.contribute(campaignId, contributionAmount);
        console.log("Contributed", contributionAmount, "to campaign", campaignId);

        vm.stopBroadcast();
        return (crowdfundingAddress, tokenAddress);
    }
}


