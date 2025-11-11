# Fushuma Network Smart Contracts

Production-ready smart contracts for the Fushuma Network ecosystem, including DeFi, Launchpad, Bridge, and Governance infrastructure.

## Overview

This repository contains all smart contracts that power the Fushuma Network platform:

- **DeFi (FumaSwap V4)**: Core DEX contracts for trading and liquidity provision
- **Launchpad**: Token launch and vesting contracts (already deployed)
- **Bridge**: Cross-chain bridge contracts (already deployed)
- **Governance**: On-chain governance infrastructure (future)
- **Tokens**: Wrapped tokens and standard implementations

## Repository Structure

```
fushuma-contracts/
├── contracts/
│   ├── core/           # Core DeFi contracts (Vault, Pool Managers)
│   ├── periphery/      # User-facing contracts (Routers, Quoters)
│   ├── governance/     # Protocol governance contracts
│   ├── hooks/          # Custom hook implementations
│   └── tokens/         # Token contracts (WFUMA, etc.)
├── scripts/            # Deployment and management scripts
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

### DeFi Contracts (To Be Deployed)
- **WFUMA**: TBD
- **Vault**: TBD
- **CLPoolManager**: TBD
- **InfinityRouter**: TBD
- **CLPositionManager**: TBD
- **MixedQuoter**: TBD

## Network Information

- **Network**: Fushuma Network
- **Chain ID**: 121224
- **RPC URL**: https://rpc.fushuma.com
- **Explorer**: https://explorer.fushuma.com
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

### 4. Deploy WFUMA (First Priority)

```bash
export PRIVATE_KEY=0x...
./scripts/deploy-wfuma.sh
```

## Deployment Sequence

Contracts must be deployed in the following order due to dependencies:

### Phase 1: Foundation (Critical)
1. ✅ **WFUMA** - Wrapped FUMA token
2. ⚠️ **Permit2** - Check if exists at canonical address, deploy if needed

### Phase 2: Core DeFi (Critical)
3. **Vault** - Core liquidity vault
4. **CLPoolManager** - Concentrated liquidity pool manager
5. **BinPoolManager** - Bin-based pool manager (optional)

### Phase 3: Periphery (High Priority)
6. **CLPositionManager** - LP position management
7. **InfinityRouter** - Universal router for swaps
8. **CLQuoter** - Price quoter for CL pools
9. **MixedQuoter** - Multi-pool quoter

### Phase 4: Governance (Medium Priority)
10. **CLProtocolFeeController** - Fee management
11. **CLPoolManagerOwner** - Admin controls

### Phase 5: Custom Features (Medium Priority)
12. **FumaDiscountHook** - Fee discounts for FUMA holders
13. **LaunchpadHook** - Launchpad integration

## Contract Status

| Category | Contracts | Status | Priority |
|----------|-----------|--------|----------|
| **Tokens** | WFUMA | Ready to deploy | 🔴 Critical |
| **Core DeFi** | Vault, Managers | Needs implementation | 🔴 Critical |
| **Periphery** | Routers, Quoters | Needs implementation | 🟠 High |
| **Governance** | Fee Controller, Owner | Needs implementation | 🟡 Medium |
| **Hooks** | Discount, Launchpad | Needs implementation | 🟡 Medium |
| **Launchpad** | Proxy, Vesting | ✅ Deployed | ✅ Complete |
| **Bridge** | Bridge Contract | ✅ Deployed | ✅ Complete |

## Security

### Audit Status
- **Launchpad**: Production (deployed)
- **Bridge**: Production (deployed)
- **DeFi Contracts**: Awaiting audit before production deployment

### Best Practices
- All contracts use Solidity 0.8.20+ with built-in overflow protection
- Reentrancy guards on all state-changing functions
- Access control via OpenZeppelin's Ownable/AccessControl
- Comprehensive test coverage required before deployment
- Multi-signature wallet for contract ownership

### Reporting Security Issues
If you discover a security vulnerability, please email: security@fushuma.com

## Testing

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-path test/WFUMA.t.sol

# Run with gas reporting
forge test --gas-report

# Run with coverage
forge coverage
```

## Deployment Scripts

All deployment scripts are located in the `scripts/` directory:

- `deploy-wfuma.sh` - Deploy Wrapped FUMA token
- `deploy-core.sh` - Deploy core DeFi contracts (coming soon)
- `deploy-periphery.sh` - Deploy periphery contracts (coming soon)
- `deploy-hooks.sh` - Deploy custom hooks (coming soon)

## Configuration

After deployment, update the following files in the main repository:

1. **fushuma-gov-hub-v2/src/lib/fumaswap/contracts.ts**
   - Update all contract addresses
   - Update WFUMA address in COMMON_TOKENS

2. **Environment Variables**
   - Set `NEXT_PUBLIC_WFUMA_ADDRESS`
   - Set `NEXT_PUBLIC_VAULT_ADDRESS`
   - Set other contract addresses

## Gas Estimates

| Contract | Estimated Gas | Estimated Cost (at 1 gwei) |
|----------|---------------|----------------------------|
| WFUMA | ~1,000,000 | ~0.001 FUMA |
| Vault | ~3,000,000 | ~0.003 FUMA |
| CLPoolManager | ~4,000,000 | ~0.004 FUMA |
| InfinityRouter | ~3,000,000 | ~0.003 FUMA |
| CLPositionManager | ~2,500,000 | ~0.0025 FUMA |
| **Total** | ~25,000,000 | ~0.025 FUMA |

*Note: Actual costs depend on network gas prices at deployment time*

## Development Roadmap

### ✅ Phase 0: Infrastructure (Complete)
- [x] Launchpad contracts deployed
- [x] Bridge contracts deployed
- [x] Payment tokens configured
- [x] Frontend infrastructure ready

### 🔄 Phase 1: Core DeFi (In Progress)
- [x] WFUMA contract ready
- [ ] Core contracts implementation
- [ ] Periphery contracts implementation
- [ ] Testing and audit

### 📋 Phase 2: Advanced Features (Planned)
- [ ] Custom hooks implementation
- [ ] Governance contracts
- [ ] Staking and farming
- [ ] Subgraph deployment

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
- **Explorer**: [explorer.fushuma.com](https://explorer.fushuma.com)
- **GitHub**: [github.com/Fushuma](https://github.com/Fushuma)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

- **Email**: dev@fushuma.com
- **Discord**: [Join our community](https://discord.gg/fushuma)
- **Twitter**: [@FushumaNetwork](https://twitter.com/FushumaNetwork)

---

**⚠️ Important**: These contracts are under active development. Do not use in production without proper auditing and testing.

**Last Updated**: November 2025
