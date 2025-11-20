# Shanghai EVM Adaptation - Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the Shanghai-adapted Fushuma DeFi contracts.

## Pre-Deployment Checklist

- [ ] All code changes committed to `shanghai-evm-adaptation` branch
- [ ] Foundry configuration set to Shanghai EVM
- [ ] Environment variables configured
- [ ] Deployer wallet funded with sufficient FUMA
- [ ] RPC endpoint verified and accessible

## Configuration

### 1. Foundry Configuration

Verify `foundry.toml` has the correct settings:

```toml
[profile.default]
evm_version = "shanghai"
solc_version = "0.8.20"
optimizer = true
optimizer_runs = 200

[rpc_endpoints]
fushuma = "https://rpc.fushuma.com"
```

### 2. Environment Variables

Create or update `.env`:

```bash
# Network Configuration
RPC_URL=https://rpc.fushuma.com
CHAIN_ID=121224

# Deployer Configuration
PRIVATE_KEY=<your_private_key>
DEPLOYER_ADDRESS=<your_address>

# Contract Addresses (if redeploying)
VAULT_ADDRESS=0xcf842B77660E0EcEBD24fB3f860D2197d249f4E4
CL_POOL_MANAGER_ADDRESS=0xef02f995FEC090E21709A0e21709A7eBAc2197d2
BIN_POOL_MANAGER_ADDRESS=0xCF6C0074c43C00234C83D0f009Bf1db933EbF280

# Token Addresses
WFUMA_ADDRESS=0x0000000000000000000000000000000000000000
USDT_ADDRESS=0x1234567890123456789012345678901234567890
USDC_ADDRESS=0x0987654321098765432109876543210987654321
```

## Deployment Steps

### Step 1: Compile Contracts

```bash
cd /home/ubuntu/fushuma-contracts
forge clean
forge build
```

Verify compilation succeeds with no errors.

### Step 2: Deploy Vault (If Needed)

If deploying a new Vault:

```bash
forge create src/infinity-core/Vault.sol:Vault \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --legacy
```

Save the deployed address to `.env` as `VAULT_ADDRESS`.

### Step 3: Deploy Pool Managers

#### Deploy CLPoolManager

```bash
forge create src/infinity-core/pool-cl/CLPoolManager.sol:CLPoolManager \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --constructor-args $VAULT_ADDRESS \
  --legacy
```

#### Deploy BinPoolManager

```bash
forge create src/infinity-core/pool-bin/BinPoolManager.sol:BinPoolManager \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --constructor-args $VAULT_ADDRESS \
  --legacy
```

### Step 4: Register Pool Managers with Vault

```bash
# Register CLPoolManager
cast send $VAULT_ADDRESS \
  "registerApp(address)" \
  $CL_POOL_MANAGER_ADDRESS \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --legacy

# Register BinPoolManager
cast send $VAULT_ADDRESS \
  "registerApp(address)" \
  $BIN_POOL_MANAGER_ADDRESS \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --legacy
```

### Step 5: Deploy Peripheral Contracts

#### Deploy CLQuoter

```bash
forge create src/infinity-periphery/pool-cl/CLQuoter.sol:CLQuoter \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --constructor-args $CL_POOL_MANAGER_ADDRESS \
  --legacy
```

#### Deploy BinQuoter

```bash
forge create src/infinity-periphery/pool-bin/BinQuoter.sol:BinQuoter \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --constructor-args $BIN_POOL_MANAGER_ADDRESS \
  --legacy
```

#### Deploy Position Managers

```bash
# CLPositionManager
forge create src/infinity-periphery/pool-cl/CLPositionManager.sol:CLPositionManager \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --constructor-args $VAULT_ADDRESS $CL_POOL_MANAGER_ADDRESS $WFUMA_ADDRESS \
  --legacy

# BinPositionManager
forge create src/infinity-periphery/pool-bin/BinPositionManager.sol:BinPositionManager \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --constructor-args $VAULT_ADDRESS $BIN_POOL_MANAGER_ADDRESS $WFUMA_ADDRESS \
  --legacy
```

### Step 6: Verify Contracts

Verify each deployed contract on the block explorer:

```bash
forge verify-contract \
  --chain-id $CHAIN_ID \
  --compiler-version 0.8.20 \
  --constructor-args $(cast abi-encode "constructor(address)" $VAULT_ADDRESS) \
  $CL_POOL_MANAGER_ADDRESS \
  src/infinity-core/pool-cl/CLPoolManager.sol:CLPoolManager
```

Repeat for all contracts.

### Step 7: Initialize Test Pools

Create a script to initialize pools:

