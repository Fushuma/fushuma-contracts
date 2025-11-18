# DeFi Contracts Redeployment Guide
## Shanghai EVM / Solidity 0.8.20 Migration

**Date:** November 18, 2025  
**Purpose:** Replace currently deployed DeFi contracts (Solidity 0.8.26/Cancun) with Shanghai EVM / Solidity 0.8.20 versions  
**Repository:** `/home/ubuntu/fushuma-contracts`

---

## Executive Summary

**Current Situation:**
- ❌ Deployed contracts use Solidity **0.8.26** (Cancun EVM)
- ❌ Use transient storage (Cancun-specific)
- ❌ NOT compatible with Shanghai EVM requirement

**Solution:**
- ✅ Redeploy all contracts with Solidity **0.8.20** (Shanghai EVM)
- ✅ Use regular storage instead of transient storage
- ✅ Full Shanghai EVM compatibility

---

## Deployment Order

Contracts **MUST** be deployed in this exact order due to dependencies:

### Phase 1: Core Contracts
1. **Vault** - Central liquidity vault
2. **CLPoolManager** - Concentrated Liquidity pool manager
3. **BinPoolManager** - Bin-based pool manager

### Phase 2: Periphery Contracts - CL
4. **CLPositionDescriptor** - NFT position descriptor
5. **CLPositionManager** - Manage CL positions
6. **CLQuoter** - Quote CL swaps

### Phase 3: Periphery Contracts - Bin
7. **BinPositionManager** - Manage Bin positions
8. **BinQuoter** - Quote Bin swaps

### Phase 4: Advanced Quoter
9. **MixedQuoter** - ✨ **NEW!** Quote across multiple pool types (now Shanghai-compatible!)

### Phase 5: Routers
10. **InfinityRouter** - Base router contract
11. **UniversalRouter** - Universal swap router

### Phase 6: Supporting (if needed)
12. **Permit2** - Signature-based approvals (may already exist at canonical address)
13. **WFUMA** - Wrapped FUMA (may already be deployed)

---

## Prerequisites

### 1. Environment Setup

```bash
# Navigate to contracts directory
cd /home/ubuntu/fushuma-contracts

# Ensure Foundry is in PATH
export PATH="$HOME/.foundry/bin:$PATH"

# Verify configuration
cat foundry.toml | grep -E "solc_version|evm_version"
# Should show:
# solc_version = "0.8.20"
# evm_version = "shanghai"
```

### 2. Set Environment Variables

```bash
# Set your deployer private key
export PRIVATE_KEY="your_private_key_here"

# Set RPC URL
export RPC_URL="https://rpc.fushuma.com"

# Optional: Set explorer API key for verification
export FUSHUMA_EXPLORER_API_KEY="your_api_key_here"

# Verify deployer has sufficient FUMA for gas
cast balance $(cast wallet address --private-key $PRIVATE_KEY) --rpc-url $RPC_URL
```

### 3. Verify Compilation

```bash
# Clean previous builds
forge clean

# Build all contracts
forge build --skip test --skip script

# Verify build succeeded
ls -la out/Vault.sol/Vault.json
ls -la out/CLPoolManager.sol/CLPoolManager.json
ls -la out/UniversalRouter.sol/UniversalRouter.json

# Check Solidity version in compiled bytecode
cat out/Vault.sol/Vault.json | jq -r '.deployedBytecode.object' | tail -c 100
# Should contain: 6f6c634300081400 (0x0814 = 0.8.20)
```

---

## Deployment Commands

### Phase 1: Deploy Core Contracts

```bash
# Deploy Vault, CLPoolManager, BinPoolManager
forge script script/FushumaDeployCore.s.sol:FushumaDeployCore \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --legacy \
    --slow

# Save the output addresses!
# Example output:
# Vault:           0x...
# CLPoolManager:   0x...
# BinPoolManager:  0x...

# Set environment variables for next phases
export VAULT_ADDRESS="0x..."
export CL_POOL_MANAGER="0x..."
export BIN_POOL_MANAGER="0x..."
```

**⚠️ IMPORTANT:** Save these addresses immediately! You'll need them for:
- Frontend configuration
- Subsequent deployments
- Contract verification

### Phase 2: Deploy CL Periphery

```bash
# Deploy CLPositionDescriptor, CLPositionManager, CLQuoter
forge script script/DeployPositionManagers.s.sol:DeployPositionManagers \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --legacy \
    --slow \
    --sig "run(address,address)" \
    $VAULT_ADDRESS \
    $CL_POOL_MANAGER

# Save addresses
export CL_POSITION_DESCRIPTOR="0x..."
export CL_POSITION_MANAGER="0x..."
export CL_QUOTER="0x..."
```

### Phase 3: Deploy Bin Periphery

```bash
# Deploy BinPositionManager, BinQuoter
forge script script/DeployPeriphery.s.sol:DeployPeriphery \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --legacy \
    --slow \
    --sig "run(address,address)" \
    $VAULT_ADDRESS \
    $BIN_POOL_MANAGER

# Save addresses
export BIN_POSITION_MANAGER="0x..."
export BIN_QUOTER="0x..."
```

