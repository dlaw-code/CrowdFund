# 🚀 QUICK REFERENCE: PLEDGE CHECKLIST & COMMANDS

## ⚡ 60-SECOND VERSION

**The two-step pledging process:**

```solidity
// STEP 1: Approve (on Token contract)
token.approve(crowdfunding, amount)

// STEP 2: Pledge (on Crowdfunding contract)  
crowdfunding.pledge(campaignId, amount)
```

Done! Your tokens are now locked in the campaign.

---

## ✅ PRE-PLEDGE CHECKLIST

- [ ] Campaign is active (Jan 8 - Jan 18 for Campaign 2)
- [ ] I have the correct token: `0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496`
- [ ] My token balance ≥ pledging amount
- [ ] I have ETH for gas (~0.02 ETH)
- [ ] Crowdfunding address: `0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c`
- [ ] Campaign ID: `2` (or 3, 4 if preferred)
- [ ] Pledging amount: e.g., `10 ether` (10 tokens)

**All checked? ✅ Proceed!**

---

## 🎯 METHOD 1: Via Script (Recommended)

```bash
# 1. Create/edit your pledge script at:
# script/backer/PledgeScript.s.sol

# 2. Update with correct values:
address tokenAddress = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
address crowdfundingAddress = 0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c;
uint256 campaignId = 2;
uint256 pledgeAmount = 10 ether;

# 3. Run the script:
cd /home/dlawnoni/crowdfund
source .env
forge script script/backer/YourScript.s.sol \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  -vvv
```

**Status codes:**
- `✅ SUCCESS` - Transactions sent!
- `❌ ERROR` - Check the error message in the guide

---

## 🎯 METHOD 2: Via Etherscan (Manual)

**Transaction 1: Approve**
1. Go to: `https://sepolia.etherscan.io/address/0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496#writeContract`
2. Click "Connect Wallet"
3. Find `approve` function
4. Fill in:
   - spender: `0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c`
   - amount: `10000000000000000000` (10 tokens)
5. Click "Write" → Confirm in MetaMask
6. Wait for confirmation

**Transaction 2: Pledge**
1. Go to: `https://sepolia.etherscan.io/address/0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c#writeContract`
2. Click "Connect Wallet"
3. Find `pledge` function
4. Fill in:
   - _id: `2`
   - _amount: `10000000000000000000`
5. Click "Write" → Confirm in MetaMask
6. Wait for confirmation

**Done!** ✅

---

## 📊 VERIFICATION COMMANDS

**Check your pledge amount:**
```solidity
// Via Etherscan:
// Go to Crowdfunding "Read as Proxy"
// Find: getPledgedAmount
// Enter: _id=2, _backer=yourAddress
// Should return: 10000000000000000000 (10 tokens)

// Via Script:
uint256 pledged = crowdfunding.getPledgedAmount(2, msg.sender);
require(pledged == 10 ether, "Pledge not recorded!");
```

**Check campaign status:**
```solidity
Campaign memory camp = crowdfunding.getCampaign(2);
console.log("Total pledged:", camp.pledged / 1e18);
console.log("Goal:", camp.goal / 1e18);
console.log("Campaign active:", camp.startAt <= now && now <= camp.endAt);
```

---

## 🔗 CONTRACT ADDRESSES (Copy-Paste Ready)

```
Token:        0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
Crowdfunding: 0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c
Your Address: 0x3AbBA09c1f53471660d45f16F84EABc82BA96ACf
Network:      Sepolia (11155111)
```

---

## 🎯 STANDARD SOLIDITY TEMPLATE

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Crowdfunding} from "src/Crowdfunding.sol";

contract PledgeCampaign is Script {
    function run() external {
        // Configuration
        address token = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
        address crowdfunding = 0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c;
        uint256 campaignId = 2;
        uint256 amount = 10 ether;

        IERC20 erc20 = IERC20(token);
        Crowdfunding cf = Crowdfunding(crowdfunding);

        vm.startBroadcast();

        // Step 1: Approve
        erc20.approve(crowdfunding, amount);

        // Step 2: Pledge
        cf.pledge(campaignId, amount);

        vm.stopBroadcast();
    }
}
```

---

## ⚠️ COMMON ERRORS & QUICK FIXES

| Error | Reason | Fix |
|-------|--------|-----|
| `not started` | Campaign hasn't begun | Wait until Jan 8 |
| `already ended` | Campaign is over | Campaign #2 ends Jan 18 |
| `amount = 0` | Trying to pledge 0 | Pledge at least 1 token |
| `SafeERC20FailedOperation` | Token transfer failed | Check: have tokens + approved amount |
| `Campaign not exist` | Wrong campaign ID | Use ID 2, 3, or 4 |
| `Call reverted` | Generic failure | Check all parameters correct |

---

## 🎓 UNDERSTANDING THE TWO TRANSACTIONS

```
Transaction 1: approve() 
├─ On: Token contract
├─ Calls: approve(spender, amount)
├─ Effect: allowance[you][spender] = amount
├─ Cost: ~0.005-0.01 ETH gas
└─ Purpose: Authorization only

Transaction 2: pledge()
├─ On: Crowdfunding contract
├─ Calls: pledge(campaignId, amount)
├─ Effect: Transfers your tokens
├─ Cost: ~0.01-0.02 ETH gas
└─ Purpose: Lock tokens in campaign
```

**Why two steps?** For security! You explicitly authorize before any transfer happens.

---

## 💡 PRO TIPS

1. **Approve more than needed** (one-time cost)
   ```solidity
   token.approve(crowdfunding, type(uint256).max);
   // Now you can pledge multiple times without re-approving
   ```

2. **Check gas prices** before pledging
   - Use etherscan.io to check current gas
   - Budget 0.03 ETH to be safe

3. **Use a test campaign first**
   - Pledge small amount to understand the flow
   - Then pledge larger amounts

4. **Verify on Etherscan**
   - After pledging, check your pledge amount
   - Better safe than sorry!

5. **Keep transaction hashes**
   - Save your approval & pledge tx hashes
   - Useful for debugging or proof

---

## 📋 COMPLETE FLOW CHECKLIST

- [ ] **Day 1**: Read `PLEDGING_GUIDE.md`
- [ ] **Day 1**: Check you have the token
- [ ] **Day 2**: Run approval transaction
- [ ] **Day 2**: Run pledge transaction
- [ ] **Day 3**: Verify pledge on Etherscan
- [ ] **Day 18**: Check campaign result
- [ ] **After**: Claim refund (if failed) or confirm success

---

## 🚀 TL;DR - JUST DO IT!

```bash
cd /home/dlawnoni/crowdfund
source .env

# Create script file: script/backer/PledgeMe.s.sol
# Edit addresses & amounts
# Then run:

forge script script/backer/PledgeMe.s.sol \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast -vvv

# Done! Check Etherscan for tx hash
```

---

**Questions?** Read the full guides:
- `PLEDGING_GUIDE.md` - Theory
- `PLEDGING_MECHANICS.md` - Visuals
- `PLEDGING_REFERENCE.md` - Practical
- `VISUAL_PLEDGE_FLOW.md` - Diagrams

**You got this! 🎉**
