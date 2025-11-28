# BitLoan Protocol Deployment Scripts

This directory contains comprehensive deployment and management scripts for the BitLoan lending protocol.

## Scripts Overview

### 1. Deploy.s.sol
Main deployment script that handles the complete protocol deployment:
- Deploys PriceOracle, InterestRateModel, CollateralManager, and LendingPool
- Configures all contracts correctly
- Validates deployment parameters
- Provides detailed logging

### 2. DeployLocal.s.sol
Local development deployment script:
- Deploys a mock ERC20 token for testing
- Sets up the complete protocol with test-friendly parameters
- Mints tokens to test addresses
- Provides testing instructions

### 3. DeployMainnet.s.sol
Production deployment script:
- Uses real token addresses
- Production-ready configuration (conservative parameters)
- Enhanced validation and security checks
- Provides verification commands and post-deployment checklist

### 4. ManageProtocol.s.sol
Protocol management utilities:
- Update protocol parameters
- Transfer ownership
- Monitor protocol state
- Administrative functions

## Quick Start

### Local Development
```bash
# Deploy to local blockchain with mock token
forge script script/DeployLocal.s.sol --fork-url http://localhost:8545 --broadcast

# Or use anvil
anvil &
forge script script/DeployLocal.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

### Testnet Deployment
```bash
# Set environment variables
export BORROW_ASSET=0x... # Address of the token you want to use as borrow asset
export INITIAL_ETH_PRICE=3000000000000000000000 # $3000 in wei (3000 * 1e18)
export RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=your_private_key

# Deploy to testnet
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

### Mainnet Deployment
```bash
# Set production environment variables
export MAINNET_BORROW_ASSET=0xA0b86a33E6441029525958EbD69E5757Ac5557c3 # USDC
export MAINNET_ETH_PRICE=2500000000000000000000 # Current ETH price * 1e18
export MAINNET_COLLATERAL_FACTOR=750000000000000000 # 75% * 1e18
export MAINNET_LIQUIDATION_THRESHOLD=800000000000000000 # 80% * 1e18
export RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=your_private_key

# Deploy to mainnet (BE VERY CAREFUL!)
forge script script/DeployMainnet.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## Environment Variables

### Required for Production
- `BORROW_ASSET`: Address of the ERC20 token to use as the borrowing asset
- `RPC_URL`: RPC endpoint for the target network
- `PRIVATE_KEY`: Private key of the deployer account

### Optional Configuration
- `INITIAL_ETH_PRICE`: Initial ETH price in wei (default: 3000 * 1e18)
- `COLLATERAL_FACTOR`: Collateral factor in wei (default: 0.8 * 1e18)
- `LIQUIDATION_THRESHOLD`: Liquidation threshold in wei (default: 0.85 * 1e18)

### For Management Script
- `LENDING_POOL_ADDRESS`: Address of deployed LendingPool
- `COLLATERAL_MANAGER_ADDRESS`: Address of deployed CollateralManager
- `PRICE_ORACLE_ADDRESS`: Address of deployed PriceOracle
- `NEW_ETH_PRICE`: New ETH price for updates
- `NEW_OWNER`: Address for ownership transfer

## Post-Deployment Checklist

### Immediate Actions
1. **Verify contracts** on block explorer using provided commands
2. **Test basic functionality** with small amounts
3. **Update ETH price** to current market price
4. **Transfer ownership** to multisig wallet (recommended)

### Production Readiness
1. **Replace PriceOracle** with real price feeds (Chainlink, etc.)
2. **Set up monitoring** for protocol health
3. **Conduct security audit** before significant TVL
4. **Implement governance** for parameter updates
5. **Set up emergency procedures**

## Protocol Parameters

### Default Values
- **Collateral Factor**: 80% (allows borrowing up to 80% of collateral value)
- **Liquidation Threshold**: 85% (liquidation occurs when debt exceeds 85% of collateral value)
- **Reserve Factor**: 10% (10% of interest goes to protocol reserves)
- **Close Factor**: 60% (max 60% of debt can be repaid in single liquidation)
- **Liquidation Bonus**: 5% (liquidators get 5% bonus)

### Interest Rate Model
- **Base Rate**: 2% APR
- **Multiplier**: 18% (rate increases linearly with utilization)
- **Max Rate**: 20% APR (at 100% utilization)

## Security Considerations

### Access Control
- All contracts use OpenZeppelin's `Ownable` for admin functions
- LendingPool can call CollateralManager functions
- Consider using multisig wallets for ownership

### Price Oracle Risk
- Current implementation uses a simple mock oracle
- **Critical**: Replace with decentralized price feeds for production
- Consider implementing price staleness checks and circuit breakers

### Parameter Validation
- All parameters are validated during deployment
- Liquidation threshold must be greater than collateral factor
- Price must be greater than zero

## Testing Commands

After local deployment, you can test the protocol:

```bash
# Get deployed addresses from logs, then:

# Deposit ETH as collateral
cast send $LENDING_POOL "depositCollateral()" --value 1ether --private-key $PRIVATE_KEY

# Deposit tokens to earn interest
cast send $LENDING_POOL "deposit(uint256)" 1000000000000000000 --private-key $PRIVATE_KEY

# Borrow tokens (requires collateral)
cast send $LENDING_POOL "borrow(uint256,address)" 100000000000000000 $YOUR_ADDRESS --private-key $PRIVATE_KEY

# Check your balances
cast call $LENDING_POOL "getSupplyBalance(address)" $YOUR_ADDRESS
cast call $LENDING_POOL "getBorrowBalance(address)" $YOUR_ADDRESS
cast call $LENDING_POOL "healthFactor(address)" $YOUR_ADDRESS
```

## Common Issues

### Deployment Failures
- Ensure you have enough ETH for gas
- Verify all environment variables are set correctly
- Check that borrow asset address is valid ERC20

### Transaction Reverts
- "LendingPool: health factor too low" - Need more collateral
- "LendingPool: insufficient supply" - Not enough tokens deposited
- "ERC20: insufficient allowance" - Need to approve tokens first

## Support

For issues or questions:
1. Check the deployment logs for error details
2. Verify all parameters are within valid ranges
3. Ensure sufficient gas and token balances
4. Review the contract source code for requirements