#!/bin/bash

# Script to check for active campaigns using cast
# Usage: ./check_campaigns.sh

# Load environment variables
source .env

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================"
echo "CHECKING ACTIVE CAMPAIGNS"
echo "========================================"
echo "Crowdfunding Contract: $CROWDFUNDING_ADDRESS"
echo "RPC URL: $SEPOLIA_RPC_URL"
echo ""

# Get total campaign count
echo "Fetching campaign count..."
COUNT=$(cast call "$CROWDFUNDING_ADDRESS" "count()(uint256)" --rpc-url "$SEPOLIA_RPC_URL" 2>/dev/null)

if [ -z "$COUNT" ] || [ "$COUNT" == "0" ]; then
    echo -e "${RED}No campaigns found!${NC}"
    exit 0
fi

echo "Total Campaigns: $COUNT"
echo ""

# Get current block timestamp
CURRENT_TIME=$(cast block latest --rpc-url "$SEPOLIA_RPC_URL" | grep timestamp | awk '{print $2}')
echo "Current Time: $CURRENT_TIME"
echo ""

ACTIVE_COUNT=0

# Loop through campaigns
for i in $(seq 1 $COUNT); do
    echo "Checking Campaign #$i..."
    
    # Get campaign data
    # getCampaign(uint256) returns: (address creator, uint256 goal, uint256 pledged, uint32 startAt, uint32 endAt, bool claimed, bool isFlexibleFunding)
    CAMPAIGN_DATA=$(cast call "$CROWDFUNDING_ADDRESS" "getCampaign(uint256)(address,uint256,uint256,uint32,uint32,bool,bool)" "$i" --rpc-url "$SEPOLIA_RPC_URL" 2>/dev/null)
    
    if [ -z "$CAMPAIGN_DATA" ]; then
        echo "  Campaign #$i - Error fetching data"
        continue
    fi
    
    # Parse the response
    CREATOR=$(echo $CAMPAIGN_DATA | awk '{print $1}')
    GOAL=$(echo $CAMPAIGN_DATA | awk '{print $2}')
    PLEDGED=$(echo $CAMPAIGN_DATA | awk '{print $3}')
    START_AT=$(echo $CAMPAIGN_DATA | awk '{print $4}')
    END_AT=$(echo $CAMPAIGN_DATA | awk '{print $5}')
    CLAIMED=$(echo $CAMPAIGN_DATA | awk '{print $6}')
    IS_FLEXIBLE=$(echo $CAMPAIGN_DATA | awk '{print $7}')
    
    # Check if campaign exists (creator != address(0))
    if [ "$CREATOR" == "0x0000000000000000000000000000000000000000" ]; then
        echo "  Campaign #$i - Does not exist (cancelled or deleted)"
        continue
    fi
    
    # Convert to human-readable values (assuming 18 decimals)
    GOAL_TOKENS=$(echo "scale=2; $GOAL / 1000000000000000000" | bc)
    PLEDGED_TOKENS=$(echo "scale=2; $PLEDGED / 1000000000000000000" | bc)
    
    # Check if active
    if [ "$CURRENT_TIME" -ge "$START_AT" ] && [ "$CURRENT_TIME" -le "$END_AT" ]; then
        ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
        echo -e "${GREEN}----------------------------------------${NC}"
        echo -e "${GREEN}ACTIVE CAMPAIGN #$i${NC}"
        echo -e "${GREEN}----------------------------------------${NC}"
        echo "  Creator: $CREATOR"
        echo "  Goal: $GOAL_TOKENS tokens"
        echo "  Pledged: $PLEDGED_TOKENS tokens"
        echo "  Start Time: $START_AT"
        echo "  End Time: $END_AT"
        echo "  Flexible Funding: $IS_FLEXIBLE"
        echo "  Claimed: $CLAIMED"
        echo -e "${GREEN}  Status: ACTIVE - Ready to pledge!${NC}"
        echo ""
    elif [ "$CURRENT_TIME" -lt "$START_AT" ]; then
        echo "  Campaign #$i - Not started yet (starts at: $START_AT)"
    elif [ "$CURRENT_TIME" -gt "$END_AT" ]; then
        echo -e "${RED}  Campaign #$i - EXPIRED (ended at: $END_AT)${NC}"
        if [ "$CLAIMED" == "true" ]; then
            echo "    -> Funds claimed by creator"
        elif [ "$PLEDGED" -ge "$GOAL" ] || [ "$IS_FLEXIBLE" == "true" ]; then
            echo "    -> Goal met - Creator can claim"
        else
            echo "    -> Goal not met - Backers can refund"
        fi
    fi
done

echo "========================================"
echo "SUMMARY"
echo "========================================"
echo "Total Campaigns: $COUNT"
echo -e "${GREEN}Active Campaigns: $ACTIVE_COUNT${NC}"
echo ""

if [ "$ACTIVE_COUNT" -eq 0 ]; then
    echo -e "${RED}No active campaigns found. All campaigns have expired or not started yet.${NC}"
else
    echo -e "${GREEN}You can pledge to $ACTIVE_COUNT active campaign(s)!${NC}"
    echo "Use the campaign IDs shown above."
fi
