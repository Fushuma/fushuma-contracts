#!/bin/bash

# WFUMA Deployment Script for Fushuma Network
# This script deploys the Wrapped FUMA token contract

set -e

echo "========================================="
echo "WFUMA Deployment Script"
echo "========================================="
echo ""

# Network Configuration
CHAIN_ID=121224
RPC_URL="https://rpc.fushuma.com"
EXPLORER_URL="https://explorer.fushuma.com"

# Check if private key is provided
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable is not set"
    echo "Usage: PRIVATE_KEY=0x... ./deploy-wfuma.sh"
    exit 1
fi

# Check if foundry is installed
if ! command -v forge &> /dev/null; then
    echo "Error: Foundry (forge) is not installed"
    echo "Install from: https://book.getfoundry.sh/getting-started/installation"
    exit 1
fi

echo "Network: Fushuma Network"
echo "Chain ID: $CHAIN_ID"
echo "RPC URL: $RPC_URL"
echo ""

# Check RPC connectivity
echo "Checking RPC connectivity..."
if ! cast block-number --rpc-url $RPC_URL &> /dev/null; then
    echo "Error: Cannot connect to RPC at $RPC_URL"
    exit 1
fi
echo "✓ RPC connection successful"
echo ""

# Get deployer address
DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)
echo "Deployer address: $DEPLOYER"

# Check deployer balance
BALANCE=$(cast balance $DEPLOYER --rpc-url $RPC_URL)
echo "Deployer balance: $BALANCE wei"
echo ""

if [ "$BALANCE" = "0" ]; then
    echo "Error: Deployer has zero balance. Please fund the account with FUMA tokens."
    exit 1
fi

# Deploy WFUMA contract
echo "Deploying WFUMA contract..."
echo ""

DEPLOY_OUTPUT=$(forge create WFUMA.sol:WFUMA \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --legacy 2>&1)

echo "$DEPLOY_OUTPUT"
echo ""

# Extract deployed address
WFUMA_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oP "Deployed to: \K0x[a-fA-F0-9]{40}" || echo "")

if [ -z "$WFUMA_ADDRESS" ]; then
    echo "Error: Failed to extract contract address from deployment output"
    exit 1
fi

echo "========================================="
echo "✓ WFUMA Deployment Successful!"
echo "========================================="
echo ""
echo "Contract Address: $WFUMA_ADDRESS"
echo "Explorer: $EXPLORER_URL/address/$WFUMA_ADDRESS"
echo ""
echo "Next steps:"
echo "1. Verify the contract on the block explorer"
echo "2. Update src/lib/fumaswap/contracts.ts with the WFUMA address"
echo "3. Test wrap/unwrap functionality"
echo ""

# Save deployment info
cat > deployment-info.json <<EOF
{
  "network": "Fushuma Network",
  "chainId": $CHAIN_ID,
  "deployer": "$DEPLOYER",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "contracts": {
    "WFUMA": "$WFUMA_ADDRESS"
  }
}
EOF

echo "Deployment info saved to deployment-info.json"
echo ""
echo "To verify the contract, run:"
echo "forge verify-contract $WFUMA_ADDRESS WFUMA.sol:WFUMA --chain $CHAIN_ID --rpc-url $RPC_URL"
