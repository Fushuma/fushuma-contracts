# Fushuma Network Smart Contracts

Production-ready smart contracts for the Fushuma Network ecosystem, including DeFi, Governance, Launchpad, and Bridge infrastructure.

## Overview

This repository contains all smart contracts that power the Fushuma Network platform:

- **DeFi (FumaSwap V4)**: Core DEX contracts for trading and liquidity provision (✅ Core deployed)
- **Governance**: On-chain governance with vote-escrowed NFTs and council oversight (✅ Deployed)
- **Launchpad**: Token launch and vesting contracts (✅ Deployed)
- **Bridge**: Cross-chain bridge contracts (✅ Deployed)
- **Tokens**: Wrapped tokens and standard implementations (✅ WFUMA deployed)

## Repository Structure

```
fushuma-contracts/
├── contracts/
│   ├── core/           # Core DeFi contracts (Vault, Pool Managers)
│   ├── periphery/      # User-facing contracts (Routers, Quoters)
│   ├── governance/     # Governance contracts (Governor, Council, VotingEscrow)
│   ├── hooks/          # Custom hook implementations
│   └── tokens/         # Token contracts (WFUMA, etc.)
├── script/             # Deployment and management scripts
├── test/               # Contract tests
├── docs/               # Documentation
└── README.md
```

## Deployed Contracts

### Launchpad (Production ✅)
- **LaunchpadProxy**: `0x206236eca2dF8FB37EF1d024e1F72f4313f413E4`
- **VestingImplementation**: `0x0d8e696475b233193d21E565C21080EbF6A3C5DA`

### Bridge (Production ✅)
- **Bridge Contract**: `0x7304ac11BE92A013dA2a8a9D77330eA5C1531462`

### Payment Tokens (Production ✅)
- **USDC**: `0xf8EA5627691E041dae171350E8Df13c592084848`
- **USDT**: `0x1e11d176117dbEDbd234b1c6a10C6eb8dceD275e`

### Token Infrastructure (Production ✅)
- **WFUMA**: `0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E`

### Governance Contracts (Production ✅)
- **VotingEscrow**: `0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f`
- **EpochManager**: `0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453`
- **GovernanceCouncil**: `0x92bCcdcae7B73A5332429e517D26515D447e9997`
- **FushumaGovernor**: `0xF36107b3AA203C331284E5A467C1c58bDD5b591D`
- **GaugeController**: `0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466`
- **GrantGauge**: `0x0D6833778cf1fa803D21075b800483F68f57A153`

### DeFi Core Contracts (Production ✅)
**Deployed**: November 16, 2025 (Paris EVM Compatible)

- **Vault**: `0x4FB212Ed5038b0EcF2c8322B3c71FC64d66073A1`
- **CLPoolManager**: `0x9123DeC6d2bE7091329088BA1F8Dc118eEc44f7a`
- **BinPoolManager**: `0x3014809fBFF942C485A9F527242eC7C5A9ddC765`

### DeFi Periphery Contracts (Production ✅)
**Deployed**: November 16, 2025 (Paris EVM Compatible)

**Concentrated Liquidity:**
- **CLQuoter**: `0x9C82E4098805a00eAE3CE96D1eBFD117CeB1fAF8`
- **CLPositionDescriptor**: `0x181267d849a0a89bC45F4e96F70914AcFb631515`
- **CLPositionManager**: `0x411755EeC7BaA85F8d6819189FE15d966F41Ad85`

**Bin Pools:**
- **BinQuoter**: `0x24cc1bc41220e638204216FdB4252b1D3716561D`
- **BinPositionManager**: `0x36eb7e5Ae00b2eEA50435084bb98Bb4Ebf5E2982`

**Router:**
- **InfinityRouter**: `0x9E98f794bd1c4161898013fa0DEE406B7b06aB6B`

### Supporting Contracts (Production ✅)
- **Permit2**: `0x1d5E963f9581F5416Eae6C9978246B7dDf559Ff0`

### Protocol Governance (⏳ Optional - Pending)
- **CLProtocolFeeController**: TBD
- **CLPoolManagerOwner**: TBD

### Custom Hooks (⏳ Optional - Pending Development)
- **FumaDiscountHook**: TBD
- **LaunchpadHook**: TBD

