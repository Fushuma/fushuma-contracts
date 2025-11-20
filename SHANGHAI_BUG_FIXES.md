# Shanghai EVM Adaptation - Bug Fixes Documentation

## Overview

This document details the critical bug fixes implemented as part of the Shanghai EVM adaptation.

## Bug Fix 1: Pool Initialization Issue

### Problem
Pools cannot be re-initialized even when they appear uninitialized. The check `if (self.slot0.sqrtPriceX96() != 0)` prevents initialization.

### Root Cause
The issue is in `CLPool.sol` line 5: The pool checks if `sqrtPriceX96 != 0` to determine if it's already initialized. However, this check may be too strict or the pool state is not being properly reset.

### Analysis
The current implementation in `src/infinity-core/pool-cl/libraries/CLPool.sol`:
```solidity
function initialize(State storage self, uint160 sqrtPriceX96, uint24 protocolFee, uint24 lpFee)
    internal
    returns (int24 tick)
{
    if (self.slot0.sqrtPriceX96() != 0) revert PoolAlreadyInitialized();
    tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
    self.slot0 = CLSlot0.wrap(bytes32(0)).setSqrtPriceX96(sqrtPriceX96).setTick(tick).setProtocolFee(protocolFee)
        .setLpFee(lpFee);
}
```

### Solution
The pool initialization logic is actually correct. The issue is likely in the deployment/testing process:

1. **Verify Pool ID Calculation**: Ensure the `poolId` calculation is consistent between deployment scripts and contracts
2. **Check Pool State**: Before attempting to initialize, verify the pool state is truly empty
3. **Add Debugging**: Add events to track pool initialization attempts

### Recommended Actions
1. Add a view function to check if a pool is initialized:
```solidity
function isPoolInitialized(PoolId id) external view returns (bool) {
    return pools[id].slot0.sqrtPriceX96() != 0;
}
```

2. Add detailed logging in deployment scripts to show:
   - PoolKey components
   - Calculated PoolId
   - Current pool state before initialization

## Bug Fix 2: Decimal Mismatch (6-decimal tokens)

### Problem
USDT and USDC have 6 decimals, but the protocol may be treating them as 18-decimal tokens, causing users to receive 10^12 times less tokens than expected.

### Root Cause
The `Currency` type in PancakeSwap V4 is a simple wrapper around an address. There's no built-in decimal handling in the core protocol. The protocol assumes all amounts are already in the token's native decimal format.

### Analysis
Looking at the `Currency` type in `src/infinity-core/types/Currency.sol`:
```solidity
type Currency is address;
```

The protocol does NOT normalize decimals internally. This is actually correct behavior - the protocol should handle raw token amounts.

### Where the Issue Occurs
The decimal mismatch likely occurs in:
1. **Frontend**: When users input amounts (e.g., "100 USDT"), the frontend must convert this to `100 * 10^6` (not `100 * 10^18`)
2. **Quoter**: When calculating quotes, it must account for different decimals
3. **Price Calculations**: When displaying prices, must normalize to a common base

### Solution

#### Frontend Fix (CRITICAL)
The frontend must fetch token decimals and use them correctly:

```typescript
// In swap.ts or token utilities
import { erc20ABI } from 'wagmi';

async function getTokenDecimals(tokenAddress: string): Promise<number> {
  const decimals = await readContract({
    address: tokenAddress as `0x${string}`,
    abi: erc20ABI,
    functionName: 'decimals',
  });
  return decimals;
}

async function parseTokenAmount(amount: string, tokenAddress: string): Promise<bigint> {
  const decimals = await getTokenDecimals(tokenAddress);
  return parseUnits(amount, decimals);
}
```

#### Smart Contract Enhancement (Optional)
While the core protocol doesn't need to change, we can add helper functions:

```solidity
// In a new library: src/infinity-core/libraries/TokenHelper.sol
library TokenHelper {
    function getDecimals(Currency currency) internal view returns (uint8) {
        if (currency.isNative()) return 18;
        
        (bool success, bytes memory data) = Currency.unwrap(currency).staticcall(
            abi.encodeWithSignature("decimals()")
        );
        
        if (!success || data.length == 0) return 18; // Default to 18
        return abi.decode(data, (uint8));
    }
    
    function normalizeAmount(Currency currency, uint256 amount) internal view returns (uint256) {
        uint8 decimals = getDecimals(currency);
        if (decimals == 18) return amount;
        if (decimals < 18) {
            return amount * (10 ** (18 - decimals));
        } else {
            return amount / (10 ** (decimals - 18));
        }
    }
}
```

### Recommended Actions

1. **Immediate Frontend Fix**:
   - Update `src/lib/fumaswap/swap.ts` to properly handle token decimals
   - Ensure all amount inputs are parsed with correct decimals
   - Display amounts with correct decimal places

2. **Testing**:
   - Test swaps with 6-decimal tokens (USDT, USDC)
   - Test swaps with 18-decimal tokens (WFUMA)
   - Test mixed swaps (6-decimal <-> 18-decimal)

3. **Documentation**:
   - Document that the protocol uses native token amounts
   - Provide examples for integrators

## Bug Fix 3: Storage Cleanup (New from Shanghai Adaptation)

### Problem
The Storage-as-Transient pattern requires manual cleanup, which introduces a new attack vector if not done correctly.

### Solution
The `_cleanupTransientStorage()` function in `Vault.sol` handles this:

```solidity
function _cleanupTransientStorage() internal {
    for (uint256 i = 0; i < writtenSlots.length; i++) {
        bytes32 slot = writtenSlots[i];
        delete transientStorageMock[slot];
        delete isSlotWritten[slot];
    }
    delete writtenSlots;
}
```

This is called at the end of every `lock()` transaction, ensuring no dirty state persists.

### Security Considerations
1. The `lock()` function MUST revert if `deltaCount != 0` before cleanup
2. The cleanup MUST happen even if the callback reverts (handled by EVM revert)
3. Re-entrancy is prevented by checking `currentLocker != address(0)`

## Summary of Changes

### Modified Files
1. `src/infinity-core/Vault.sol` - Implemented Storage-as-Transient pattern
2. `src/infinity-core/Extsload.sol` - Added exttload virtual functions
3. `src/infinity-core/pool-cl/CLPoolManager.sol` - Added exttload override
4. `src/infinity-core/pool-bin/BinPoolManager.sol` - Added exttload override

### No Changes Required (But Verification Needed)
1. Pool initialization logic - Already correct
2. Decimal handling in contracts - Already correct (uses native amounts)

### Frontend Changes Required
1. Token decimal handling in swap interface
2. Amount parsing and formatting
3. Price display normalization

## Testing Checklist

- [ ] Deploy contracts to testnet
- [ ] Initialize a pool with 6-decimal token (USDT/WFUMA)
- [ ] Initialize a pool with 18-decimal tokens (WFUMA/WETH)
- [ ] Execute swap: 6-decimal -> 18-decimal
- [ ] Execute swap: 18-decimal -> 6-decimal
- [ ] Verify output amounts are correct
- [ ] Test frontend with corrected decimal handling
- [ ] Verify exttload proxy works for Quoter
- [ ] Test multi-hop swaps
- [ ] Verify storage cleanup after each transaction
