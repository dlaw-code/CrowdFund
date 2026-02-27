# 🎯 HOW TO PLEDGE FUNDS TO A CROWDFUNDING CAMPAIGN - Complete Walkthrough

## Overview
Pledging in a crowdfunding protocol involves two main steps:
1. **Approve** - Give the crowdfunding contract permission to spend your ERC20 tokens
2. **Pledge** - Transfer tokens to the crowdfunding contract and record your pledge

---

## 📋 THE CAMPAIGN STRUCTURE

Your campaigns have these properties:
```
Campaign {
  creator: address          // The person who created the campaign
  goal: uint256            // Target amount in tokens (e.g., 100 tokens)
  pledged: uint256         // Total pledged so far
  startAt: uint32          // Unix timestamp when pledging starts
  endAt: uint32            // Unix timestamp when pledging ends
  claimed: bool            // Whether creator has claimed funds
  isFlexibleFunding: bool  // If true, creator can claim even if goal not met
}
```

---

## 🔐 STEP-BY-STEP PLEDGING PROCESS

### STEP 1: CHECK CAMPAIGN STATUS
Before pledging, verify:
- ✅ Campaign exists
- ✅ Campaign has started (`block.timestamp >= campaign.startAt`)
- ✅ Campaign hasn't ended (`block.timestamp <= campaign.endAt`)

Example check:
```javascript
Campaign memory camp = crowdfunding.getCampaign(campaignId);
require(now >= camp.startAt && now <= camp.endAt, "Campaign not active");
```

---

### STEP 2: APPROVE TOKEN TRANSFER (First Time Only Per Amount)

**Why?** ERC20 tokens use an approval pattern for security. You must explicitly authorize the contract to spend your tokens.

**Function:** 
```solidity
IERC20.approve(spender, amount)
```

**What happens:**
- You call `token.approve(CROWDFUNDING_ADDRESS, amount)`
- This sets an allowance for the Crowdfunding contract
- The contract can now transfer up to `amount` tokens from your wallet

**In a Script:**
```solidity
IERC20 token = IERC20(TOKEN_ADDRESS);
token.approve(CROWDFUNDING_ADDRESS, pledgeAmount);
```

**Important:** 
- You only need to approve once if the contract already has enough allowance
- You can approve a high amount (e.g., type(uint256).max) to avoid approving multiple times

---

### STEP 3: PLEDGE TOKENS

**Function:**
```solidity
crowdfunding.pledge(uint256 campaignId, uint256 amount)
```

**What the contract does:**

```solidity
function pledge(uint256 _id, uint256 _amount) external nonReentrant campaignExists(_id) {
    Campaign storage campaign = campaigns[_id];
    
    // ✅ Check 1: Campaign has started
    require(block.timestamp >= campaign.startAt, "not started");
    
    // ✅ Check 2: Campaign hasn't ended
    require(block.timestamp <= campaign.endAt, "already ended");
    
    // ✅ Check 3: Amount > 0
    require(_amount > 0, "amount = 0");
    
    // ✅ Update state: Add to campaign total
    campaign.pledged += _amount;
    
    // ✅ Update state: Record your pledge amount
    pledgedAmount[_id][msg.sender] += _amount;
    
    // ✅ Transfer tokens from YOU to the CONTRACT
    TOKEN.safeTransferFrom(msg.sender, address(this), _amount);
    
    // ✅ Emit event
    emit Pledge(_id, msg.sender, _amount);
}
```

**Flow Diagram:**
```
Your Wallet                    Token Contract              Crowdfunding Contract
    |                               |                            |
    |--- approve(amount) ---------->|                            |
    |                               |                            |
    |--- pledge(id, amount) --------|----transferFrom()--------->|
    |                               |                            |
    |                        [Tokens locked here]
    |
    | Your pledge amount is recorded: pledgedAmount[id][you] = amount
```

---

## 💡 WHAT HAPPENS TO YOUR TOKENS?

1. **While Campaign Active**: Tokens are held in the Crowdfunding contract
2. **You can Unpledge**: Before campaign ends, you can withdraw your tokens
   ```solidity
   crowdfunding.unpledge(campaignId, amount);
   ```

