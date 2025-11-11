# FumaSwap V4 Smart Contracts

FumaSwap V4 is a decentralized exchange (DEX) built on the Fushuma Network, based on PancakeSwap V4 (Infinity) architecture.

## Overview

FumaSwap V4 implements a modular, hook-based AMM design with the following key features:

- **Concentrated Liquidity (CL)**: Capital-efficient liquidity provision with custom price ranges
- **Bin Pools**: Alternative pool type for specific use cases
- **Singleton Architecture**: All pools share a single Vault contract for gas optimization
- **Hooks System**: Customizable pool behavior through hook contracts
- **Flash Accounting**: Efficient multi-hop swaps and complex operations
- **Native Token Support**: Direct integration with FUMA (wrapped as WFUMA for trading)

## Architecture

### Core Contracts (`core/`)

**Main Contracts**:
- `Vault.sol` - Central liquidity vault managing all pools
- `ProtocolFees.sol` - Protocol fee collection and distribution
- `ProtocolFeeController.sol` - Fee configuration management

**Pool Managers**:
- `pool-cl/CLPoolManager.sol` - Concentrated liquidity pool manager
- `pool-bin/BinPoolManager.sol` - Bin pool manager (optional)

**Base Contracts**:
- `base/PoolManager.sol` - Base pool manager functionality
- `base/Hooks.sol` - Hook system implementation

### Periphery Contracts (`periphery/`)

**Position Management**:
- `pool-cl/CLPositionManager.sol` - Manage concentrated liquidity positions
- `pool-bin/BinPositionManager.sol` - Manage bin positions

**Routing**:
- `InfinityRouter.sol` - Universal router for swaps and liquidity operations
- `V4Router.sol` - V4-specific routing logic

**Quoters**:
- `pool-cl/CLQuoter.sol` - Get swap quotes for CL pools
- `MixedQuoter.sol` - Cross-pool quote aggregation

**Utilities**:
- `BatchRouter.sol` - Batch multiple operations
- `Permit2Forwarder.sol` - Gasless approvals via Permit2

## Custom Hooks

FumaSwap includes custom hooks for ecosystem integration:

### FumaDiscountHook
Provides fee discounts to FUMA token holders based on their holdings.

**Features**:
- Tiered discount system based on FUMA balance
- Dynamic fee adjustment
- Integration with governance voting power

### LaunchpadHook
Integrates with the Fushuma Launchpad for new token launches.

**Features**:
- Automatic liquidity locking for launched tokens
- Initial liquidity provision
- Anti-bot protection during launch
- Vesting integration

## Deployment

### Prerequisites

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install
```

### Configuration

1. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

2. Configure deployment parameters in `script/config/FumaswapConfig.sol`

### Deploy Core Contracts

```bash
# Deploy Vault and core contracts
forge script script/fumaswap-core/01_DeployCore.s.sol --rpc-url $RPC_URL --broadcast --verify

# Deploy CL Pool Manager
forge script script/fumaswap-core/02_DeployCLPoolManager.s.sol --rpc-url $RPC_URL --broadcast --verify
```

### Deploy Periphery Contracts

```bash
# Deploy Position Manager
forge script script/fumaswap-periphery/01_DeployPositionManager.s.sol --rpc-url $RPC_URL --broadcast --verify

# Deploy Router
forge script script/fumaswap-periphery/02_DeployRouter.s.sol --rpc-url $RPC_URL --broadcast --verify

# Deploy Quoters
forge script script/fumaswap-periphery/03_DeployQuoters.s.sol --rpc-url $RPC_URL --broadcast --verify
```

### Deploy Custom Hooks

```bash
# Deploy FUMA Discount Hook
forge script script/hooks/DeployFumaDiscountHook.s.sol --rpc-url $RPC_URL --broadcast --verify

# Deploy Launchpad Hook
forge script script/hooks/DeployLaunchpadHook.s.sol --rpc-url $RPC_URL --broadcast --verify
```

## Testing

```bash
# Run all tests
forge test

