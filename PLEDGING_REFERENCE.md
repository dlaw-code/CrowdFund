# PLEDGING IN YOUR SPECIFIC CROWDFUNDING CONTRACT

## 📍 Your Contract Addresses

- **Crowdfunding Contract**: `0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c`
- **Token Contract**: `0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496`
- **Your Address**: `0x3AbBA09c1f53471660d45f16F84EABc82BA96ACf`
- **Network**: Sepolia Testnet (11155111)

---

## 🎯 YOUR ACTIVE CAMPAIGNS

| Campaign ID | Status | Goal | Current Pledges | Start | End | Action |
|-------------|--------|------|-----------------|-------|-----|--------|
| 2 | 🟢 ACTIVE | 100 tokens | ? | Jan 8 | Jan 18 | **PLEDGE NOW** |
| 3 | 🟢 ACTIVE | 100 tokens | ? | Jan 10 | Jan 20 | PLEDGE LATER |
| 4 | 🟢 ACTIVE | 100 tokens | ? | Jan 10 | Jan 20 | PLEDGE LATER |

---

## 🎬 STEP-BY-STEP: PLEDGE TO CAMPAIGN 2

### PREREQUISITE: Do You Have the Token?

First, check if you have the token (`0x7FA9385bE...`) in your wallet:

**On Etherscan (or block explorer):**
1. Go to: `https://sepolia.etherscan.io`
2. Search token: `0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496`
3. Check your balance
4. If balance = 0, you need to get this token!

---

### IF YOU DON'T HAVE THE TOKEN: Where to Get It?

This token was used when you deployed the Crowdfunding contract. Options:
1. **Check your deployment scripts** - Do you have a faucet or minting function?
2. **Check previous broadcasts** - Look for where this token came from
3. **Mint from contract** - If you have minting permissions, create tokens
4. **Use the MockERC20 instead** - Switch to the contract with MockERC20

---

### IF YOU HAVE THE TOKEN: Let's Pledge!

#### Method 1: Using Your Script (Recommended)

We created a script for you at `script/backer/PledgeWithMockToken.s.sol`

Modify it to use the correct token:

```solidity
// CHANGE THIS:
address tokenAddress = 0xf0E24f4437c40c247e34403b8A727E9bb28646Aa; // ❌ OLD
address crowdfundingAddress = 0x0fcD5851717194C93E6696936dd4432bfDe6BAFc; // ❌ OLD

// TO THIS:
address tokenAddress = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496; // ✅ CORRECT
address crowdfundingAddress = 0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c; // ✅ CORRECT
uint256 campaignId = 2; // CAMPAIGN 2
uint256 amount = 10 ether; // PLEDGE 10 TOKENS
```

Then run:
```bash
cd /home/dlawnoni/crowdfund
source .env
forge script script/backer/PledgeWithMockToken.s.sol \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  -vvv
```

---

#### Method 2: Using Etherscan (Manual)

If you prefer to interact through Etherscan:

**Step 1: Approve Token**
1. Go to token contract on Etherscan: `0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496`
2. Click "Contract" tab → "Write as Proxy"
3. Connect your wallet
4. Find `approve` function
5. Enter:
   - `spender`: `0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c` (Crowdfunding contract)
   - `amount`: `10000000000000000000` (10 tokens with 18 decimals)
6. Click "Write"
7. Confirm in MetaMask

**Step 2: Pledge**
1. Go to Crowdfunding contract on Etherscan: `0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c`
2. Click "Contract" tab → "Write as Proxy"
3. Connect your wallet
4. Find `pledge` function
5. Enter:
   - `_id`: `2` (Campaign 2)
   - `_amount`: `10000000000000000000` (10 tokens)
6. Click "Write"
7. Confirm in MetaMask

---

## 📊 UNDERSTANDING THE TRANSACTION

When you pledge, two transactions happen:

### Transaction 1: approve()
```
Function: approve
Input:
  - spender: 0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c
  - amount: 10000000000000000000

What it does:
  - Sets allowance[YOUR_ADDRESS][CROWDFUNDING] = 10 tokens
  - Token contract: "You can now transfer this much"
  
Gas cost: ~45,000 gas
```

### Transaction 2: pledge()
```
Function: pledge
Input:
  - campaignId: 2
  - amount: 10000000000000000000

What it does:
  1. Checks: campaign 2 exists ✓
  2. Checks: campaign 2 is active ✓
  3. Checks: amount > 0 ✓
  4. Updates: campaigns[2].pledged += 10
  5. Updates: pledgedAmount[2][yourAddress] += 10
  6. Transfers: 10 tokens from you → contract
  7. Emits: Pledge event
  
Gas cost: ~90,000 gas

Result: Your 10 tokens are now locked in the contract!
```

---

## ✅ VERIFY YOUR PLEDGE

After pledging, verify it worked:

### Via Script:
```solidity
uint256 myPledge = crowdfunding.getPledgedAmount(2, yourAddress);
console.log("I pledged:", myPledge / 1e18, "tokens to campaign 2");
```

