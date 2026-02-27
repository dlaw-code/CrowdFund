#!/bin/bash

# Pledge to Campaign 2 Script
# This script pledges 50 tokens to campaign 2 on Sepolia testnet

echo "=== PLEDGING TO CAMPAIGN 2 ==="
echo ""
echo "Campaign Details:"
echo "- Campaign ID: 2"
echo "- Pledge Amount: 50 tokens"
echo "- Token Address: 0xf0E24f4437c40c247e34403b8A727E9bb28646Aa"
echo "- Crowdfunding Address: 0x60E7D551396c65B4Ffa7B03848E7d88e3E064B2c"
echo "- Network: Sepolia (11155111)"
echo ""

# Load environment variables
source .env

# Run the pledge script
forge script script/backer/PledgeCampaign2.s.sol \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  -vvv

echo ""
echo "✅ Pledge completed! Check the broadcast directory for the transaction receipt."
