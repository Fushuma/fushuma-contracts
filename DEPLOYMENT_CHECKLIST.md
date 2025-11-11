# Fushuma Smart Contracts Deployment Checklist

Use this checklist to track deployment progress and ensure all steps are completed.

## Pre-Deployment

### Environment Setup
- [ ] Foundry installed and updated (`foundryup`)
- [ ] Node.js v18+ installed
- [ ] Git configured
- [ ] Repository cloned
- [ ] Dependencies installed (`forge install`)
- [ ] `.env` file configured with private key
- [ ] Private key has sufficient FUMA for gas fees (recommended: 1+ FUMA)

### Network Verification
- [ ] RPC connection tested (`cast block-number --rpc-url https://rpc.fushuma.com`)
- [ ] Deployer address identified
- [ ] Deployer balance confirmed
- [ ] Block explorer accessible

### Code Preparation
- [ ] All contracts compiled successfully (`forge build`)
- [ ] No compilation warnings
- [ ] Tests written and passing (`forge test`)
- [ ] Code reviewed
- [ ] Documentation complete

## Phase 1: WFUMA Deployment (Critical)

### Pre-Deployment
- [ ] WFUMA contract reviewed (`contracts/tokens/WFUMA.sol`)
- [ ] Deployment script reviewed (`scripts/deploy-wfuma.sh`)
- [ ] Gas estimate calculated
- [ ] Deployer funded

### Deployment
- [ ] WFUMA deployed successfully
- [ ] Deployment transaction confirmed
- [ ] Contract address recorded: `_____________________`
- [ ] Deployment info saved (`deployment-info.json`)

### Verification
- [ ] Contract code verified on explorer
- [ ] Contract source published
- [ ] Test wrap (deposit) function
- [ ] Test unwrap (withdraw) function
- [ ] Test transfer function
- [ ] Test approve function

### Configuration Update
- [ ] Updated `fushuma-gov-hub-v2/src/lib/fumaswap/contracts.ts`
- [ ] Updated `COMMON_TOKENS.WFUMA` address
- [ ] Updated `.env` with WFUMA address
- [ ] Committed changes to git
- [ ] Deployed frontend with new address

## Phase 2: Permit2 Verification (Critical)

### Verification
- [ ] Checked canonical address: `0x000000000022D473030F116dDEE9F6B43aC78BA3`
- [ ] Confirmed contract exists OR deployed new instance
- [ ] Contract address recorded: `_____________________`
- [ ] Functionality tested

### Configuration Update
- [ ] Updated contracts configuration if different address
- [ ] Updated `.env` if needed
- [ ] Committed changes

## Phase 3: Core DeFi Contracts (Critical)

### Source Code
- [ ] FumaSwap V4 core repository identified
- [ ] Core contracts reviewed
- [ ] Contracts adapted for Fushuma Network
- [ ] Tests updated and passing
- [ ] Security review completed

### Vault Deployment
- [ ] Vault contract compiled
- [ ] Deployment script prepared
- [ ] Vault deployed
- [ ] Deployment transaction confirmed
- [ ] Contract address recorded: `_____________________`
- [ ] Contract verified on explorer
- [ ] Functionality tested

### CLPoolManager Deployment
- [ ] CLPoolManager contract compiled
- [ ] Dependencies configured (Vault address)
- [ ] CLPoolManager deployed
- [ ] Deployment transaction confirmed
- [ ] Contract address recorded: `_____________________`
- [ ] Contract verified on explorer
- [ ] Functionality tested

### BinPoolManager Deployment (Optional)
- [ ] Decision made: Deploy [ ] Yes [ ] No
- [ ] If yes, BinPoolManager deployed
- [ ] Contract address recorded: `_____________________`
- [ ] Contract verified on explorer

### Configuration Update
- [ ] All core contract addresses updated in config
- [ ] Frontend configuration updated
- [ ] Changes committed and deployed

## Phase 4: Periphery Contracts (High Priority)

### CLPositionManager
- [ ] Contract compiled
- [ ] Dependencies configured
- [ ] Deployed successfully
- [ ] Contract address recorded: `_____________________`
- [ ] Verified on explorer
- [ ] Tested position management

### InfinityRouter
- [ ] Contract compiled
- [ ] Dependencies configured
- [ ] Deployed successfully
- [ ] Contract address recorded: `_____________________`
- [ ] Verified on explorer
- [ ] Tested swap routing

### CLQuoter
- [ ] Contract compiled
- [ ] Dependencies configured
- [ ] Deployed successfully
- [ ] Contract address recorded: `_____________________`
- [ ] Verified on explorer
- [ ] Tested price quotes