3. **After Campaign Ends - Two Scenarios:**

   **Scenario A: Goal Met (Flexible or Enough Pledged)**
   - Creator calls `claim()` to get funds (minus 5% platform fee)
   - Tokens distributed to creator
   - ❌ Backers cannot get refund

   **Scenario B: Goal NOT Met (Rigid Funding)**
   - Campaign fails
   - Backers can call `refund()` to get their tokens back
   - Creator gets nothing

---

## 🎬 COMPLETE EXAMPLE: PLEDGING 50 TOKENS TO CAMPAIGN 2

### Prerequisites:
- Campaign 2 is active
- You have at least 50 tokens
- Crowdfunding contract: `0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c`
- Token contract: `0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496` (or whichever token it uses)

### Code:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract PledgeExample is Script {
    function run() external {
        address tokenAddr = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
        address crowdAddr = 0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c;
        uint256 campaignId = 2;
        uint256 pledgeAmount = 50 ether; // 50 tokens (assuming 18 decimals)

        IERC20 token = IERC20(tokenAddr);
        Crowdfunding crowdfunding = Crowdfunding(crowdAddr);

        vm.startBroadcast();

        // STEP 1: Approve the contract to spend your tokens
        token.approve(crowdAddr, pledgeAmount);
        
        // STEP 2: Pledge tokens
        crowdfunding.pledge(campaignId, pledgeAmount);

        vm.stopBroadcast();
    }
}
```

### What happens when you run it:
```
✅ Token.approve() - Contract is authorized to transfer up to 50 tokens
✅ Crowdfunding.pledge(2, 50e18) - Your 50 tokens are transferred to the contract
✅ Your pledge is recorded: pledgedAmount[2][yourAddress] = 50e18
✅ Campaign.pledged increases to track total pledges
✅ Pledge event emitted
```

---

## 🔍 VERIFY YOUR PLEDGE

After pledging, you can check your pledge amount:

```solidity
uint256 myPledge = crowdfunding.getPledgedAmount(campaignId, myAddress);
console.log("I pledged:", myPledge / 1e18, "tokens");
```

---

## 📊 STANDARD CROWDFUNDING FLOW (Industry Standard)

This is how most ERC20-based crowdfunding protocols work:

```
CREATOR                          BACKERS                    CONTRACT
   |                               |                            |
   |-- launch(goal, start, end) -->|                            |
   |                               |                            |
   |                          [Campaign Active]                |
   |                               |                            |
   |                          approve() ----------------------->|
   |                          pledge() ----------------------->|
   |                               |    [Tokens locked]         |
   |                          unpledge() (optional)            |
   |                               |                            |
   |                          [Campaign Ends]                  |
   |                               |                            |
   |-- claim() [if goal met] ------|-- distribute funds ------->|
   |                               |    [Creator gets $]        |
   |                               |    [Admin gets 5% fee]     |
   |                               |                            |
   |                               |-- refund() [if goal failed]
   |                               |    [Backers get $ back]    |
```

---

## ⚠️ IMPORTANT SECURITY FEATURES IN YOUR CODE

1. **SafeERC20**: Uses OpenZeppelin's SafeERC20 wrapper for safe token transfers
2. **ReentrancyGuard**: Protects against reentrancy attacks on pledge/unpledge
3. **State validation**: Checks campaign exists, times are correct, amounts > 0
4. **Approval pattern**: Requires separate approve() call (ERC20 standard)

---

## 🎯 KEY TAKEAWAYS

| Step | Function | Purpose |
|------|----------|---------|
| 1 | `approve(contract, amount)` | Authorize contract to spend tokens |
| 2 | `pledge(campaignId, amount)` | Lock tokens in contract & record pledge |
| 3 (optional) | `unpledge(campaignId, amount)` | Withdraw tokens before campaign ends |
| 4 (creator) | `claim(campaignId)` | Claim funds if goal met |
| 4 (backer) | `refund(campaignId)` | Get refund if goal failed |

---

## ❓ COMMON ISSUES

**Issue**: "SafeERC20FailedOperation" error
**Solution**: 
- Make sure you have tokens of the correct address
- Make sure you approved enough amount
- Make sure the campaign contract is using the right token address

**Issue**: "not started" error
**Solution**: Campaign start time hasn't arrived yet

**Issue**: "already ended" error
**Solution**: Campaign end time has passed

**Issue**: "insufficient pledge" error (on unpledge)
**Solution**: You're trying to unpledge more than you pledged

---

This is the standard ERC20 pledging pattern used by Kickstarter-style crowdfunding protocols! 🚀
