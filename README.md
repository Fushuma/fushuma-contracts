# Fushuma Network Smart Contracts

Production-ready smart contracts for the Fushuma Network ecosystem, including DeFi, Launchpad, Bridge, and Governance infrastructure.

## Overview

This repository contains all smart contracts that power the Fushuma Network platform:

- **DeFi (FumaSwap V4)**: Core DEX contracts for trading and liquidity provision
- **Governance**: On-chain governance with vote-escrowed NFTs and council oversight
- **Launchpad**: Token launch and vesting contracts (already deployed)
- **Bridge**: Cross-chain bridge contracts (already deployed)
- **Tokens**: Wrapped tokens and standard implementations

## Repository Structure

```
fushuma-contracts/
├── contracts/
│   ├── core/           # Core DeFi contracts (Vault, Pool Managers)
│   ├── periphery/      # User-facing contracts (Routers, Quoters)
│   ├── governance/     # Governance contracts (Governor, Council, VotingEscrow)
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

### Governance Contracts (Ready to Deploy)
- **FushumaGovernor**: Main governance contract with veNFT-based voting
- **GovernanceCouncil**: Council with veto and speedup powers
- **VotingEscrow**: Vote-escrowed NFT for governance participation
- **VotingEscrowV2**: Enhanced version with additional features
- **EpochManager**: Manages governance epochs
- **GaugeController**: Controls gauge weights for incentives
- **Gauge**: Standard gauge implementation
- **GrantGauge**: Specialized gauge for development grants

### DeFi Contracts (To Be Deployed)
- **WFUMA**: TBD (or provide address if already deployed)
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

### 4. Build Contracts

```bash
forge build
```

### 5. Run Tests

```bash
forge test
```

## Deployment Guides

### Governance Contracts

See [docs/GOVERNANCE_DEPLOYMENT.md](docs/GOVERNANCE_DEPLOYMENT.md) for detailed deployment instructions.

**Quick Deploy**:
```bash
export PRIVATE_KEY=0x...
forge script scripts/DeployGovernance.s.sol:DeployGovernance \
  --rpc-url https://rpc.fushuma.com \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### WFUMA Token

See [scripts/deploy-wfuma.sh](scripts/deploy-wfuma.sh) for WFUMA deployment.

**Quick Deploy**:
```bash
export PRIVATE_KEY=0x...
./scripts/deploy-wfuma.sh
```

### DeFi Contracts

See [docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) for full DeFi deployment instructions.

## Contract Categories

### Governance Contracts ✅ Ready

The governance system implements a sophisticated voting mechanism with the following features:

- **veNFT-based voting**: Lock FUMA tokens to receive voting power
- **Council oversight**: Emergency veto and speedup capabilities
- **Timelock execution**: Safety delays for proposal execution
- **Epoch management**: Organized governance periods
- **Gauge system**: Incentive distribution control
- **Grant gauges**: Development grant allocation

**Key Contracts**:
- `FushumaGovernor.sol` - Main governance contract
- `GovernanceCouncil.sol` - Council with oversight powers
- `VotingEscrow.sol` / `VotingEscrowV2.sol` - Vote-escrowed NFTs
- `EpochManager.sol` - Epoch management
- `GaugeController.sol` - Gauge weight controller
- `Gauge.sol` / `GrantGauge.sol` - Gauge implementations

**Documentation**:
- [Architecture](docs/GOVERNANCE_ARCHITECTURE.md)
- [Deployment Guide](docs/GOVERNANCE_DEPLOYMENT.md)
- [Integration Guide](docs/GOVERNANCE_INTEGRATION.md)

### Token Contracts

**WFUMA (Wrapped FUMA)**
- Standard WETH9 implementation adapted for FUMA
- Enables native FUMA to be used in DeFi protocols
- Status: Ready to deploy (or provide address if deployed)

### DeFi Contracts (Pending Implementation)

These contracts require the FumaSwap V4 implementation:

**Core Contracts**:
- Vault - Core liquidity vault
- CLPoolManager - Concentrated liquidity pools
- BinPoolManager - Bin-based pools (optional)

**Periphery Contracts**:
- CLPositionManager - Position management
- InfinityRouter - Universal router
- CLQuoter - Price quotes
- MixedQuoter - Cross-pool quotes

**Custom Hooks** (require development):
- FumaDiscountHook - Fee discounts for FUMA holders
- LaunchpadHook - Launchpad integration

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
- **DeFi Contracts**: Awaiting audit before production deployment

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

- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) - Full deployment instructions
- [Contract Status](docs/CONTRACT_STATUS.md) - Current deployment status
- [Security Guidelines](docs/SECURITY.md) - Security best practices
- [Governance Architecture](docs/GOVERNANCE_ARCHITECTURE.md) - Governance system design
- [Governance Deployment](docs/GOVERNANCE_DEPLOYMENT.md) - Deploy governance contracts
- [Governance Integration](docs/GOVERNANCE_INTEGRATION.md) - Integrate with governance

## Gas Estimates

| Contract Category | Estimated Gas | Notes |
|-------------------|---------------|-------|
| WFUMA | ~1,000,000 | Standard wrapped token |
| Governance (full suite) | ~15,000,000 | All governance contracts |
| Core DeFi | ~10,000,000 | Vault + Managers |
| Periphery | ~8,000,000 | Routers + Quoters |
| **Total** | ~35,000,000 | Full deployment |

*Note: Actual costs depend on network gas prices at deployment time*

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

**⚠️ Important**: Governance contracts have NOT been audited. DeFi contracts are under development. Do not use in production without proper auditing and testing.

**Last Updated**: November 11, 2025
