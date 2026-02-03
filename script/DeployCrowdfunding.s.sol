// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract DeployCrowdfunding is Script {
    function run() external returns (address crowdfunding) {
        // Require token address to be provided
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        
        console.log("Deploying Crowdfunding with token:", tokenAddress);

        vm.startBroadcast();

        Crowdfunding cf = new Crowdfunding(tokenAddress);
        crowdfunding = address(cf);
        
        console.log("Deployed Crowdfunding at:", crowdfunding);
        console.log("Admin:", msg.sender);

        vm.stopBroadcast();

        return crowdfunding;
    }
}