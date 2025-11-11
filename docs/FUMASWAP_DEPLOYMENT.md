# FumaSwap V4 Deployment Guide

This guide provides step-by-step instructions for deploying FumaSwap V4 contracts to Fushuma Network.

## Prerequisites

### 1. Install Dependencies

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Clone repository
git clone https://github.com/Fushuma/fushuma-contracts.git
cd fushuma-contracts

# Install contract dependencies
forge install
```

### 2. Configure Environment

Create a `.env` file:

```bash
# Network Configuration
RPC_URL=https://rpc.fushuma.com
CHAIN_ID=your_chain_id

# Deployment Account
PRIVATE_KEY=your_private_key_here

# Contract Verification
ETHERSCAN_API_KEY=your_explorer_api_key

# Token Addresses (if already deployed)
WFUMA_ADDRESS=0x...
FUMA_ADDRESS=0x...

# Governance Addresses (if using governance control)
GOVERNANCE_ADDRESS=0x...
TIMELOCK_ADDRESS=0x...
```

### 3. Prepare Deployment Account

Ensure your deployment account has sufficient FUMA for gas fees:

```bash
# Check balance
cast balance $DEPLOYER_ADDRESS --rpc-url $RPC_URL

# Recommended: At least 50 FUMA for full deployment
```

## Deployment Order

Deploy contracts in this specific order to satisfy dependencies:

1. **WFUMA Token** (if not already deployed)
2. **Core Contracts** (Vault, Pool Managers)
3. **Periphery Contracts** (Position Managers, Routers, Quoters)
4. **Custom Hooks** (FUMA Discount Hook, Launchpad Hook)
5. **Initialize Pools**

---

## Step 1: Deploy WFUMA Token

If WFUMA is not already deployed:

```bash
forge script script/DeployWFUMA.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

# Save the deployed address
export WFUMA_ADDRESS=<deployed_address>
```

**Expected Gas**: ~1,000,000

---

## Step 2: Deploy Core Contracts

### 2.1 Deploy Vault

```bash
forge script script/fumaswap-core/01_DeployVault.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

# Save addresses
export VAULT_ADDRESS=<vault_address>
export PROTOCOL_FEES_ADDRESS=<protocol_fees_address>
export PROTOCOL_FEE_CONTROLLER_ADDRESS=<controller_address>
```

**Contracts Deployed**:
- `Vault.sol` - Main liquidity vault
- `ProtocolFees.sol` - Fee collection
- `ProtocolFeeController.sol` - Fee management

**Expected Gas**: ~8,000,000

### 2.2 Deploy CL Pool Manager

```bash
forge script script/fumaswap-core/02_DeployCLPoolManager.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

export CL_POOL_MANAGER_ADDRESS=<deployed_address>
```

**Expected Gas**: ~5,000,000

### 2.3 Deploy Bin Pool Manager (Optional)

```bash
forge script script/fumaswap-core/03_DeployBinPoolManager.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

export BIN_POOL_MANAGER_ADDRESS=<deployed_address>
```

**Expected Gas**: ~4,000,000

---

## Step 3: Deploy Periphery Contracts

### 3.1 Deploy CL Position Manager

```bash
forge script script/fumaswap-periphery/01_DeployCLPositionManager.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

export CL_POSITION_MANAGER_ADDRESS=<deployed_address>
```

**Expected Gas**: ~6,000,000

### 3.2 Deploy Infinity Router

```bash
forge script script/fumaswap-periphery/02_DeployInfinityRouter.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

export INFINITY_ROUTER_ADDRESS=<deployed_address>
```

**Expected Gas**: ~4,000,000

### 3.3 Deploy Quoters

```bash
# Deploy CL Quoter
forge script script/fumaswap-periphery/03_DeployCLQuoter.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

export CL_QUOTER_ADDRESS=<deployed_address>

# Deploy Mixed Quoter
forge script script/fumaswap-periphery/04_DeployMixedQuoter.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

export MIXED_QUOTER_ADDRESS=<deployed_address>
```

**Expected Gas**: ~3,000,000 (total)

---

## Step 4: Deploy Custom Hooks

### 4.1 Deploy FUMA Discount Hook

```bash
forge script script/hooks/DeployFumaDiscountHook.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

export FUMA_DISCOUNT_HOOK_ADDRESS=<deployed_address>
```

**Configuration**:
- Connects to FUMA token for balance checks
- Default discount tiers:
  - 1,000 FUMA = 10% discount
  - 10,000 FUMA = 25% discount
  - 100,000 FUMA = 50% discount
  - 1,000,000 FUMA = 75% discount

**Expected Gas**: ~2,000,000

### 4.2 Deploy Launchpad Hook

```bash
forge script script/hooks/DeployLaunchpadHook.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify

export LAUNCHPAD_HOOK_ADDRESS=<deployed_address>
```

**Expected Gas**: ~2,500,000

---

## Step 5: Configure Protocol

### 5.1 Set Protocol Fee Recipient

```bash
cast send $PROTOCOL_FEE_CONTROLLER_ADDRESS \
  "setProtocolFeeRecipient(address)" \
  $TREASURY_ADDRESS \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

### 5.2 Set Default Protocol Fee

```bash
# Set 0.05% protocol fee (500 basis points out of 1,000,000)
cast send $PROTOCOL_FEE_CONTROLLER_ADDRESS \
  "setProtocolFee(uint24)" \
  500 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

### 5.3 Transfer Ownership to Governance

```bash
# Transfer Vault ownership
cast send $VAULT_ADDRESS \
  "transferOwnership(address)" \
  $GOVERNANCE_ADDRESS \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY

