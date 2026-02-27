# VISUAL PLEDGE FLOW - COMPLETE DIAGRAM

## 🎯 THE COMPLETE PLEDGE JOURNEY

```
                         YOU WANT TO PLEDGE TO CAMPAIGN 2
                                      │
                                      ▼
                ┌─────────────────────────────────────┐
                │  PREREQUISITES                      │
                ├─────────────────────────────────────┤
                │ ✅ Campaign 2 is active             │
                │ ✅ You have 10+ tokens              │
                │ ✅ You have ETH for gas            │
                └─────────────────────────────────────┘
                                      │
                    ┌─────────────────┴──────────────┐
                    │                                │
                    ▼                                ▼
         NO TOKENS?               HAVE TOKENS?
             │                          │
             │                    GOOD! PROCEED
         GET TOKENS                     │
             │                          ▼
             │              ┌──────────────────────┐
             │              │ STEP 1: APPROVE      │
             │              ├──────────────────────┤
             │              │ Call on Token:       │
             │              │ approve(             │
             │              │   Crowdfunding,      │
             │              │   10 ether           │
             │              │ )                    │
             │              └──────────────────────┘
             │                         │
             │                         ▼
             │              ┌──────────────────────┐
             │              │ Transaction 1 sent   │
             │              │ ✅ Approved!        │
             │              │                      │
             │              │ allowance[you][CF]   │
             │              │ = 10 tokens          │
             │              └──────────────────────┘
             │                         │
             │                         ▼
             │              ┌──────────────────────┐
             │              │ STEP 2: PLEDGE       │
             │              ├──────────────────────┤
             │              │ Call on Crowdfunding:│
             │              │ pledge(              │
             │              │   campaignId: 2,     │
             │              │   amount: 10 ether   │
             │              │ )                    │
             │              └──────────────────────┘
             │                         │
             │                         ▼
             │              ┌──────────────────────┐
             │              │ Crowdfunding checks: │
             │              │ ✅ Campaign exists   │
             │              │ ✅ Campaign active   │
             │              │ ✅ Amount > 0        │
             │              │ ✅ You approved $     │
             │              └──────────────────────┘
             │                         │
             │                         ▼
             │              ┌──────────────────────┐
             │              │ Token transferred:   │
             │              │ FROM: Your wallet    │
             │              │ TO: Crowdfunding     │
             │              │ AMOUNT: 10 tokens    │
             │              └──────────────────────┘
             │                         │
             │                         ▼
             │              ┌──────────────────────┐
             │              │ Transaction 2 done   │
             │              │ ✅ Pledged!         │
             │              │                      │
             │              │ Your state:          │
             │              │ - Balance: 90 (-10)  │
             │              │ - Pledged[2]: 10     │
             │              │ - Tokens: LOCKED     │
             │              │                      │
             │              │ Campaign #2:         │
             │              │ - Total: 60+ tokens  │
             │              └──────────────────────┘
             │                         │
             └──────────────┬──────────┘
                            │
                            ▼
                    CAMPAIGN ENDS (JAN 18)
                            │
            ┌───────────────┴──────────────┐
            │                              │
            ▼                              ▼
        GOAL MET?                    GOAL NOT MET?
      (60+ tokens)                  (< 60 tokens)
            │                              │
            ▼                              ▼
    ┌──────────────────┐         ┌──────────────────┐
    │ SUCCESS ✅        │         │ FAILED ❌         │
    ├──────────────────┤         ├──────────────────┤
    │ Creator calls:    │         │ You call:        │
    │ claim(2)          │         │ refund(2)        │
    │                   │         │                  │
    │ Fee: 5% to admin  │         │ Your tokens:     │
    │ Rest to creator   │         │ RETURNED!        │
    │                   │         │                  │
    │ YOU: Get nothing  │         │ Creator: nothing │
    │ (funded campaign) │         │                  │
    └──────────────────┘         └──────────────────┘
            │                              │
            ▼                              ▼
    ✅ Campaign funded            ✅ Campaign failed
    💰 Creator happy              💰 You get refund
    🎉 Campaign proceeds          😢 No funding
```

---

## 📈 STATE CHANGES DIAGRAM

```
┌────────────────────────────────────────────────────────────┐
│                     YOUR WALLET STATE                      │
└────────────────────────────────────────────────────────────┘

    INITIAL                AFTER APPROVE          AFTER PLEDGE
    ─────────              ──────────────         ─────────────
    
    Balance: 100           Balance: 100           Balance: 90
    ✓ Free                 ✓ Free                 ✗ Locked (10)
    
    Allowance: 0           Allowance: 10          Allowance: 0
    (to Crowdfunding)      ✓ Can use              (used up)
                           
                                                 Pledged: 10
                                                 (to Campaign 2)
```

---

## 🔄 STATE CHANGES IN CONTRACT

