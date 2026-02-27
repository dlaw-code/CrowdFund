# THE PLEDGE MECHANISM - VISUAL BREAKDOWN

## 1️⃣ ERC20 TOKEN APPROVAL (The Two-Step Process)

Why two steps? For **SECURITY** - the token contract doesn't want to blindly transfer your tokens.

```
┌─────────────────────────────────────────────────────────────────┐
│                      THE APPROVAL FLOW                          │
└─────────────────────────────────────────────────────────────────┘

Your Wallet (0x3AbBA09...)
        │
        │ "I want to approve Crowdfunding to spend 50 tokens"
        │
        ▼
[IERC20.approve(Crowdfunding, 50 ether)]
        │
        │ Sets: allowance[yourAddress][Crowdfunding] = 50 ether
        │
        ▼
Token Contract (0x7FA9385...)
        │
        │ ✅ Approval granted!
        │ Crowdfunding can now transferFrom up to 50 tokens
        │
        ▼
Crowdfunding Contract is NOW AUTHORIZED ✅
```

**Important**: This doesn't transfer tokens yet! It just grants permission.

---

## 2️⃣ THE ACTUAL PLEDGE (Transferring Tokens)

Once approved, you can now pledge:

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE PLEDGE FLOW                              │
└─────────────────────────────────────────────────────────────────┘

Your Wallet (0x3AbBA09...)
        │
        │ "I pledge 50 tokens to campaign 2"
        │
        ▼
[Crowdfunding.pledge(campaignId: 2, amount: 50 ether)]
        │
        │ Contract executes:
        │ ✅ Check campaign exists
        │ ✅ Check campaign is active (startAt <= now <= endAt)
        │ ✅ Check amount > 0
        │ ✅ campaign.pledged += 50
        │ ✅ pledgedAmount[2][yourAddr] += 50
        │
        ▼
[TOKEN.safeTransferFrom(yourAddr, Crowdfunding, 50 ether)]
        │
        │ Token contract transfers 50 tokens
        │ FROM: Your Wallet
        │ TO: Crowdfunding Contract
        │
        ▼
Crowdfunding Contract NOW HOLDS YOUR 50 TOKENS ✅
Emit Pledge event
```

---

## 3️⃣ STATE AFTER PLEDGING

```
Token Contract (0x7FA9385...)
├─ Your Balance: 150 → 100 tokens (50 sent)
└─ allowance[you][Crowdfunding]: 50 → 0 (used up)

Crowdfunding Contract (0x60E7D551...)
├─ Token Balance: increased by 50
├─ Campaign #2:
│  ├─ pledged: 100 → 150 tokens
│  ├─ goal: 100 tokens
│  └─ isFlexibleFunding: false
└─ pledgedAmount[2][you]: 0 → 50 tokens
```

---

## 4️⃣ WHAT CAN HAPPEN NEXT

### Option A: CAMPAIGN SUCCEEDS ✅

```
Campaign #2 reaches end time with pledged >= goal

Creator calls: crowdfunding.claim(2)
    ↓
Platform Fee = 150 * 5% = 7.5 tokens → Admin
Remaining = 150 - 7.5 = 142.5 tokens → Creator

Result:
├─ Admin receives: 7.5 tokens
├─ Creator receives: 142.5 tokens
├─ You (backer): Get nothing (participated in successful campaign)
└─ Your tokens: LOCKED with creator
```

### Option B: CAMPAIGN FAILS ❌

```
Campaign #2 reaches end time with pledged < goal
AND isFlexibleFunding = false

You call: crowdfunding.refund(2)
    ↓
pledgedAmount[2][you] = 0
Tokens sent back to you = 50

Result:
├─ You receive: 50 tokens back
├─ Creator receives: nothing (goal failed)
└─ Campaign is refunded
```

### Option C: YOU CHANGE YOUR MIND 🔄

```
Before campaign ends, you call: crowdfunding.unpledge(2, 50)
    ↓
campaign.pledged = 150 - 50 = 100
pledgedAmount[2][you] = 50 - 50 = 0
Tokens sent back to you = 50

Result:
├─ You receive: 50 tokens back (while campaign still active)
├─ Campaign total pledged: reduced
└─ You can pledge again if you want
```

---

## 5️⃣ COMPLETE EXAMPLE WITH NUMBERS

```
INITIAL STATE:
Your Token Balance: 200 tokens
Campaign #2:
  - Goal: 100 tokens
  - Start: Jan 10, 2026
  - End: Jan 20, 2026
  - Pledged so far: 50 tokens (from other backers)
  - Creator: Alice

