// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract Interact is Script {
    function run() external {
        vm.startBroadcast();
        Crowdfunding crowdfunding = Crowdfunding(payable(msg.sender));
        crowdfunding.createCampaign(1 ether, 7 days, false);
        vm.stopBroadcast();
    }
}