### Phase 4: Deploy MixedQuoter (NEW!)

```bash
# MixedQuoter is now Shanghai-compatible!
forge script script/DeployQuoters.s.sol:DeployQuoters \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --legacy \
    --slow \
    --sig "run(address,address,address)" \
    $VAULT_ADDRESS \
    $CL_POOL_MANAGER \
    $BIN_POOL_MANAGER

# Save address
export MIXED_QUOTER="0x..."
```

### Phase 5: Deploy Routers

```bash
# Check if Permit2 exists at canonical address
cast code 0x000000000022D473030F116dDEE9F6B43aC78BA3 --rpc-url $RPC_URL

# If empty, deploy Permit2 first
# If exists, use canonical address
export PERMIT2_ADDRESS="0x000000000022D473030F116dDEE9F6B43aC78BA3"

# Deploy UniversalRouter
forge create --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --legacy \
    src/infinity-universal-router/UniversalRouter.sol:UniversalRouter \
    --constructor-args \
    $VAULT_ADDRESS \
    $PERMIT2_ADDRESS \
    $CL_POOL_MANAGER \
    $BIN_POOL_MANAGER

# Save address
export UNIVERSAL_ROUTER="0x..."
```

---

## Post-Deployment Steps

### 1. Verify Contracts on Explorer

```bash
# Verify Vault
forge verify-contract \
    --rpc-url $RPC_URL \
    --etherscan-api-key $FUSHUMA_EXPLORER_API_KEY \
    --compiler-version 0.8.20 \
    $VAULT_ADDRESS \
    src/infinity-core/Vault.sol:Vault

# Repeat for other contracts...
```

### 2. Update Frontend Configuration

Edit `/home/ubuntu/fushuma-gov-hub-v2/src/lib/fumaswap/contracts.ts`:

```typescript
export const FUSHUMA_CONTRACTS = {
  // Core Contracts (Shanghai EVM / Solidity 0.8.20)
  vault: '0x...', // NEW ADDRESS
  clPoolManager: '0x...', // NEW ADDRESS
  binPoolManager: '0x...', // NEW ADDRESS
  
  // Periphery Contracts - Concentrated Liquidity
  clQuoter: '0x...', // NEW ADDRESS
  clPositionDescriptor: '0x...', // NEW ADDRESS
  clPositionManager: '0x...', // NEW ADDRESS
  
  // Periphery Contracts - Bin Pools
  binQuoter: '0x...', // NEW ADDRESS
  binPositionManager: '0x...', // NEW ADDRESS
  
  // Router
  infinityRouter: '0x...', // NEW ADDRESS
  universalRouter: '0x...', // NEW ADDRESS
  mixedQuoter: '0x...', // NEW ADDRESS - Now available!
  
  // Standard Contracts
  permit2: '0x000000000022D473030F116dDEE9F6B43aC78BA3',
  wfuma: '0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E',
} as const;
```

Update the comment:

```typescript
/**
 * FumaSwap V4 Contract Addresses on Fushuma Network
 * 
 * Shanghai EVM Compatible Version - Deployed Nov 18, 2025
 * Solidity 0.8.20 with regular storage (no transient storage)
 * All contracts deployed and operational
 */
```

### 3. Update ABIs (if needed)

If contract interfaces changed:

```bash
# Copy new ABIs to frontend
cp out/Vault.sol/Vault.json \
   /home/ubuntu/fushuma-gov-hub-v2/src/lib/fumaswap/abis/Vault.json

cp out/CLPoolManager.sol/CLPoolManager.json \
   /home/ubuntu/fushuma-gov-hub-v2/src/lib/fumaswap/abis/CLPoolManager.json

cp out/UniversalRouter.sol/UniversalRouter.json \
   /home/ubuntu/fushuma-gov-hub-v2/src/lib/fumaswap/abis/UniversalRouter.json

# Add MixedQuoter ABI (new!)
cp out/MixedQuoter.sol/MixedQuoter.json \
   /home/ubuntu/fushuma-gov-hub-v2/src/lib/fumaswap/abis/MixedQuoter.json
```

### 4. Test Frontend Integration

```bash
cd /home/ubuntu/fushuma-gov-hub-v2

# Install dependencies
pnpm install

# Start development server
pnpm dev

# Open browser and test:
# 1. Connect wallet
# 2. Try token swap
# 3. Add liquidity
# 4. Check positions
# 5. Verify no console errors
```

### 5. Create Initial Pools

```bash
# Create WFUMA/USDC pool (example)
# Use frontend or direct contract interaction

# Add initial liquidity
# Monitor pool creation events
```

---

## Verification Checklist

### Pre-Deployment
- [ ] Foundry installed and updated
- [ ] Private key set in environment
- [ ] Deployer has sufficient FUMA for gas (~5-10 FUMA recommended)
- [ ] RPC URL is correct
- [ ] Contracts compile successfully
- [ ] Bytecode shows Solidity 0.8.20 (`0814`)

