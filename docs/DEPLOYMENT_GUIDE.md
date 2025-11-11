# Fushuma Smart Contracts Deployment Guide

This guide provides detailed instructions for deploying all Fushuma Network smart contracts to production.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Pre-Deployment Checklist](#pre-deployment-checklist)
3. [Deployment Steps](#deployment-steps)
4. [Post-Deployment](#post-deployment)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Software Requirements

1. **Foundry** (latest version)
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Node.js** (v18 or higher)
   ```bash
   node --version  # Should be v18+
   ```

3. **Git**
   ```bash
   git --version
   ```

### Account Requirements

1. **Deployer Wallet**
   - Private key with sufficient FUMA tokens
   - Recommended: 1+ FUMA for gas fees
   - Keep private key secure and never commit to git

2. **Network Access**
   - Stable internet connection
   - Access to Fushuma RPC: https://rpc.fushuma.com

### Knowledge Requirements

- Basic understanding of smart contracts
- Familiarity with command line operations
- Understanding of blockchain transactions

## Pre-Deployment Checklist

### 1. Environment Setup

```bash
# Clone the repository
git clone https://github.com/Fushuma/fushuma-contracts.git
cd fushuma-contracts

# Copy environment template
cp .env.example .env

# Edit .env with your private key
nano .env
```

### 2. Verify Network Connectivity

```bash
# Check RPC connection
cast block-number --rpc-url https://rpc.fushuma.com

# Check deployer balance
export PRIVATE_KEY=0x...
DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)
cast balance $DEPLOYER --rpc-url https://rpc.fushuma.com
```

### 3. Test Compilation

```bash
# Compile all contracts
forge build

# Ensure no compilation errors
```

### 4. Run Tests (if available)

```bash
# Run all tests
forge test

# Ensure all tests pass
```

## Deployment Steps

### Phase 1: Deploy WFUMA (Critical - Day 1)

WFUMA is the foundation for all DeFi operations and must be deployed first.

#### Step 1.1: Deploy WFUMA Contract

```bash
export PRIVATE_KEY=0x...
./scripts/deploy-wfuma.sh
```

**Expected Output:**
```
=========================================
✓ WFUMA Deployment Successful!
=========================================

Contract Address: 0x...
Explorer: https://explorer.fushuma.com/address/0x...
```

#### Step 1.2: Verify WFUMA Deployment

```bash
# Check contract code
WFUMA_ADDRESS=0x...  # From deployment output
cast code $WFUMA_ADDRESS --rpc-url https://rpc.fushuma.com

# Test wrap functionality
cast send $WFUMA_ADDRESS "deposit()" \
  --value 0.1ether \
  --private-key $PRIVATE_KEY \
  --rpc-url https://rpc.fushuma.com

# Check WFUMA balance
cast call $WFUMA_ADDRESS "balanceOf(address)" $DEPLOYER \
  --rpc-url https://rpc.fushuma.com
```

#### Step 1.3: Update Configuration

Update the WFUMA address in the main repository:

**File**: `fushuma-gov-hub-v2/src/lib/fumaswap/contracts.ts`

```typescript
export const FUSHUMA_CONTRACTS = {
  // ...
  wfuma: '0x...', // Your deployed WFUMA address
  // ...
}

export const COMMON_TOKENS = {
  // ...
  WFUMA: '0x...', // Your deployed WFUMA address
  // ...
}
```

### Phase 2: Check Permit2 (Critical - Day 1)

Permit2 is typically deployed at a canonical address across all chains.

#### Step 2.1: Check if Permit2 Exists

```bash
PERMIT2_ADDRESS=0x000000000022D473030F116dDEE9F6B43aC78BA3
cast code $PERMIT2_ADDRESS --rpc-url https://rpc.fushuma.com
```

**If code exists**: Permit2 is already deployed, skip to Phase 3.

**If no code**: Permit2 needs to be deployed (see below).

#### Step 2.2: Deploy Permit2 (if needed)

```bash
# Clone Permit2 repository
git clone https://github.com/Uniswap/permit2.git
cd permit2

# Install dependencies
forge install

# Deploy
forge create src/Permit2.sol:Permit2 \
  --rpc-url https://rpc.fushuma.com \
  --private-key $PRIVATE_KEY \
  --legacy
```

**Note**: If deployed to a different address than canonical, update `src/lib/fumaswap/contracts.ts`.

### Phase 3: Deploy Core DeFi Contracts (Critical - Days 2-4)

**⚠️ Important**: Core DeFi contracts (Vault, Pool Managers) require the actual FumaSwap V4 implementation. These contracts are complex and should be:

1. Sourced from the official FumaSwap/PancakeSwap V4 repositories
2. Adapted for Fushuma Network
3. Thoroughly tested on testnet first
4. Audited by professional security firms

**Recommended Approach**:

```bash
# Clone PancakeSwap V4 (or FumaSwap if available)
git clone https://github.com/pancakeswap/pancake-v4-core.git
cd pancake-v4-core

# Review and adapt for Fushuma Network
# - Update chain ID references
# - Update fee structures if needed
# - Test thoroughly

# Deploy Vault
forge script script/DeployVault.s.sol \
  --rpc-url https://rpc.fushuma.com \
  --private-key $PRIVATE_KEY \
  --broadcast

# Deploy CLPoolManager
forge script script/DeployCLPoolManager.s.sol \
  --rpc-url https://rpc.fushuma.com \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Phase 4: Deploy Periphery Contracts (High Priority - Days 5-7)

Periphery contracts include routers, quoters, and position managers.

**Note**: These also require the official FumaSwap V4 periphery implementation.

```bash
# Clone periphery repository
git clone https://github.com/pancakeswap/pancake-v4-periphery.git
cd pancake-v4-periphery

# Deploy contracts in order
# 1. CLPositionManager
# 2. InfinityRouter
# 3. CLQuoter
# 4. MixedQuoter
```

### Phase 5: Deploy Custom Hooks (Medium Priority - Days 8-10)

Custom hooks require implementation based on specifications.

**FumaDiscountHook**: Provides fee discounts for FUMA token holders
**LaunchpadHook**: Integrates with the launchpad for special pool features

These need to be developed according to the FumaSwap V4 hook interface.

## Post-Deployment

### 1. Update All Configuration Files

After each deployment, update:

1. **Main Repository Config**
   - `fushuma-gov-hub-v2/src/lib/fumaswap/contracts.ts`
   - Update all deployed addresses

2. **Environment Variables**
   - Update `.env` in the main repository
   - Set all `NEXT_PUBLIC_*_ADDRESS` variables

3. **Documentation**
   - Update README.md with deployed addresses
   - Document any deployment issues or notes

### 2. Verify Contracts on Explorer

```bash
# Verify WFUMA
forge verify-contract $WFUMA_ADDRESS \
  contracts/tokens/WFUMA.sol:WFUMA \
  --chain 121224 \
  --rpc-url https://rpc.fushuma.com

# Verify other contracts similarly
```

### 3. Test Integration

```bash
# Test from frontend
# 1. Connect wallet to governance2.fushuma.com
# 2. Navigate to DeFi section
# 3. Test wrap/unwrap FUMA
# 4. Test token approvals
# 5. Test swap quotes (once routers deployed)
```

### 4. Create Initial Liquidity Pools

Once all contracts are deployed:

```bash
# Create WFUMA/USDC pool
# Create WFUMA/USDT pool
# Create USDC/USDT pool

# Add initial liquidity to each pool
```

## Verification

### Contract Verification Checklist

- [ ] WFUMA deployed and verified
- [ ] Permit2 exists or deployed
- [ ] Vault deployed and verified
- [ ] CLPoolManager deployed and verified
- [ ] CLPositionManager deployed and verified
- [ ] InfinityRouter deployed and verified
- [ ] All quoters deployed and verified
- [ ] All addresses updated in config files
- [ ] All contracts verified on block explorer
- [ ] Integration tests passing
- [ ] Initial pools created
- [ ] Initial liquidity added

### Functional Testing

Test each function:

1. **WFUMA**
   - [ ] Deposit (wrap) FUMA
   - [ ] Withdraw (unwrap) FUMA
   - [ ] Transfer WFUMA
   - [ ] Approve WFUMA

2. **Pools** (once deployed)
   - [ ] Create pool
   - [ ] Add liquidity
   - [ ] Remove liquidity
   - [ ] Swap tokens

3. **Positions** (once deployed)
   - [ ] Mint position
   - [ ] Increase liquidity
   - [ ] Decrease liquidity
   - [ ] Collect fees
   - [ ] Burn position

## Troubleshooting

### Common Issues

#### Issue: "Insufficient funds for gas"

**Solution**: Ensure deployer wallet has enough FUMA tokens.

```bash
# Check balance
cast balance $DEPLOYER --rpc-url https://rpc.fushuma.com

# If needed, transfer FUMA to deployer
```

#### Issue: "Nonce too low"

**Solution**: Transaction already processed or nonce mismatch.

```bash
# Check current nonce
cast nonce $DEPLOYER --rpc-url https://rpc.fushuma.com

# Wait for pending transactions to complete
```

#### Issue: "Contract creation code storage out of gas"

**Solution**: Contract too large, needs optimization.

```bash
# Enable via-ir in foundry.toml
via_ir = true

# Rebuild
forge build
```

#### Issue: "RPC connection failed"

**Solution**: Check network connectivity and RPC URL.

```bash
# Test RPC
curl -X POST https://rpc.fushuma.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### Getting Help

If you encounter issues:

1. Check the [Troubleshooting Guide](./TROUBLESHOOTING.md)
2. Review deployment logs in `deployment-info.json`
3. Ask in Discord: https://discord.gg/fushuma
4. Email: dev@fushuma.com

## Security Considerations

### Before Production Deployment

1. **Security Audit**: All contracts must be audited by professional firms
2. **Testnet Testing**: Deploy and test on testnet first
3. **Multi-sig**: Use multi-signature wallet for contract ownership
4. **Timelock**: Implement timelock for critical operations
5. **Emergency Pause**: Ensure pause mechanisms are in place

### Private Key Security

- Never commit private keys to git
- Use hardware wallets for production deployments
- Store private keys in secure key management systems
- Use different keys for testnet and mainnet

### Post-Deployment Security

1. Transfer contract ownership to multi-sig
2. Set up monitoring and alerts
3. Document all admin functions
4. Establish incident response plan

## Timeline Estimate

| Phase | Duration | Contracts |
|-------|----------|-----------|
| Phase 1 | 1 day | WFUMA, Permit2 |
| Phase 2 | 3-4 days | Core contracts |
| Phase 3 | 3 days | Periphery contracts |
| Phase 4 | 3 days | Custom hooks |
| Phase 5 | 2 days | Testing & verification |
| Phase 6 | 2-4 weeks | Security audit |
| **Total** | **4-6 weeks** | Full deployment |

## Next Steps

After successful deployment:

1. Deploy subgraph for data indexing
2. Create initial liquidity pools
3. Launch marketing campaign
4. Monitor system performance
5. Gather user feedback
6. Plan Phase 2 features (staking, farming)

---

**Last Updated**: November 2025  
**Version**: 1.0  
**Maintainer**: Fushuma Development Team
