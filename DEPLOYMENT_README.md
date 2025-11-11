# Fushuma Governance Deployment

This document describes the deployed Fushuma governance system on Fushuma zkEVM+ Mainnet.

## Deployment Status

**Date**: November 11, 2025  
**Network**: Fushuma zkEVM+ Mainnet (Chain ID: 121224)  
**Status**: 5 of 6 contracts fully operational ✅

## Contract Addresses

All contract addresses are available in `deployments/fushuma-mainnet.json`.

### Core Contracts

| Contract | Proxy Address | Status |
|----------|---------------|--------|
| **VotingEscrow** | `0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f` | ✅ Working |
| **EpochManager** | `0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453` | ✅ Working |
| **GovernanceCouncil** | `0x92bCcdcae7B73A5332429e517D26515D447e9997` | ✅ Working |
| **FushumaGovernor** | `0xF36107b3AA203C331284E5A467C1c58bDD5b591D` | ✅ Working |
| **GaugeController** | `0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466` | ✅ Working |
| **GrantGauge** | `0x6E56987a890FC377Ec9c6193e2FB68838b70b1D7` | ⚠️ Needs Init |

### Token

| Token | Address | Status |
|-------|---------|--------|
| **WFUMA** | `0xBcA7B11c788dBb85bE92627ef1e60a2A9B7e2c6E` | ✅ Pre-existing |

## Architecture

The governance system consists of several interconnected contracts that work together to provide decentralized governance for the Fushuma ecosystem. The system uses a vote-escrowed NFT (veNFT) model where users lock WFUMA tokens to receive voting power that increases linearly over time.

### VotingEscrow

The VotingEscrow contract allows users to lock WFUMA tokens for a specified duration (up to 1 year) and receive a veNFT in return. The voting power of each veNFT increases linearly over time, reaching a maximum multiplier of 4x after the full lock period. This incentivizes long-term commitment to the protocol.

**Key Parameters:**
- Minimum deposit: 100 WFUMA
- Warmup period: 7 days (voting power ramps up)
- Cooldown period: 14 days (before withdrawal)
- Maximum lock duration: 1 year
- Maximum multiplier: 4x

### EpochManager

The EpochManager coordinates time-based operations across the governance system. It divides time into 14-day epochs, each consisting of three phases: voting, distribution, and preparation. This ensures orderly execution of governance actions and resource allocation.

**Key Parameters:**
- Epoch duration: 14 days (1,209,600 seconds)
- Current epoch: 0
- Start time: November 11, 2025, 10:46 UTC

### GovernanceCouncil

The GovernanceCouncil provides an additional layer of oversight and security. It consists of trusted community members who can veto malicious proposals or expedite critical ones. The council operates as a multisig, requiring approval from multiple members before taking action.

**Key Parameters:**
- Council members: 3
- Required approvals: 2 of 3
- Veto period: 2 days
- Veto voting period: 1 day
- Speedup voting period: 12 hours

**Council Members:**
1. `0xC8e420222d4c93355776eD77f9A34757fb6f3eea`
2. `0x7152B9A7BD708750892e577Fcc96ea24FDDF37a4`
3. `0x45FAc82b24511927a201C2cdFC506625dECe3d22`

### FushumaGovernor

The FushumaGovernor is the main governance contract that handles proposal creation, voting, and execution. It integrates with the VotingEscrow to determine voting power and includes a timelock mechanism for security. Proposals must meet a minimum threshold and quorum to pass.

**Key Parameters:**
- Proposal threshold: 1,000 WFUMA voting power
- Quorum: 10% (1,000 basis points)
- Voting period: 7 days (50,400 blocks)
- Voting delay: 1 day (7,200 blocks)
- Timelock delay: 2 days (172,800 seconds)

### GaugeController

The GaugeController manages the allocation of resources across different gauges. Users with veNFTs can vote on how resources should be distributed among various initiatives, projects, or grants. The controller aggregates votes and determines the allocation for each epoch.

**Key Parameters:**
- Linked to VotingEscrow: `0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f`
- Linked to EpochManager: `0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453`

### GrantGauge

The GrantGauge is a specific type of gauge designed for distributing WFUMA tokens to grant recipients. It follows the allocation determined by the GaugeController and includes vesting schedules to ensure responsible distribution of funds over time.