YOUR ACTIONS:
┌──────────────────────────────────────────────────────┐
│ Step 1: Approve                                      │
├──────────────────────────────────────────────────────┤
│ token.approve(Crowdfunding, 50 ether)               │
│ Your Balance: 200 (unchanged, just authorized)       │
└──────────────────────────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────┐
│ Step 2: Pledge                                       │
├──────────────────────────────────────────────────────┤
│ crowdfunding.pledge(2, 50 ether)                    │
│ Your Balance: 200 - 50 = 150 tokens                 │
│ Campaign #2 Pledged: 50 + 50 = 100 tokens           │
│ Your Pledge Recorded: 50 tokens to campaign 2       │
└──────────────────────────────────────────────────────┘
                         ▼
        CAMPAIGN REACHES END TIME (Jan 20)
                         ▼
   Goal Met (100 >= 100)? YES ✅
                         ▼
┌──────────────────────────────────────────────────────┐
│ Alice (Creator) calls: claim(2)                      │
├──────────────────────────────────────────────────────┤
│ Platform Fee: 100 * 5% = 5 tokens → Admin           │
│ For Alice: 100 - 5 = 95 tokens                      │
│                                                      │
│ Admin receives: 5 tokens                            │
│ Alice receives: 95 tokens                           │
│ You: Get nothing (you're the backer, not creator)   │
│ Your tokens: LOCKED with Alice (part of the 95)     │
└──────────────────────────────────────────────────────┘
```

---

## 6️⃣ KEY SOLIDITY FUNCTIONS EXPLAINED

### approve() - Token Contract
```solidity
// You call this on the Token contract
token.approve(address spender, uint256 amount)

// Effect:
allowance[msg.sender][spender] = amount

// Usage: Lets Crowdfunding contract transfer your tokens later
```

### transferFrom() - Token Contract (Called by Crowdfunding)
```solidity
// Crowdfunding calls this on the Token contract
TOKEN.safeTransferFrom(from, to, amount)

// Checks: allowance[from][msg.sender] >= amount
// Effect: 
//   - balance[from] -= amount
//   - balance[to] += amount
//   - allowance[from][msg.sender] -= amount

// Result: Tokens moved from your wallet to Crowdfunding
```

### pledge() - Crowdfunding Contract
```solidity
// You call this on the Crowdfunding contract
crowdfunding.pledge(uint256 campaignId, uint256 amount)

// Effect:
//   - campaigns[campaignId].pledged += amount
//   - pledgedAmount[campaignId][msg.sender] += amount
//   - TOKEN.safeTransferFrom(msg.sender, address(this), amount)
//   - emit Pledge(campaignId, msg.sender, amount)

// Requirements:
//   - Campaign must exist
//   - Campaign must be active (startAt <= now <= endAt)
//   - Amount must be > 0
//   - You must have approved enough tokens
//   - Reentrancy protection (nonReentrant modifier)
```

---

## 7️⃣ APPROVAL AMOUNT STRATEGIES

### Strategy 1: Approve Exactly
```solidity
token.approve(crowdfunding, 50 ether);
crowdfunding.pledge(campaignId, 50 ether);
// Pro: Precise control
// Con: Need new approval for each pledge
```

### Strategy 2: Approve High Amount (Recommended)
```solidity
token.approve(crowdfunding, type(uint256).max);
crowdfunding.pledge(campaignId, 50 ether);
crowdfunding.pledge(campaignId, 30 ether);
// Pro: Multiple pledges without re-approving
// Con: Higher risk if contract is hacked (but contract is auditable)
```

### Strategy 3: Approve with Increase/Decrease (SafeERC20)
```solidity
token.approve(crowdfunding, 50 ether);
// Later...
token.increaseAllowance(crowdfunding, 30 ether); // Now 80 total
token.decreaseAllowance(crowdfunding, 10 ether); // Now 70 total
```

---

## 8️⃣ STANDARD INDUSTRY PATTERN

This two-step approval + transfer pattern is used by:
- **Uniswap** - Approve tokens, then swap
- **Aave** - Approve tokens, then lend
- **OpenSea** - Approve NFTs, then buy
- **All ERC20-based DeFi protocols**

It's the **STANDARD** because:
1. ✅ Secure - Tokens aren't transferred without approval
2. ✅ Efficient - You can use the same approval for multiple actions
3. ✅ User-friendly - You control exactly what gets authorized

---

## ✅ FINAL CHECKLIST: Ready to Pledge?

- [ ] Campaign ID is known
- [ ] Campaign is active (after startAt, before endAt)
- [ ] You have enough tokens
- [ ] Token address matches crowdfunding's TOKEN
- [ ] You called approve() with sufficient amount
- [ ] You have ETH for gas fees
- [ ] You understand you'll lock tokens until campaign ends

**If all checked ✓**, you're ready to pledge! 🚀
