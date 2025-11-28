# BitLoan Protocol Deployment Makefile
# Provides convenient commands for deploying and managing the protocol

.PHONY: help install build test deploy-local deploy-testnet deploy-mainnet verify manage clean

# Default target
help:
	@echo "BitLoan Protocol Deployment Commands:"
	@echo ""
	@echo "Setup:"
	@echo "  make install      Install dependencies"
	@echo "  make build        Build contracts"
	@echo "  make test         Run tests"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-local     Deploy to local blockchain with mock token"
	@echo "  make deploy-sepolia   Deploy to Sepolia testnet"
	@echo "  make deploy-mainnet   Deploy to Ethereum mainnet (BE CAREFUL!)"
	@echo ""
	@echo "Management:"
	@echo "  make verify          Verify deployed contracts"
	@echo "  make manage          Run protocol management script"
	@echo "  make status          Check protocol status"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean           Clean build artifacts"
	@echo "  make format          Format code"
	@echo ""

# Setup commands
install:
	forge install

build:
	forge build

test:
	forge test -vv

# Local deployment
deploy-local:
	@echo "Deploying to local blockchain..."
	forge script script/DeployLocal.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvv

# Testnet deployment (Sepolia)
deploy-sepolia:
	@echo "Deploying to Sepolia testnet..."
	@if [ -z "$$BORROW_ASSET" ]; then echo "Error: BORROW_ASSET environment variable not set"; exit 1; fi
	@if [ -z "$$RPC_URL" ]; then echo "Error: RPC_URL environment variable not set"; exit 1; fi  
	@if [ -z "$$PRIVATE_KEY" ]; then echo "Error: PRIVATE_KEY environment variable not set"; exit 1; fi
	forge script script/Deploy.s.sol --rpc-url $$RPC_URL --private-key $$PRIVATE_KEY --broadcast --verify -vvv

# Mainnet deployment (DANGEROUS!)
deploy-mainnet:
	@echo "WARNING: You are about to deploy to MAINNET!"
	@echo "This will deploy with real money. Are you sure? [y/N]"
	@read confirm && [ "$$confirm" = "y" ] || exit 1
	@if [ -z "$$MAINNET_BORROW_ASSET" ]; then echo "Error: MAINNET_BORROW_ASSET not set"; exit 1; fi
	@if [ -z "$$RPC_URL" ]; then echo "Error: RPC_URL not set"; exit 1; fi
	@if [ -z "$$PRIVATE_KEY" ]; then echo "Error: PRIVATE_KEY not set"; exit 1; fi
	forge script script/DeployMainnet.s.sol --rpc-url $$RPC_URL --private-key $$PRIVATE_KEY --broadcast --verify -vvv

# Contract verification (if deployment verification failed)
verify:
	@echo "Verifying contracts..."
	@if [ -z "$$CONTRACT_ADDRESS" ]; then echo "Error: CONTRACT_ADDRESS not set"; exit 1; fi
	@if [ -z "$$CONTRACT_NAME" ]; then echo "Error: CONTRACT_NAME not set"; exit 1; fi
	forge verify-contract $$CONTRACT_ADDRESS $$CONTRACT_NAME --rpc-url $$RPC_URL

# Protocol management
manage:
	@echo "Running protocol management script..."
	@if [ -z "$$LENDING_POOL_ADDRESS" ]; then echo "Error: LENDING_POOL_ADDRESS not set"; exit 1; fi
	forge script script/ManageProtocol.s.sol --rpc-url $$RPC_URL --private-key $$PRIVATE_KEY --broadcast -vv

# Check protocol status
status:
	@echo "Checking protocol status..."
	forge script script/ManageProtocol.s.sol:ManageProtocol --sig "getProtocolInfo()" --rpc-url $$RPC_URL

# Utilities
clean:
	forge clean
	rm -rf cache/ out/

format:
	forge fmt

# Development helpers
anvil:
	@echo "Starting local blockchain..."
	anvil --host 0.0.0.0 --port 8545

# Quick test deployment on fresh anvil instance
test-deploy:
	@echo "Testing deployment on fresh anvil..."
	@(anvil --port 8545 &) && sleep 2
	@make deploy-local
	@pkill anvil

# Environment setup
setup-env:
	@if [ ! -f .env ]; then \
		echo "Creating .env file from example..."; \
		cp script/.env.example .env; \
		echo "Please edit .env file with your configuration"; \
	else \
		echo ".env file already exists"; \
	fi

# Load environment variables if .env exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Network-specific quick deploys
sepolia: RPC_URL=https://sepolia.infura.io/v3/$(INFURA_KEY)
sepolia: deploy-sepolia

goerli: RPC_URL=https://goerli.infura.io/v3/$(INFURA_KEY) 
goerli: deploy-sepolia

mainnet: RPC_URL=https://mainnet.infura.io/v3/$(INFURA_KEY)
mainnet: deploy-mainnet

# Help for specific commands
help-deploy:
	@echo "Deployment Help:"
	@echo ""
	@echo "Required Environment Variables:"
	@echo "  RPC_URL        - RPC endpoint for target network"
	@echo "  PRIVATE_KEY    - Private key of deployer account"
	@echo "  BORROW_ASSET   - Address of ERC20 token to use (for testnet/mainnet)"
	@echo ""
	@echo "Optional Variables:"
	@echo "  INITIAL_ETH_PRICE      - Initial ETH price (default: 3000e18)"
	@echo "  COLLATERAL_FACTOR      - Collateral factor (default: 0.8e18)"
	@echo "  LIQUIDATION_THRESHOLD  - Liquidation threshold (default: 0.85e18)"
	@echo ""
	@echo "Examples:"
	@echo "  BORROW_ASSET=0x... RPC_URL=https://... PRIVATE_KEY=0x... make deploy-sepolia"
	@echo ""

help-manage:
	@echo "Protocol Management Help:"
	@echo ""
	@echo "Required Environment Variables:"
	@echo "  LENDING_POOL_ADDRESS       - Address of deployed LendingPool"
	@echo "  COLLATERAL_MANAGER_ADDRESS - Address of deployed CollateralManager"
	@echo "  PRICE_ORACLE_ADDRESS       - Address of deployed PriceOracle"
	@echo ""
	@echo "Management Variables (set as needed):"
	@echo "  NEW_ETH_PRICE          - Update ETH price"
	@echo "  NEW_COLLATERAL_FACTOR  - Update collateral factor"
	@echo "  NEW_OWNER             - Transfer ownership"
	@echo ""