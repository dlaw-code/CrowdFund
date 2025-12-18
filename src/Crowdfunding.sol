// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ICrowdfunding} from "src/interfaces/ICrowdfunding.sol";

contract Crowdfunding is ReentrancyGuard, ICrowdfunding {
    using SafeERC20 for IERC20;
    
    IERC20 public immutable TOKEN;
    address public admin;
    uint256 public platformFeePercentage = 5; // 5% fee
    uint256 public count;
    
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;
    
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);
    
    constructor(address _token) {  
        TOKEN = IERC20(_token);
        admin = msg.sender;
    }
    
    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }
    
    function _onlyAdmin() internal view {
        require(msg.sender == admin, "Not admin");
    }
    
    modifier campaignExists(uint256 _id) {
        _campaignExists(_id);
        _;
    }
    
    function _campaignExists(uint256 _id) internal view {
        require(campaigns[_id].creator != address(0), "Campaign not exist");
    }
    
    function launch(
        uint256 _goal,
        uint32 _startAt,
        uint32 _endAt,
        bool _isFlexibleFunding
    ) external returns (uint256 campaignId) {
        require(_goal > 0, "Goal must be > 0");
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt > _startAt, "end at <= start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");
        
        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false,
            isFlexibleFunding: _isFlexibleFunding
        });
        
        emit Launch(count, msg.sender, _goal, _startAt, _endAt, _isFlexibleFunding);
        return count;
    }
    
    function cancel(uint256 _id) external campaignExists(_id) {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator");
        require(block.timestamp < campaign.startAt, "already started");
        require(campaign.pledged == 0, "already has pledges");
        
        delete campaigns[_id];
        emit Cancel(_id);
    }
    
    function pledge(uint256 _id, uint256 _amount) external nonReentrant campaignExists(_id) {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "already ended");
        require(_amount > 0, "amount = 0");
        
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        
        TOKEN.safeTransferFrom(msg.sender, address(this), _amount);
        emit Pledge(_id, msg.sender, _amount);
    }
    
    function unpledge(uint256 _id, uint256 _amount) external nonReentrant campaignExists(_id) {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "already ended");
        require(pledgedAmount[_id][msg.sender] >= _amount, "insufficient pledge");
        require(_amount > 0, "amount = 0");
        
        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        
        TOKEN.safeTransfer(msg.sender, _amount);
        emit Unpledge(_id, msg.sender, _amount);
    }
    
    function claim(uint256 _id) external nonReentrant campaignExists(_id) {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal || campaign.isFlexibleFunding, "goal not met");
        require(!campaign.claimed, "already claimed");
        
        campaign.claimed = true;
        uint256 totalAmount = campaign.pledged;
        
        uint256 fee = (totalAmount * platformFeePercentage) / 100;
        uint256 amountToCreator = totalAmount - fee;
        
        campaign.pledged = 0; // Prevent reentrancy
        
        if (fee > 0) {
            TOKEN.safeTransfer(admin, fee);
        }
        TOKEN.safeTransfer(campaign.creator, amountToCreator);
        
        emit Claim(_id, amountToCreator, fee);
    }
    
    function refund(uint256 _id) external nonReentrant campaignExists(_id) {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal && !campaign.isFlexibleFunding, "no refund available");
        require(!campaign.claimed, "already claimed");
        
        uint256 bal = pledgedAmount[_id][msg.sender];
        require(bal > 0, "no pledge to refund");
        
        pledgedAmount[_id][msg.sender] = 0;
        TOKEN.safeTransfer(msg.sender, bal);
        
        emit Refund(_id, msg.sender, bal);
    }
    
    function getCampaign(uint256 _id) external view override returns (Campaign memory) {
        return campaigns[_id];
    }
    
    function getPledgedAmount(uint256 _id, address _backer) external view returns (uint256) {
        return pledgedAmount[_id][_backer];
    }
    
    function setPlatformFee(uint256 _feePercentage) external onlyAdmin {
        require(_feePercentage < 20, "Fee too high");
        platformFeePercentage = _feePercentage;
    }
    
    function transferAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        emit AdminUpdated(admin, _newAdmin);
        admin = _newAdmin;
    }
}