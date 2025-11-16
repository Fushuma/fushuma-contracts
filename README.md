# Fushuma Network Smart Contracts

**Last Updated:** November 16, 2025

Production-ready smart contracts for the Fushuma Network ecosystem, including DeFi, Launchpad, Bridge, and Governance infrastructure.

## Overview

This repository contains all smart contracts that power the Fushuma Network platform:

- **DeFi (FumaSwap V4)**: Core DEX contracts for trading and liquidity provision
- **Governance**: On-chain governance with vote-escrowed NFTs and council oversight
- **Launchpad**: Token launch and vesting contracts (already deployed)
- **Bridge**: Cross-chain bridge contracts (already deployed)
- **Tokens**: Wrapped tokens and standard implementations

## Deployed Contracts

### DeFi (FumaSwap V4) - ✅ Deployed & Live!

| Contract | Address |
|---|---|
| **Vault** | `0x4FB212Ed5038b0EcF2c8322B3c71FC64d66073A1` |
| **CLPoolManager** | `0x9123DeC6d2bE7091329088BA1F8Dc118eEc44f7a` |
| **BinPoolManager** | `0x3014809fBFF942C485A9F527242eC7C5A9ddC765` |
| **CLQuoter** | `0x9C82E4098805a00eAE3CE96D1eBFD117CeB1fAF8` |
| **CLPositionDescriptor** | `0x181267d849a0a89bC45F4e96F70914AcFb631515` |
| **CLPositionManager** | `0x411755EeC7BaA85F8d6819189FE15d966F41Ad85` |
| **BinQuoter** | `0x24cc1bc41220e638204216FdB4252b1D3716561D` |
| **BinPositionManager** | `0x36eb7e5Ae00b2eEA50435084bb98Bb4Ebf5E2982` |
| **FumaInfinityRouter** | `0x9E98f794bd1c4161898013fa0DEE406B7b06aB6B` |
| **Permit2** | `0x1d5E963f9581F5416Eae6C9978246B7dDf559Ff0` |
| **WFUMA** | `0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E` |

### Launchpad (Production ✅)
- **LaunchpadProxy**: `0x206236eca2dF8FB37EF1d024e1F72f4313f413E4`
- **VestingImplementation**: `0x0d8e696475b233193d21E565C21080EbF6A3C5DA`

### Bridge (Production ✅)
- **Bridge Contract**: `0x7304ac11BE92A013dA2a8a9D77330eA5C1531462`

### Payment Tokens (Production ✅)
- **USDC**: `0xf8EA5627691E041dae171350E8Df13c592084848`
- **USDT**: `0x1e11d176117dbEDbd234b1c6a10C6eb8dceD275e`

## Network Information

- **Network**: Fushuma Network
- **Chain ID**: 121224
- **RPC URL**: https://rpc.fushuma.com
- **Explorer**: https://explorer.fushuma.com
- **Native Token**: FUMA

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

## Deployment

All DeFi contracts have been deployed. See the deployment record at `broadcast/` for transaction details.

To redeploy, use the scripts in the `script/` directory.

## Security

- **Audit Status**: ⚠️ NOT audited yet - use at your own risk.
- **Security Features**: Solidity 0.8.26+, reentrancy guards, access control, pausable, timelock delays, comprehensive test coverage.
- **Reporting Security Issues**: security@fushuma.com

## Resources

- **Documentation**: [docs.fushuma.com](https://docs.fushuma.com)
- **Website**: [fushuma.com](https://fushuma.com)
- **Governance Hub**: [governance2.fushuma.com](https://governance2.fushuma.com)
- **Explorer**: [explorer.fushuma.com](https://explorer.fushuma.com)
- **GitHub**: [github.com/Fushuma](https://github.com/Fushuma)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
