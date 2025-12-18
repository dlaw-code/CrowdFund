// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {MockERC20} from "test/mocks/MockERC20.sol";

contract DeployCrowdfunding is Script {
    struct DeployConfig {
        address tokenAddress;
        bool deployMockToken;
    }

    // Changed to view since we're not modifying state
    function getConfig() internal view returns (DeployConfig memory) {
        address tokenAddress = address(0);
        bool deployMock = true;

        try vm.envString("TOKEN_ADDRESS") returns (string memory tokenStr) {
            if (bytes(tokenStr).length > 0) {
                tokenAddress = vm.parseAddress(tokenStr);
                deployMock = false;
                console.log("Using existing token from env:", tokenAddress);
            }
        } catch {
            // If env var doesn't exist, deploy mock
            deployMock = true;
        }

        return DeployConfig({
            tokenAddress: tokenAddress,
            deployMockToken: deployMock
        });
    }

    function run() external returns (Crowdfunding crowdfunding, address tokenAddress) {
        DeployConfig memory config = getConfig();
        tokenAddress = config.tokenAddress;

        vm.startBroadcast();

        // Deploy mock token if needed
        if (config.deployMockToken) {
            MockERC20 token = new MockERC20("Test Token", "TEST");
            tokenAddress = address(token);
            console.log("Deployed Mock Token at:", tokenAddress);
        }

        // Deploy Crowdfunding with token address
        crowdfunding = new Crowdfunding(tokenAddress);
        console.log("Deployed Crowdfunding at:", address(crowdfunding));

        // Mint tokens to deployer if using mock
        if (config.deployMockToken) {
            MockERC20 mockToken = MockERC20(tokenAddress);
            mockToken.mint(msg.sender, 1000000 ether);
            console.log("Minted 1M TEST tokens to deployer:", msg.sender);
            
            // Also approve the crowdfunding contract to spend deployer's tokens
            mockToken.approve(address(crowdfunding), type(uint256).max);
            console.log("Approved Crowdfunding to spend deployer's tokens");
        }

        vm.stopBroadcast();
    }
}