```
┌────────────────────────────────────────────────────────────┐
│            CROWDFUNDING CONTRACT STATE                      │
└────────────────────────────────────────────────────────────┘

    BEFORE PLEDGE              AFTER PLEDGE
    ─────────────              ────────────
    
    campaigns[2].pledged: 50    campaigns[2].pledged: 60
    (other backers)            (+ your 10)
    
    pledgedAmount[2][you]: 0    pledgedAmount[2][you]: 10
    (tracking)                 (your pledge recorded)
    
    Contract balance: 50 ETH    Contract balance: 60 ETH
    (in tokens)                (+ your 10 tokens)
```

---

## 🎬 COMPLETE FLOW WITH TIMING

```
Timeline of Events:
─────────────────────────────────────────────────────────

JAN 1-7, 2026
├─ You create Campaign 2
├─ Goal: 100 tokens
├─ Start: Jan 8, 2026
├─ End: Jan 18, 2026
└─ Flexible: NO (must meet goal)

JAN 8, 2026
├─ Campaign starts
├─ Backers begin pledging
└─ You can pledge now ← YOU ARE HERE

JAN 10-17, 2026
├─ Campaign is active
├─ More backers pledge
├─ Total pledges: 50+ tokens
└─ You pledged: 10 tokens

JAN 18, 2026
├─ Campaign ends
├─ Check final pledges: 60 tokens
├─ Compare to goal: 100 tokens
└─ Result: ❌ GOAL NOT MET

JAN 19+, 2026
├─ Creator cannot claim
├─ Backers can refund
└─ You get 10 tokens back
```

---

## 💰 MONEY FLOW IN YOUR SCENARIO

```
Scenario: You pledge 10 tokens to Campaign 2

                    YOUR ACTIONS
                    ────────────
                         │
         ┌───────────────┴────────────────┐
         │                                │
    Approve 10              Pledge 10 tokens
    (not transferred)       (transferred!)
         │                        │
         ▼                        ▼
    Token Contract         Crowdfunding Contract
    ║ Gives permission      ║ Holds your 10 tokens
    ║ allowance[you][CF]    ║ Waits for end time
    ║ = 10 tokens           ║
    ║                       ╚═══╤═══════════════
    ║                           │
    ║                    Campaign Ends
    ║                           │
    ║                    ┌──────┴──────┐
    ║                    │             │
    ║           Goal Met?      Goal Failed?
    ║           (100+)         (<100)
    ║              │              │
    ║              ▼              ▼
    ║         Creator         You get
    ║         gets            refund
    ║         funds           (10 back)
    ║         (95 after
    ║          5% fee)
    │
    └─ Still in your account, just authorized
```

---

## ⚡ GAS COST BREAKDOWN

```
Transaction 1: approve()
─────────────────────────
- Function call: ~21,000 gas
- ERC20 approval: ~20,000 gas
- Total: ~41,000 gas
- Cost: ~0.005-0.01 ETH (at Sepolia gas prices)

Transaction 2: pledge()
────────────────────────
- Function call: ~21,000 gas
- State update (campaign.pledged): ~5,000 gas
- State update (pledgedAmount): ~20,000 gas
- Token transfer: ~40,000 gas
- Reentrancy check: ~1,000 gas
- Event emit: ~2,000 gas
- Total: ~89,000 gas
- Cost: ~0.01-0.02 ETH (at Sepolia gas prices)

TOTAL GAS: ~130,000 gas ≈ 0.015-0.03 ETH ≈ $40-80
```

---

## 🔐 SECURITY CHECKS IN YOUR CONTRACT

```
When you call pledge(2, 10):

┌─────────────────────────────────────┐
│ SECURITY CHECKS PERFORMED           │
├─────────────────────────────────────┤
│                                     │
│ 1. campaignExists(2)               │
│    ✅ Campaign 2 must exist         │
│                                     │
│ 2. nonReentrant                     │
│    ✅ Prevent recursive calls       │
│                                     │
│ 3. block.timestamp >= startAt      │
│    ✅ Campaign must have started    │
│                                     │
│ 4. block.timestamp <= endAt        │
│    ✅ Campaign must be active       │
│                                     │
│ 5. _amount > 0                     │
│    ✅ Must pledge something         │
│                                     │
│ 6. safeTransferFrom()              │
│    ✅ SafeERC20 handles edge cases │
│    ✅ Checks you have tokens       │
│    ✅ Checks approval exists       │
│                                     │
└─────────────────────────────────────┘
```

---

## 📝 SUMMARY TABLE

| Phase | Your Balance | Crowdfunding Balance | Campaign Pledged |
|-------|--------------|----------------------|------------------|
| Before | 100 tokens | 0 tokens | 50 tokens (others) |
| After Approve | 100 tokens | 0 tokens | 50 tokens |
| After Pledge | 90 tokens | 10 tokens | 60 tokens |
| Campaign Ends (Goal Failed) | 100 tokens (refunded) | 0 tokens | 0 tokens |

---

**This is the complete flow of pledging in your Crowdfunding contract!** 🚀
