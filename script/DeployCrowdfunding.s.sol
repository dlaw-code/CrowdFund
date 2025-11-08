// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract DeployCrowdfunding is Script {
    function run() external returns (Crowdfunding) {
        vm.startBroadcast();
        Crowdfunding crowdfunding = new Crowdfunding();
        vm.stopBroadcast();
        return crowdfunding;
    }
}