### During Deployment
- [ ] Core contracts deployed (Vault, CLPoolManager, BinPoolManager)
- [ ] CLPoolManager registered with Vault
- [ ] BinPoolManager registered with Vault
- [ ] CL periphery deployed
- [ ] Bin periphery deployed
- [ ] MixedQuoter deployed (new!)
- [ ] Routers deployed
- [ ] All addresses saved

### Post-Deployment
- [ ] Contracts verified on explorer
- [ ] Frontend addresses updated
- [ ] ABIs updated (if needed)
- [ ] Frontend builds without errors
- [ ] Wallet connection works
- [ ] Token swaps work
- [ ] Liquidity operations work
- [ ] Position management works
- [ ] No console errors

---

## Troubleshooting

### Issue: "Insufficient funds for gas"

**Solution:**
```bash
# Check balance
cast balance $(cast wallet address --private-key $PRIVATE_KEY) --rpc-url $RPC_URL

# Get FUMA from faucet or transfer from another wallet
```

### Issue: "Contract creation failed"

**Solution:**
```bash
# Try with --legacy flag for EIP-1559 issues
# Increase gas limit with --gas-limit 10000000
# Check deployer nonce: cast nonce <address> --rpc-url $RPC_URL
```

### Issue: "Compilation failed"

**Solution:**
```bash
# Clean and rebuild
forge clean
forge build --skip test --skip script

# Check for syntax errors
forge build --force
```

### Issue: "Frontend shows wrong data"

**Solution:**
```bash
# Clear browser cache
# Verify contract addresses in contracts.ts
# Check ABI files are updated
# Restart development server
```

---

## Rollback Plan

If deployment fails or issues arise:

1. **Keep old addresses** - Frontend can temporarily use old contracts
2. **Deploy to testnet first** - Test full deployment flow
3. **Gradual migration** - Deploy new contracts, test, then update frontend
4. **Monitor closely** - Watch for errors in first 24 hours

**Old Contract Addresses (for reference):**
```
vault: 0x4FB212Ed5038b0EcF2c8322B3c71FC64d66073A1
clPoolManager: 0x9123DeC6d2bE7091329088BA1F8Dc118eEc44f7a
binPoolManager: 0x3014809fBFF942C485A9F527242eC7C5A9ddC765
universalRouter: 0xE489902A6F5926C68B8dc3431FAaF28A73C1AE95
```

---

## Gas Estimates

Approximate gas costs for deployment:

| Contract | Estimated Gas | Approx. Cost (at 1 gwei) |
|----------|--------------|--------------------------|
| Vault | 3,000,000 | 0.003 FUMA |
| CLPoolManager | 4,500,000 | 0.0045 FUMA |
| BinPoolManager | 4,500,000 | 0.0045 FUMA |
| CLPositionManager | 5,000,000 | 0.005 FUMA |
| BinPositionManager | 4,000,000 | 0.004 FUMA |
| MixedQuoter | 3,500,000 | 0.0035 FUMA |
| UniversalRouter | 4,000,000 | 0.004 FUMA |
| **Total** | **~30,000,000** | **~0.03 FUMA** |

**Recommended:** Have at least **5-10 FUMA** in deployer wallet for safety.

---

## Key Improvements

### What's New in This Deployment

1. ✅ **Solidity 0.8.20** - Stable, well-tested version
2. ✅ **Shanghai EVM** - Network compatibility
3. ✅ **Regular Storage** - No transient storage dependency
4. ✅ **MixedQuoter Available** - Now Shanghai-compatible!
5. ✅ **Lower Gas Costs** - Optimized for Shanghai
6. ✅ **Better Compatibility** - Works with more tools

### What Changed from Old Deployment

- **Transient Storage → Regular Storage** in 6 libraries
- **Solidity 0.8.26 → 0.8.20** across all contracts
- **Cancun EVM → Shanghai EVM** target
- **New MixedQuoter** - Previously unavailable

---

## Support & Resources

- **Contract Repository:** `/home/ubuntu/fushuma-contracts`
- **Frontend Repository:** `/home/ubuntu/fushuma-gov-hub-v2`
- **Migration Summary:** `/home/ubuntu/fushuma-contracts/SHANGHAI_MIGRATION_SUMMARY.md`
- **Foundry Book:** https://book.getfoundry.sh/
- **Fushuma RPC:** https://rpc.fushuma.com
- **Fushuma Explorer:** https://fumascan.com

---

## Quick Reference Commands

```bash
# Set environment
cd /home/ubuntu/fushuma-contracts
export PATH="$HOME/.foundry/bin:$PATH"
export PRIVATE_KEY="..."
export RPC_URL="https://rpc.fushuma.com"

# Deploy core
forge script script/FushumaDeployCore.s.sol:FushumaDeployCore \
    --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy --slow

# Check deployment
cast code <address> --rpc-url $RPC_URL

# Verify contract
forge verify-contract --rpc-url $RPC_URL <address> <contract_path>

# Update frontend
cd /home/ubuntu/fushuma-gov-hub-v2
# Edit src/lib/fumaswap/contracts.ts
pnpm dev
```

---

**Ready to deploy?** Follow the steps in order, save all addresses, and test thoroughly! 🚀