```bash
# WFUMA/USDT Pool (0.3% fee)
cast send $CL_POOL_MANAGER_ADDRESS \
  "initialize((address,address,address,address,uint24,bytes32),uint160)" \
  "($WFUMA_ADDRESS,$USDT_ADDRESS,$CL_POOL_MANAGER_ADDRESS,0x0000000000000000000000000000000000000000,3000,0x0000000000000000000000000000000000000000000000000000000000000000)" \
  "79228162514264337593543950336" \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --legacy
```

### Step 8: Post-Deployment Verification

Run verification tests:

```bash
# Check Vault is registered
cast call $VAULT_ADDRESS "isAppRegistered(address)" $CL_POOL_MANAGER_ADDRESS --rpc-url $RPC_URL

# Check exttload proxy works
cast call $CL_POOL_MANAGER_ADDRESS "exttload(bytes32)" 0x0000000000000000000000000000000000000000000000000000000000000000 --rpc-url $RPC_URL

# Check transientStorageMock is accessible
cast call $VAULT_ADDRESS "transientStorageMock(bytes32)" 0x0000000000000000000000000000000000000000000000000000000000000000 --rpc-url $RPC_URL
```

## Update Frontend Configuration

Update the frontend contract addresses in `fushuma-gov-hub-v2/src/lib/fumaswap/contracts.ts`:

```typescript
export const CONTRACT_ADDRESSES = {
  vault: '0x<NEW_VAULT_ADDRESS>',
  clPoolManager: '0x<NEW_CL_POOL_MANAGER_ADDRESS>',
  binPoolManager: '0x<NEW_BIN_POOL_MANAGER_ADDRESS>',
  clQuoter: '0x<NEW_CL_QUOTER_ADDRESS>',
  binQuoter: '0x<NEW_BIN_QUOTER_ADDRESS>',
  clPositionManager: '0x<NEW_CL_POSITION_MANAGER_ADDRESS>',
  binPositionManager: '0x<NEW_BIN_POSITION_MANAGER_ADDRESS>',
  // ... other addresses
};
```

## Security Considerations

1. **Transfer Ownership**: After deployment, transfer ownership of all contracts to a multisig wallet:

```bash
cast send $VAULT_ADDRESS "transferOwnership(address)" $MULTISIG_ADDRESS --rpc-url $RPC_URL --private-key $PRIVATE_KEY --legacy
```

2. **Set Protocol Fees**: Configure protocol fees if needed

3. **Pause Mechanism**: Verify pause functionality works

4. **Emergency Contacts**: Set up monitoring and alert systems

## Rollback Plan

If issues are discovered post-deployment:

1. **Pause Contracts**: Use pause functionality to stop new transactions
2. **Notify Users**: Communicate the issue and expected resolution time
3. **Deploy Fix**: Deploy corrected contracts to new addresses
4. **Migrate State**: If possible, migrate critical state (liquidity positions)
5. **Update Frontend**: Point to new contract addresses

## Testing on Mainnet

Before announcing the launch:

1. Execute a small test swap (e.g., 1 WFUMA -> USDT)
2. Add a small amount of liquidity
3. Remove the liquidity
4. Verify all events are emitted correctly
5. Check gas costs are reasonable

## Launch Checklist

- [ ] All contracts deployed and verified
- [ ] Ownership transferred to multisig
- [ ] Test pools initialized with liquidity
- [ ] Frontend updated with new addresses
- [ ] Test transactions executed successfully
- [ ] Monitoring and alerts configured
- [ ] Documentation updated
- [ ] Announcement prepared

## Support and Monitoring

### Monitoring Tools
- Block explorer: https://explorer.fushuma.com
- RPC status: https://rpc.fushuma.com/health
- Grafana dashboard: (to be configured)

### Emergency Contacts
- Technical Lead: [Contact Info]
- Security Team: [Contact Info]
- Community Manager: [Contact Info]

## Appendix: Contract Addresses Template

```markdown
# Fushuma DeFi - Shanghai Adapted Contracts

Deployed on: [DATE]
Network: Fushuma Mainnet (Chain ID: 121224)

## Core Contracts
- Vault: 0x...
- CLPoolManager: 0x...
- BinPoolManager: 0x...

## Peripheral Contracts
- CLQuoter: 0x...
- BinQuoter: 0x...
- CLPositionManager: 0x...
- BinPositionManager: 0x...
- CLPositionDescriptor: 0x...
- UniversalRouter: 0x...
- Permit2: 0x...

## Token Addresses
- WFUMA: 0x...
- USDT: 0x...
- USDC: 0x...
```