# Run with gas reporting
forge test --gas-report

# Run specific test file
forge test --match-path test/fumaswap-v4/Vault.t.sol

# Generate coverage
forge coverage
```

## Integration

### Creating a Pool

```solidity
import {IVault} from "./interfaces/IVault.sol";
import {ICLPoolManager} from "./interfaces/ICLPoolManager.sol";

// Initialize pool
PoolKey memory key = PoolKey({
    currency0: Currency.wrap(address(token0)),
    currency1: Currency.wrap(address(token1)),
    hooks: IHooks(address(fumaDiscountHook)),
    poolManager: clPoolManager,
    fee: 3000, // 0.3%
    parameters: bytes32(uint256(60)) // 60 tick spacing
});

clPoolManager.initialize(key, sqrtPriceX96);
```

### Adding Liquidity

```solidity
import {ICLPositionManager} from "./interfaces/ICLPositionManager.sol";

// Add liquidity to CL pool
ICLPositionManager.MintParams memory params = ICLPositionManager.MintParams({
    poolKey: key,
    tickLower: -887220,
    tickUpper: 887220,
    amount0Desired: 1000e18,
    amount1Desired: 1000e18,
    amount0Min: 0,
    amount1Min: 0,
    recipient: msg.sender,
    deadline: block.timestamp
});

positionManager.mint(params);
```

### Swapping

```solidity
import {IInfinityRouter} from "./interfaces/IInfinityRouter.sol";

// Execute swap
IInfinityRouter.ExactInputSingleParams memory params = IInfinityRouter.ExactInputSingleParams({
    poolKey: key,
    zeroForOne: true,
    amountIn: 100e18,
    amountOutMinimum: 0,
    sqrtPriceLimitX96: 0,
    hookData: ""
});

router.exactInputSingle(params, block.timestamp);
```

## Security

### Audit Status
⚠️ **NOT AUDITED** - These contracts are based on PancakeSwap V4 but have been modified for Fushuma Network. A comprehensive security audit is required before production deployment.

### Security Considerations
- All contracts inherit from audited PancakeSwap V4 codebase
- Custom hooks require additional security review
- Reentrancy protection via OpenZeppelin guards
- Access control on administrative functions
- Pausable for emergency stops

### Reporting Issues
If you discover a security vulnerability, please email: security@fushuma.com

## Gas Optimization

FumaSwap V4 includes several gas optimizations:

- **Singleton Vault**: Reduces deployment costs and improves swap efficiency
- **Flash Accounting**: Minimizes token transfers during multi-hop swaps
- **Efficient Hooks**: Minimal overhead for custom logic
- **Optimized Storage**: Packed structs and efficient data structures

## Documentation

- [Architecture Overview](../../docs/FUMASWAP_ARCHITECTURE.md)
- [Deployment Guide](../../docs/FUMASWAP_DEPLOYMENT.md)
- [Integration Guide](../../docs/FUMASWAP_INTEGRATION.md)
- [Hook Development](../../docs/FUMASWAP_HOOKS.md)
- [PancakeSwap V4 Docs](https://docs.pancakeswap.finance/developers/smart-contracts/pancakeswap-infinity)

## Resources

- **Fushuma Docs**: [docs.fushuma.com](https://docs.fushuma.com)
- **FumaSwap Interface**: [governance2.fushuma.com/defi/fumaswap](https://governance2.fushuma.com/defi/fumaswap)
- **PancakeSwap V4**: [github.com/pancakeswap/pancake-v4-core](https://github.com/pancakeswap/pancake-v4-core)

## License

Based on PancakeSwap V4, licensed under GPL-2.0-or-later. See [LICENSE](../../LICENSE) for details.

## Credits

FumaSwap V4 is built on top of:
- **PancakeSwap V4 (Infinity)** - Core AMM architecture
- **Uniswap V4** - Original hook-based design
- **OpenZeppelin** - Security libraries

---

**Last Updated**: November 11, 2025
**Status**: Development - Not production ready