### Via Etherscan:
1. Go to Crowdfunding contract
2. Click "Read as Proxy"
3. Find `getPledgedAmount`
4. Enter:
   - `_id`: `2`
   - `_backer`: Your address
5. Click "Query"
6. Result should show: `10000000000000000000` (10 tokens)

---

## 🔄 AFTER YOU PLEDGE: What Can You Do?

### Before Campaign Ends (Before Jan 18):
- ✅ **View your pledge**: `getPledgedAmount(2, yourAddress)`
- ✅ **Unpledge** (withdraw your tokens): `unpledge(2, amount)`
- ❌ Can't refund yet (campaign still active)
- ❌ Can't claim (not the creator)

### After Campaign Ends (After Jan 18):
- ✅ **If goal met (100+ tokens pledged)**: 
  - Creator claims funds (you lose your tokens, they support the campaign)
  - Transaction: `crowdfunding.claim(2)`
  
- ❌ **If goal failed**:
  - Campaign didn't reach 100 tokens
  - Call `refund(2)` to get your tokens back
  - Transaction: `crowdfunding.refund(2)`

---

## 🎯 YOUR PLEDGE JOURNEY

```
BEFORE PLEDGING
├─ Your Token Balance: 100 tokens
└─ Campaign #2 Pledged: 50 tokens (other backers)

STEP 1: APPROVE
├─ Action: token.approve(Crowdfunding, 10 ether)
├─ Your Token Balance: Still 100 (just authorized)
├─ Allowance: 10 tokens to Crowdfunding
└─ Campaign #2 Pledged: Still 50

STEP 2: PLEDGE
├─ Action: crowdfunding.pledge(2, 10 ether)
├─ Your Token Balance: 100 - 10 = 90 tokens
├─ Your Pledge: pledgedAmount[2][you] = 10 tokens
├─ Campaign #2 Pledged: 50 + 10 = 60 tokens
└─ Tokens Location: LOCKED IN CROWDFUNDING CONTRACT

WAIT FOR CAMPAIGN END (Jan 18)
├─ Campaign End: Jan 18, 2026
├─ Final Pledges: 60+ tokens (goal was 100)
└─ Status: DEPENDS ON OTHER BACKERS

SCENARIO A: Others pledge 40+ more (≥100 total)
├─ Creator calls claim(2)
├─ Your 10 tokens: Sent to creator (you funded the campaign!)
├─ Platform Fee: 5% = 3 tokens to admin
├─ Creator gets: 57 tokens (60% of 100)
└─ You: Get nothing, but campaign succeeded!

SCENARIO B: Others pledge <40 more (<100 total, <60+40)
├─ Campaign Failed (< 100 tokens)
├─ You can call refund(2)
├─ Your 10 tokens: Returned to your wallet
├─ Creator: Gets nothing
└─ You: Get tokens back, campaign failed
```

---

## 💡 IMPORTANT RULES IN YOUR CONTRACT

From the `pledge()` function:

```solidity
require(block.timestamp >= campaign.startAt, "not started");
// Campaign must have started! Can't pledge before start time.

require(block.timestamp <= campaign.endAt, "already ended");
// Campaign must be ongoing! Can't pledge after end time.

require(_amount > 0, "amount = 0");
// Must pledge at least 1 token unit

TOKEN.safeTransferFrom(msg.sender, address(this), _amount);
// Actual token transfer happens here
// If this fails: "SafeERC20FailedOperation" error
```

---

## ⚠️ COMMON ERRORS & FIXES

| Error | Cause | Fix |
|-------|-------|-----|
| `"not started"` | Campaign hasn't started yet | Wait for startAt time |
| `"already ended"` | Campaign ended | Campaign is over, can't pledge |
| `"amount = 0"` | Trying to pledge 0 tokens | Pledge at least 1 token |
| `SafeERC20FailedOperation` | Token transfer failed | Check you have tokens & approved |
| `Campaign not exist` | Wrong campaign ID | Use correct campaign ID (2, 3, or 4) |

---

## 📋 CHECKLIST BEFORE PLEDGING

- [ ] I have the token: `0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496`
- [ ] My token balance > 10 (or amount I want to pledge)
- [ ] Campaign 2 start time has passed (Jan 8 ✓)
- [ ] Campaign 2 end time hasn't arrived (Jan 18 not yet)
- [ ] I have ETH for gas fees (~0.01-0.02 ETH)
- [ ] I understand tokens will be locked in the contract
- [ ] I'm ready to approve + pledge

✅ **IF ALL CHECKED: You're ready to pledge!**

---

## 🚀 FINAL COMMAND TO PLEDGE

```bash
cd /home/dlawnoni/crowdfund
source .env

# Create your pledge script first, then run:
forge script script/backer/YourPledgeScript.s.sol \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  -vvv
```

---

**Questions?** Check the other guides:
- `PLEDGING_GUIDE.md` - Detailed explanation
- `PLEDGING_MECHANICS.md` - Visual diagrams