**Status**: ⚠️ Proxy deployed but initialization failed. Requires debugging before use.

## Technical Implementation

### MinimalProxy Pattern

All contracts use a custom `MinimalProxy` implementation instead of OpenZeppelin's standard proxies. This was necessary because OpenZeppelin's ERC1967Proxy and TransparentUpgradeableProxy are incompatible with Fushuma zkEVM+. The MinimalProxy provides the same upgradeability features while being optimized for zkEVM compatibility.

**MinimalProxy Contract**: `contracts/proxy/MinimalProxy.sol`

### Upgradeability

All governance contracts are upgradeable via the UUPS (Universal Upgradeable Proxy Standard) pattern. The admin address (`0xC8e420222d4c93355776eD77f9A34757fb6f3eea`) has the authority to upgrade contract implementations. It is strongly recommended to transfer admin control to a multisig wallet or governance contract before mainnet use.

## Deployment Scripts

Individual deployment scripts are available in the `script/` directory:

- `Deploy1_EpochManager.s.sol` - Deploys EpochManager
- `Deploy2_GovernanceCouncil.s.sol` - Deploys GovernanceCouncil with council members
- `Deploy4_Governor.s.sol` - Deploys FushumaGovernor
- `Deploy5_GaugeController.s.sol` - Deploys GaugeController
- `Deploy6_GrantGauge.s.sol` - Deploys GrantGauge (needs fixing)
- `InitGrantGauge.s.sol` - Initializes existing GrantGauge proxy

## Verification

To verify the contracts are working correctly, run:

```bash
forge script script/VerifyDeployment.s.sol --rpc-url https://rpc.fushuma.com
```

Or manually check each contract:

```bash
# VotingEscrow
cast call 0x80Ebf301efc7b0FF1825dC3B4e8d69e414eaa26f "maxMultiplier()(uint256)" --rpc-url https://rpc.fushuma.com

# EpochManager
cast call 0x36C3b4EA7dC2622b8C63a200B60daC0ab2d8f453 "currentEpoch()(uint256)" --rpc-url https://rpc.fushuma.com

# GovernanceCouncil
cast call 0x92bCcdcae7B73A5332429e517D26515D447e9997 "requiredApprovals()(uint256)" --rpc-url https://rpc.fushuma.com

# FushumaGovernor
cast call 0xF36107b3AA203C331284E5A467C1c58bDD5b591D "proposalThreshold()(uint256)" --rpc-url https://rpc.fushuma.com

# GaugeController
cast call 0x41E7ba36C43CCd4b83a326bB8AEf929e109C9466 "votingEscrow()(address)" --rpc-url https://rpc.fushuma.com
```

## Outstanding Issues

### GrantGauge Initialization

The GrantGauge proxy was deployed successfully but initialization failed. The proxy exists at `0x6E56987a890FC377Ec9c6193e2FB68838b70b1D7` but is not yet functional.

**Possible causes:**
1. Parameter validation issue in the initialize function
2. Dependency on GaugeController registration
3. Token approval or access control issue

**Recommended solution:**
- Debug the exact revert reason using Foundry's trace functionality
- Check if the gauge needs to be registered with GaugeController first
- Consider deploying a fresh GrantGauge with adjusted parameters

## Next Steps

1. **Fix GrantGauge initialization** - Debug and resolve the initialization issue
2. **Verify contracts on Fumascan** - Upload source code for transparency
3. **Test all interactions** - Create test transactions for each contract
4. **Update frontend** - Deploy contract addresses to the governance hub
5. **Security audit** - Recommended before production use ($20k-50k budget)
6. **Transfer admin to multisig** - Enhance security by using a multisig wallet

## Security Considerations

- All contracts are upgradeable - the admin has significant power
- No security audit has been performed yet
- Contracts should be thoroughly tested before handling significant value
- Consider using a multisig wallet for admin operations
- Private keys must be kept secure and never committed to version control

## Resources

- **Explorer**: https://fumascan.com
- **RPC Endpoint**: https://rpc.fushuma.com
- **GitHub**: https://github.com/Fushuma/fushuma-contracts
- **Governance Hub**: https://governance2.fushuma.com

## Support

For technical support or questions about the deployment, please open an issue on GitHub or contact the Fushuma development team.

---

**Last Updated**: November 11, 2025  
**Maintainer**: Fushuma Development Team
