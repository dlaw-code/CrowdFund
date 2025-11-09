// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ICrowdfunding} from "src/interfaces/ICrowdfunding.sol";

contract Crowdfunding is ReentrancyGuard, ICrowdfunding {
    using SafeERC20 for IERC20;
    IERC20 public token;
    uint256 public platformFeePercentage = 5; // 5% fee
    address public admin;                
    uint256 private _campaignIdCounter;  

    mapping(uint256 => Campaign) private _campaigns;
    mapping(uint256 => mapping(address => uint256)) private _contributions;

    constructor(address _tokenAddress) {
        admin = msg.sender;  
        token = IERC20(_tokenAddress);  
    }        
    

    modifier onlyCreator(uint256 campaignId) {
        _onlyCreator(campaignId);
        _;
    }

    
    function _onlyCreator(uint256 campaignId) internal view {
        require(_campaigns[campaignId].creator == msg.sender, "Not creator");
    }

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    function _onlyAdmin() internal view {
        require(msg.sender == admin, "Not admin");
    }

   
    function createCampaign(uint256 goal, uint256 duration, bool isFlexibleFunding)
        external
        returns (uint256 campaignId)
    {
        require(goal > 0, "Goal must be positive");
        require(duration > 0, "Duration must be positive");
        
    
        _campaignIdCounter++;
        campaignId = _campaignIdCounter;              

        _campaigns[campaignId] = Campaign({
            creator: msg.sender,
            goal: goal,
            totalFunds: 0,
            endTime: block.timestamp + duration,
            isActive: true,
            isFlexibleFunding: isFlexibleFunding
        });



        emit CampaignCreated(campaignId, msg.sender, goal, block.timestamp + duration);
    }

   function contribute(uint256 campaignId, uint256 amount) external nonReentrant {
    Campaign storage campaign = _campaigns[campaignId];
    require(campaign.isActive, "Campaign inactive");
    require(block.timestamp < campaign.endTime, "Campaign ended");
    require(amount > 0, "Amount must be > 0");

    // Ensure the sender has approved at least `amount` to this contract
    require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");

    // Use SafeERC20 to handle tokens that don't return a bool
    token.safeTransferFrom(msg.sender, address(this), amount);

    // Update state and emit event
    campaign.totalFunds += amount;
    _contributions[campaignId][msg.sender] += amount;
    emit ContributionReceived(campaignId, msg.sender, amount);
}
function claimFunds(uint256 campaignId) external override {
    Campaign storage campaign = _campaigns[campaignId];
    require(block.timestamp >= campaign.endTime, "Campaign not ended");
    require(campaign.totalFunds >= campaign.goal || campaign.isFlexibleFunding, "Goal not met");
    
    campaign.isActive = false;
    
    // Calculate fee and creator amount in tokens
    uint256 fee = (campaign.totalFunds * platformFeePercentage) / 100;
    uint256 amountToCreator = campaign.totalFunds - fee;
    
    // Transfer tokens to admin and creator using safe transfers
    token.safeTransfer(admin, fee);
    token.safeTransfer(campaign.creator, amountToCreator);
    
    emit FundsClaimed(campaignId, campaign.creator, amountToCreator);
}







function refund(uint256 campaignId) external nonReentrant {
    Campaign storage campaign = _campaigns[campaignId];
    require(block.timestamp >= campaign.endTime, "Campaign not ended");
    require(campaign.totalFunds < campaign.goal && !campaign.isFlexibleFunding, "Goal met or flexible");
    
    campaign.isActive = false;
    uint256 contribution = _contributions[campaignId][msg.sender];
    require(contribution > 0, "No contribution");
    
    _contributions[campaignId][msg.sender] = 0;
    token.safeTransfer(msg.sender, contribution);
    
    emit RefundIssued(campaignId, msg.sender, contribution);
}

    function getCampaign(uint256 campaignId) external view override returns (Campaign memory) {
        return _campaigns[campaignId];
    }

    function setPlatformFee(uint256 feePercentage) external onlyAdmin {
        require(feePercentage < 20, "Fee too high");
        platformFeePercentage = feePercentage;
    }

    
}
