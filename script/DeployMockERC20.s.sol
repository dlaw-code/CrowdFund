// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {MockERC20} from "test/mocks/MockERC20.sol";

contract DeployMockERC20 is Script {
    function run() external returns (address token) {
        vm.startBroadcast();

        MockERC20 mock = new MockERC20(
            "Mock USD",
            "mUSD"
        );

        token = address(mock);

        console.log("MockERC20 deployed at:", token);

        vm.stopBroadcast();
    }
}
