// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface ICrowdfunding {
    struct Campaign {
        address creator;
        uint256 goal;
        uint256 pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
        bool isFlexibleFunding;
    }

    event Launch(uint256 id, address indexed creator, uint256 goal, uint32 startAt, uint32 endAt, bool isFlexible);
    event Cancel(uint256 id);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Unpledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id, uint256 amount, uint256 fee);
    event Refund(uint256 id, address indexed caller, uint256 amount);

    function launch(
        uint256 goal,
        uint32 startAt,
        uint32 endAt,
        bool isFlexibleFunding
    ) external returns (uint256 campaignId);

    function cancel(uint256 campaignId) external;
    
    function pledge(uint256 campaignId, uint256 amount) external;

    function unpledge(uint256 campaignId, uint256 amount) external;

    function claim(uint256 campaignId) external; // Try convert this to C# class to check

    function refund(uint256 campaignId) external; // Try convert this to C# class to check

    function getCampaign(uint256 campaignId) external view returns (Campaign memory);
    
    function setPlatformFee(uint256 feePercentage) external;
    
    function getPledgedAmount(uint256 campaignId, address backer) external view returns (uint256);
}