// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdfundingErrors {
    error Unauthorized();
    error DeadlineExceeded();
    error WithdrawalNotAllowed();
    error RefundNotAllowed();
    error InvalidDeadline();
    error EmptyContribution();
    error Overflow();
}