// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface ICrowdfunding {
    struct Campaign {
        address creator;
        uint256 goal;
        uint256 totalFunds;
        uint256 endTime;
        bool isActive;
        bool isFlexibleFunding;
    }

    event CampaignCreated(uint256 indexed campaignId, address indexed creator, uint256 goal, uint256 endTime);
    event ContributionReceived(uint256 indexed campaignId, address indexed backer, uint256 amount);
    event FundsClaimed(uint256 indexed campaignId, address indexed creator, uint256 amount);
    event RefundIssued(uint256 indexed campaignId, address indexed backer, uint256 amount);

    function createCampaign(
        uint256 goal,
        uint256 duration,
        bool isFlexibleFunding
    ) external returns (uint256 campaignId);

    function contribute(uint256 campaignId) external payable;

    function claimFunds(uint256 campaignId) external;

    function refund(uint256 campaignId) external;

    function getCampaign(uint256 campaignId) external view returns (Campaign memory);
}
