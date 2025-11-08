// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";
import {MockERC20} from "test/mocks/MockERC20.sol";

contract DeployCrowdfunding is Script {
    // Config for different environments
    struct DeployConfig {
        address tokenAddress;
        bool deployMockToken;
    }

    function getConfig() internal returns (DeployConfig memory) {
        // If a TOKEN_ADDRESS env var is provided, use it; otherwise deploy a mock token.
        // This makes the script automatically deploy a MockERC20 when TOKEN_ADDRESS is not set.
        address tokenAddress = address(0);
        bool deployMock = true;

        // Try to read TOKEN_ADDRESS from the environment. If not present, vm.envString may revert;
        // we catch that and fall back to deploying a mock token.
        try vm.envString("TOKEN_ADDRESS") returns (string memory tokenStr) {
            // If the string is non-empty, parse into address and use it
            if (bytes(tokenStr).length > 0) {
                tokenAddress = vm.parseAddress(tokenStr);
                deployMock = false;
            }
        } catch {
            // env var not set or parsing failed — deploy mock token
            deployMock = true;
        }

        return DeployConfig({
            tokenAddress: tokenAddress,
            deployMockToken: deployMock
        });
    }

    function run() external returns (Crowdfunding, address) {
        DeployConfig memory config = getConfig();
        address tokenAddress = config.tokenAddress;

        vm.startBroadcast();

        // Deploy mock token for test environments
        if (config.deployMockToken) {
            MockERC20 token = new MockERC20("Test Token", "TEST");
            tokenAddress = address(token);
            console.log("Deployed Mock Token at:", tokenAddress);
        }

        // Deploy Crowdfunding with token address
        Crowdfunding crowdfunding = new Crowdfunding(tokenAddress);
        console.log("Deployed Crowdfunding at:", address(crowdfunding));

        // For test environments, mint some tokens to deployer
        if (config.deployMockToken) {
            MockERC20(tokenAddress).mint(msg.sender, 1000000 ether);
            console.log("Minted 1M TEST tokens to deployer:", msg.sender);
        }

        vm.stopBroadcast();
        return (crowdfunding, tokenAddress);
    }
}