# Transfer Protocol Fee Controller ownership
cast send $PROTOCOL_FEE_CONTROLLER_ADDRESS \
  "transferOwnership(address)" \
  $GOVERNANCE_ADDRESS \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

---

## Step 6: Initialize Pools

### 6.1 Create WFUMA/USDC Pool

```bash
forge script script/pools/InitializeWFUMA_USDC.s.sol \
  --rpc-url $RPC_URL \
  --broadcast

# Pool parameters:
# - Fee: 0.3% (3000)
# - Tick spacing: 60
# - Hook: FUMA Discount Hook
```

### 6.2 Create WFUMA/USDT Pool

```bash
forge script script/pools/InitializeWFUMA_USDT.s.sol \
  --rpc-url $RPC_URL \
  --broadcast
```

### 6.3 Add Initial Liquidity

```bash
# Add liquidity to WFUMA/USDC pool
forge script script/pools/AddInitialLiquidity.s.sol \
  --rpc-url $RPC_URL \
  --broadcast

# Recommended initial liquidity:
# - WFUMA: 10,000 tokens
# - USDC: 10,000 tokens
# - Price range: Full range initially
```

---

## Step 7: Verify Deployment

### 7.1 Check Contract Deployments

```bash
# Verify Vault
cast call $VAULT_ADDRESS "owner()" --rpc-url $RPC_URL

# Verify CL Pool Manager
cast call $CL_POOL_MANAGER_ADDRESS "vault()" --rpc-url $RPC_URL

# Verify Position Manager
cast call $CL_POSITION_MANAGER_ADDRESS "vault()" --rpc-url $RPC_URL
```

### 7.2 Test Swap

```bash
# Execute test swap
forge script script/test/TestSwap.s.sol \
  --rpc-url $RPC_URL \
  --broadcast

# This will:
# 1. Approve tokens
# 2. Execute a small swap
# 3. Verify the result
```

### 7.3 Verify on Explorer

Visit your block explorer and verify all contracts are properly verified and visible.

---

## Step 8: Update Frontend Configuration

Update the contract addresses in your frontend application:

**File**: `fushuma-gov-hub-v2/src/lib/fumaswap/contracts.ts`

```typescript
export const FUMASWAP_CONTRACTS = {
  // Core
  vault: '0x...',  // VAULT_ADDRESS
  clPoolManager: '0x...',  // CL_POOL_MANAGER_ADDRESS
  binPoolManager: '0x...',  // BIN_POOL_MANAGER_ADDRESS (if deployed)
  
  // Periphery
  clPositionManager: '0x...',  // CL_POSITION_MANAGER_ADDRESS
  infinityRouter: '0x...',  // INFINITY_ROUTER_ADDRESS
  clQuoter: '0x...',  // CL_QUOTER_ADDRESS
  mixedQuoter: '0x...',  // MIXED_QUOTER_ADDRESS
  
  // Hooks
  fumaDiscountHook: '0x...',  // FUMA_DISCOUNT_HOOK_ADDRESS
  launchpadHook: '0x...',  // LAUNCHPAD_HOOK_ADDRESS
  
  // Tokens
  wfuma: '0x...',  // WFUMA_ADDRESS
} as const;
```

---

## Step 9: Deploy Subgraph

Deploy The Graph subgraph for indexing pool data:

```bash
cd subgraph/

# Update subgraph.yaml with deployed addresses
# Then deploy
graph deploy --node https://api.thegraph.com/deploy/ \
  --ipfs https://api.thegraph.com/ipfs/ \
  fushuma/fumaswap-v4
```

See [Subgraph Deployment Guide](../subgraph/README.md) for details.

---

## Post-Deployment Checklist

- [ ] All core contracts deployed and verified
- [ ] All periphery contracts deployed and verified
- [ ] Custom hooks deployed and configured
- [ ] Protocol fees configured
- [ ] Ownership transferred to governance
- [ ] Initial pools created
- [ ] Initial liquidity added
- [ ] Test swaps executed successfully
- [ ] Frontend updated with contract addresses
- [ ] Subgraph deployed and syncing
- [ ] Documentation updated
- [ ] Security audit completed (REQUIRED before mainnet)

---

## Deployment Costs Summary

| Component | Estimated Gas | Est. Cost (at 1 gwei) |
|-----------|---------------|----------------------|
| WFUMA | 1,000,000 | 0.001 FUMA |
| Core Contracts | 17,000,000 | 0.017 FUMA |
| Periphery | 13,000,000 | 0.013 FUMA |
| Hooks | 4,500,000 | 0.0045 FUMA |
| Configuration | 500,000 | 0.0005 FUMA |
| **Total** | **~36,000,000** | **~0.036 FUMA** |

*Actual costs depend on network gas prices*

---

## Troubleshooting

### Deployment Fails

```bash
# Check gas price
cast gas-price --rpc-url $RPC_URL

# Check account balance
cast balance $DEPLOYER_ADDRESS --rpc-url $RPC_URL

# Increase gas limit if needed
forge script <script> --gas-limit 30000000
```

### Verification Fails

```bash
# Manual verification
forge verify-contract \
  --chain-id $CHAIN_ID \
  --compiler-version v0.8.20 \
  $CONTRACT_ADDRESS \
  src/path/to/Contract.sol:ContractName
```

### Pool Initialization Fails

- Ensure tokens are approved
- Check tick spacing is valid
- Verify hook address is correct
- Ensure initial price (sqrtPriceX96) is calculated correctly

---

## Support

For deployment assistance:
- **Email**: dev@fushuma.com
- **Discord**: [Join our community](https://discord.gg/fushuma)
- **Docs**: [docs.fushuma.com](https://docs.fushuma.com)

---

**Last Updated**: November 11, 2025
**Status**: Ready for testnet deployment