**Note**: MixedQuoter was skipped due to transient storage incompatibility with zkEVM+. All deployed contracts use Paris EVM compatible versions.

## Network Information

- **Network**: Fushuma zkEVM+ Mainnet
- **Chain ID**: 121224
- **RPC URL**: https://rpc.fushuma.com
- **Explorer**: https://fumascan.com
- **Native Token**: FUMA

## Prerequisites

Before deploying contracts, ensure you have:

1. **Foundry** installed - [Installation Guide](https://book.getfoundry.sh/getting-started/installation)
2. **Private key** with sufficient FUMA tokens for gas fees
3. **Node.js** (v18+) for scripts
4. **Git** for version control

### Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Fushuma/fushuma-contracts.git
cd fushuma-contracts
```

### 2. Install Dependencies

```bash
forge install
npm install
```

### 3. Configure Environment

```bash
cp .env.example .env
# Edit .env with your private key
```

### 4. Build Contracts

```bash
forge build
```

### 5. Run Tests

```bash
forge test
```

## Deployment Status

### Overall Progress

| Category | Total | Deployed | Pending | Progress |
|----------|-------|----------|---------|----------|
| **Launchpad** | 2 | 2 | 0 | 100% ✅ |
| **Bridge** | 1 | 1 | 0 | 100% ✅ |
| **Payment Tokens** | 2 | 2 | 0 | 100% ✅ |
| **Token Infrastructure** | 1 | 1 | 0 | 100% ✅ |
| **Governance** | 6 | 6 | 0 | 100% ✅ |
| **Core DeFi** | 3 | 3 | 0 | 100% ✅ |
| **Periphery DeFi** | 6 | 6 | 0 | 100% ✅ |
| **Supporting** | 1 | 1 | 0 | 100% ✅ |
| **Protocol Governance** | 2 | 0 | 2 | 0% ⏳ |
| **Custom Hooks** | 2 | 0 | 2 | 0% ⏳ |
| **TOTAL** | 26 | 22 | 4 | 85% |

## Deployment Guides

### Governance Contracts

See [DEPLOYMENT_README.md](DEPLOYMENT_README.md) for detailed governance deployment information.

**Status**: ✅ All governance contracts deployed and operational

### DeFi Core Contracts

See [DEFI_DEPLOYMENT.md](DEFI_DEPLOYMENT.md) for detailed DeFi deployment information.

**Status**: ✅ Core contracts (Vault, CLPoolManager, BinPoolManager) deployed

### Periphery Contracts

**Status**: ⏳ Pending deployment - requires infinity-periphery integration

The periphery contracts (routers, quoters, position managers) are next in the deployment pipeline and require integration with the PancakeSwap V4 infinity-periphery repository.

## Contract Categories

### Governance Contracts ✅ Deployed

The governance system implements a sophisticated voting mechanism with the following features:

- **veNFT-based voting**: Lock WFUMA tokens to receive voting power
- **Council oversight**: Emergency veto and speedup capabilities
- **Timelock execution**: Safety delays for proposal execution
- **Epoch management**: Organized governance periods
- **Gauge system**: Incentive distribution control
- **Grant gauges**: Development grant allocation

**Key Contracts**:
- `FushumaGovernor.sol` - Main governance contract
- `GovernanceCouncil.sol` - Council with oversight powers
- `VotingEscrow.sol` - Vote-escrowed NFTs
- `EpochManager.sol` - Epoch management
- `GaugeController.sol` - Gauge weight controller
- `GrantGauge.sol` - Grant gauge implementation

**Documentation**:
- [Deployment Info](DEPLOYMENT_README.md)
- [Architecture](docs/GOVERNANCE_ARCHITECTURE.md)
- [Deployment Guide](docs/GOVERNANCE_DEPLOYMENT.md)
- [Integration Guide](docs/GOVERNANCE_INTEGRATION.md)

### Token Contracts ✅ Deployed

**WFUMA (Wrapped FUMA)**
- **Address**: `0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E`
- Standard WETH9 implementation adapted for FUMA
- Enables native FUMA to be used in DeFi protocols

### DeFi Contracts - FumaSwap V4 ✅ Core Deployed

FumaSwap V4 is a decentralized exchange built on PancakeSwap V4 (Infinity) architecture.

**Core Contracts** (✅ Deployed):
- `Vault.sol` - Central liquidity vault managing all pools
- `CLPoolManager.sol` - Concentrated liquidity pool manager
- `BinPoolManager.sol` - Bin-based pool manager

**Periphery Contracts** (⏳ Pending):
- `CLPositionManager.sol` - Concentrated liquidity position management
- `InfinityRouter.sol` - Universal router for swaps and liquidity
- `CLQuoter.sol` - Price quotes for CL pools
- `MixedQuoter.sol` - Cross-pool quote aggregation
- `BatchRouter.sol` - Batch operations

**Custom Hooks** (⏳ Pending):
- `FumaDiscountHook.sol` - Dynamic fee discounts for FUMA holders
- `LaunchpadHook.sol` - Integration with Fushuma Launchpad

**Status**: ⚠️ Core deployed, periphery pending - NOT audited yet

**Documentation**:
- [DeFi Deployment](DEFI_DEPLOYMENT.md)
- [Production Readiness](DEFI_PRODUCTION_READINESS.md)
- [Deployment Checklist](DEPLOYMENT_CHECKLIST.md)

## Testing

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test file
forge test --match-path test/FushumaGovernor.t.sol

# Run with gas reporting
forge test --gas-report

# Generate coverage report
forge coverage
```

## Security

### Audit Status
- **Launchpad**: Production (deployed)
- **Bridge**: Production (deployed)
- **Governance Contracts**: ⚠️ NOT audited yet - use at your own risk
- **DeFi Contracts**: ⚠️ NOT audited yet - use at your own risk

### Security Features
- Solidity 0.8.20+ with built-in overflow protection
- Reentrancy guards on critical functions
- Access control via OpenZeppelin's patterns
- Pausable for emergency stops
- Timelock delays for governance execution
- Comprehensive test coverage

### Reporting Security Issues
If you discover a security vulnerability, please email: security@fushuma.com

## Documentation

- [Deployment Summary](DEPLOYMENT_SUMMARY.md) - Overall deployment status and plan
- [DeFi Deployment](DEFI_DEPLOYMENT.md) - DeFi contracts deployment info
- [Governance Deployment](DEPLOYMENT_README.md) - Governance contracts deployment info
- [Contract Status](docs/CONTRACT_STATUS.md) - Current deployment status
- [Security Guidelines](docs/SECURITY.md) - Security best practices
- [Governance Architecture](docs/GOVERNANCE_ARCHITECTURE.md) - Governance system design
- [Governance Integration](docs/GOVERNANCE_INTEGRATION.md) - Integrate with governance

## Next Steps

### Optional Enhancements

1. **Protocol Governance Contracts** (Optional)
   - CLProtocolFeeController - for dynamic fee management
   - CLPoolManagerOwner - for decentralized pool governance

2. **Custom Hooks Development** (Optional)
   - FumaDiscountHook - fee discounts for FUMA holders
   - LaunchpadHook - launchpad integration features

3. **Security Audit** (Recommended)
   - Professional audit before handling significant value
   - Comprehensive security review of all deployed contracts

4. **Monitoring & Alerts**
   - Production monitoring infrastructure
   - Real-time alerts for unusual activity
   - Performance metrics and analytics

## Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Use Solidity 0.8.20 or higher
- Follow the [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Add comprehensive NatSpec comments
- Write tests for all new functionality
- Ensure all tests pass before submitting PR

## Resources

- **Documentation**: [docs.fushuma.com](https://docs.fushuma.com)
- **Website**: [fushuma.com](https://fushuma.com)
- **Governance Hub**: [governance2.fushuma.com](https://governance2.fushuma.com)
- **Explorer**: [fumascan.com](https://fumascan.com)
- **GitHub**: [github.com/Fushuma](https://github.com/Fushuma)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

- **Email**: dev@fushuma.com
- **Discord**: [Join our community](https://discord.gg/fushuma)
- **Twitter**: [@FushumaNetwork](https://twitter.com/FushumaNetwork)

---

**⚠️ Important**: Governance and DeFi contracts have NOT been audited. Do not use in production with significant value without proper auditing and testing.

**Last Updated**: November 16, 2025