### MixedQuoter
- [ ] Contract compiled
- [ ] Dependencies configured
- [ ] Deployed successfully
- [ ] Contract address recorded: `_____________________`
- [ ] Verified on explorer
- [ ] Tested cross-pool quotes

### Configuration Update
- [ ] All periphery addresses updated
- [ ] Frontend integrated
- [ ] Changes deployed

## Phase 5: Governance Contracts (Medium Priority)

### CLProtocolFeeController
- [ ] Contract compiled
- [ ] Deployed successfully
- [ ] Contract address recorded: `_____________________`
- [ ] Verified on explorer
- [ ] Fee parameters configured
- [ ] Ownership transferred to multi-sig

### CLPoolManagerOwner
- [ ] Contract compiled
- [ ] Deployed successfully
- [ ] Contract address recorded: `_____________________`
- [ ] Verified on explorer
- [ ] Permissions configured
- [ ] Ownership transferred to multi-sig

## Phase 6: Custom Hooks (Medium Priority)

### FumaDiscountHook
- [ ] Contract implemented
- [ ] Tests written and passing
- [ ] Security reviewed
- [ ] Deployed successfully
- [ ] Contract address recorded: `_____________________`
- [ ] Verified on explorer
- [ ] Discount logic tested
- [ ] Integrated with pools

### LaunchpadHook
- [ ] Contract implemented
- [ ] Tests written and passing
- [ ] Security reviewed
- [ ] Deployed successfully
- [ ] Contract address recorded: `_____________________`
- [ ] Verified on explorer
- [ ] Launchpad integration tested
- [ ] Integrated with pools

## Post-Deployment

### Security
- [ ] All contracts verified on block explorer
- [ ] Multi-sig wallet configured
- [ ] Contract ownership transferred to multi-sig
- [ ] Timelock configured (if applicable)
- [ ] Emergency pause mechanisms tested
- [ ] Security monitoring active

### Testing
- [ ] End-to-end swap flow tested
- [ ] Liquidity provision tested
- [ ] Position management tested
- [ ] Fee collection tested
- [ ] All hooks tested
- [ ] Load testing completed

### Documentation
- [ ] All contract addresses documented
- [ ] Deployment dates recorded
- [ ] Configuration changes documented
- [ ] User guides updated
- [ ] API documentation updated

### Infrastructure
- [ ] Subgraph deployed
- [ ] Subgraph synced
- [ ] Analytics dashboard configured
- [ ] Monitoring alerts configured
- [ ] Backup systems verified

### Initial Liquidity
- [ ] WFUMA/USDC pool created
- [ ] WFUMA/USDT pool created
- [ ] USDC/USDT pool created
- [ ] Initial liquidity added to all pools
- [ ] Pool parameters verified
- [ ] Trading enabled

### Launch Preparation
- [ ] Security audit completed
- [ ] Audit report reviewed
- [ ] All critical issues resolved
- [ ] All high-severity issues resolved
- [ ] Medium issues addressed or accepted
- [ ] Re-audit completed (if needed)
- [ ] Legal review completed
- [ ] Marketing materials prepared
- [ ] Community informed
- [ ] Support team trained

## Launch Day

### Pre-Launch
- [ ] All systems operational
- [ ] Monitoring active
- [ ] Support team ready
- [ ] Emergency procedures reviewed
- [ ] Communication channels open

### Launch
- [ ] Public announcement made
- [ ] Frontend live
- [ ] Trading enabled
- [ ] Initial trades verified
- [ ] No critical issues detected

### Post-Launch
- [ ] System performance monitored
- [ ] User feedback collected
- [ ] Issues tracked and addressed
- [ ] Daily status reports
- [ ] Community engagement

## Ongoing Maintenance

### Weekly
- [ ] System health check
- [ ] Security monitoring review
- [ ] Performance metrics review
- [ ] User feedback review

### Monthly
- [ ] Access control review
- [ ] Dependency updates check
- [ ] Security scan
- [ ] Backup verification
- [ ] Documentation update

### Quarterly
- [ ] Comprehensive security review
- [ ] Disaster recovery drill
- [ ] Performance optimization
- [ ] Feature planning

## Notes

### Deployment Dates
- WFUMA: _______________
- Permit2: _______________
- Vault: _______________
- CLPoolManager: _______________
- Periphery Contracts: _______________
- Governance Contracts: _______________
- Custom Hooks: _______________
- Launch Date: _______________

### Issues Encountered
_Document any issues or deviations from the plan:_

1. 
2. 
3. 

### Lessons Learned
_Document lessons learned for future deployments:_

1. 
2. 
3. 

---

**Deployment Lead**: _____________________  
**Date Started**: _____________________  
**Date Completed**: _____________________  
**Version**: 1.0
