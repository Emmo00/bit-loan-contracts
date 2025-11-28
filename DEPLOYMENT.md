# BitLoan Protocol - Quick Deployment Guide

## 🚀 Complete Deployment Setup

I've created comprehensive deployment scripts for your BitLoan lending protocol. Here's everything you need:

### 📁 Files Created

1. **`script/Deploy.s.sol`** - Main deployment script
2. **`script/DeployLocal.s.sol`** - Local testing with mock tokens
3. **`script/DeployMainnet.s.sol`** - Production deployment
4. **`script/ManageProtocol.s.sol`** - Protocol management utilities
5. **`script/VerifyDeployment.s.sol`** - Deployment verification
6. **`script/mocks/MockERC20.sol`** - Mock ERC20 for testing
7. **`script/README.md`** - Detailed documentation
8. **`script/.env.example`** - Environment configuration template
9. **`Makefile`** - Convenient deployment commands

### ⚡ Quick Start Commands

#### Local Testing
```bash
# Start local blockchain
anvil

# Deploy with mock token (in another terminal)
make deploy-local
# OR
forge script script/DeployLocal.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

#### Testnet Deployment
```bash
# Set environment variables
export BORROW_ASSET=0x... # Your ERC20 token address
export RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=0x...

# Deploy to testnet
make deploy-sepolia
# OR
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

#### Production Deployment
```bash
# Set production environment variables
export MAINNET_BORROW_ASSET=0xA0B86a33E6441029525958EBD69E5757ac5557C3  # USDC
export RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
export PRIVATE_KEY=0x...

# Deploy to mainnet (BE CAREFUL!)
make deploy-mainnet
```

### 🎯 Deployment Order

The scripts automatically deploy contracts in the correct order:

1. **PriceOracle** - Mock oracle with configurable ETH price
2. **InterestRateModel** - Linear interest rate model (2% base + 18% slope)
3. **CollateralManager** - Manages ETH collateral deposits/withdrawals
4. **LendingPool** - Main lending contract
5. **Configuration** - Sets up contract relationships

### 🛡️ Default Parameters

- **Collateral Factor**: 80% (can borrow up to 80% of collateral value)
- **Liquidation Threshold**: 85% (liquidation when debt > 85% of collateral)
- **Reserve Factor**: 10% (protocol keeps 10% of interest)
- **Close Factor**: 60% (max liquidation per transaction)
- **Liquidation Bonus**: 5% (liquidators get 5% bonus)

### 🔧 Environment Variables

Required for production:
```bash
BORROW_ASSET=0x...           # ERC20 token address for lending
RPC_URL=https://...          # Blockchain RPC endpoint
PRIVATE_KEY=0x...            # Deployer private key
```

Optional configuration:
```bash
INITIAL_ETH_PRICE=3000000000000000000000      # $3000 * 1e18
COLLATERAL_FACTOR=800000000000000000          # 80% * 1e18
LIQUIDATION_THRESHOLD=850000000000000000      # 85% * 1e18
```

### 📋 Post-Deployment Checklist

1. **Verify contracts** on block explorer
2. **Test basic functions** with small amounts
3. **Update ETH price** to current market rate
4. **Transfer ownership** to multisig (recommended)
5. **Replace PriceOracle** with real price feeds
6. **Set up monitoring**

### 🧪 Testing After Deployment

```bash
# Deposit ETH as collateral
cast send $LENDING_POOL "depositCollateral()" --value 1ether --private-key $KEY

# Deposit tokens to earn interest  
cast send $LENDING_POOL "deposit(uint256)" 1000000000000000000 --private-key $KEY

# Borrow tokens (requires collateral)
cast send $LENDING_POOL "borrow(uint256,address)" 100000000000000000 $ADDRESS --private-key $KEY

# Check balances
cast call $LENDING_POOL "getSupplyBalance(address)" $ADDRESS
cast call $LENDING_POOL "getBorrowBalance(address)" $ADDRESS
cast call $LENDING_POOL "healthFactor(address)" $ADDRESS
```

### ⚠️ Security Notes

- **PriceOracle is a MOCK** - Replace with Chainlink or other reliable oracle for production
- **Use multisig wallets** for ownership in production
- **Audit contracts** before significant TVL
- **Start with small amounts** for testing
- **Monitor protocol health** continuously

### 🔍 Contract Verification

After deployment, verify contracts:
```bash
forge verify-contract <address> <contract> --constructor-args <args> --rpc-url <rpc>
```

The deployment scripts provide the exact commands needed.

### 📞 Management Functions

Use `ManageProtocol.s.sol` to:
- Update ETH price
- Change collateral parameters  
- Transfer ownership
- Monitor protocol state

### 🎉 Ready to Deploy!

Your deployment scripts are ready. The protocol follows these deployment dependencies:

**CollateralManager** → **PriceOracle** → **InterestRateModel** → **LendingPool**

Everything is configured automatically with sensible defaults for immediate testing or production use.

---

**Need help?** Check `script/README.md` for detailed documentation and troubleshooting.