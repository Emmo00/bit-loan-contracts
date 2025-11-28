// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Deploy} from "./Deploy.s.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

/**
 * @title Local Deploy Script
 * @notice Deployment script for local testing with mock ERC20 token
 * @dev Creates a mock ERC20 token and deploys the entire protocol for testing
 */
contract DeployLocal is Deploy {
    MockERC20 public mockToken;
    
    function run() external override {
        vm.startBroadcast();
        
        console.log("=== BitLoan Protocol Local Deployment ===");
        console.log("Deployer address:", msg.sender);
        console.log("");
        
        // Deploy mock ERC20 token for testing
        deployMockToken();
        
        // Create deployment config with mock token
        DeploymentConfig memory config = DeploymentConfig({
            borrowAsset: address(mockToken),
            initialEthPrice: DEFAULT_INITIAL_ETH_PRICE,
            collateralFactor: DEFAULT_COLLATERAL_FACTOR,
            liquidationThreshold: DEFAULT_LIQUIDATION_THRESHOLD
        });
        
        // Validate configuration
        validateConfig(config);
        
        // Deploy all protocol contracts
        deployPriceOracle(config.initialEthPrice);
        deployInterestRateModel();
        deployCollateralManager(config.collateralFactor, config.liquidationThreshold);
        deployLendingPool(config.borrowAsset);
        
        // Configure contracts
        configureContracts();
        
        // Setup initial token balances for testing
        setupTestEnvironment();
        
        vm.stopBroadcast();
        
        // Log deployment summary
        logLocalDeploymentSummary(config);
    }
    
    function deployMockToken() internal {
        console.log("Deploying Mock ERC20 Token...");
        mockToken = new MockERC20("BitLoan Test Token", "BTT", 18);
        
        // Mint initial supply to deployer for testing
        mockToken.mint(msg.sender, 1_000_000e18); // 1M tokens
        
        console.log("MockERC20 deployed at:", address(mockToken));
        console.log("Initial supply minted to deployer: 1,000,000 tokens");
        console.log("");
    }
    
    function setupTestEnvironment() internal {
        console.log("Setting up test environment...");
        
        // Approve lending pool to spend tokens for easy testing
        mockToken.approve(address(lendingPool), type(uint256).max);
        console.log("[SUCCESS] Approved LendingPool for unlimited token spending");
        
        // Mint tokens to a few test addresses
        address[] memory testUsers = new address[](3);
        testUsers[0] = address(0x1111111111111111111111111111111111111111);
        testUsers[1] = address(0x2222222222222222222222222222222222222222);
        testUsers[2] = address(0x3333333333333333333333333333333333333333);
        
        for (uint256 i = 0; i < testUsers.length; i++) {
            mockToken.mint(testUsers[i], 100_000e18); // 100k tokens each
            console.log("[SUCCESS] Minted 100k tokens to test user:", testUsers[i]);
        }
        
        console.log("[SUCCESS] Test environment setup completed");
        console.log("");
    }
    
    function logLocalDeploymentSummary(DeploymentConfig memory config) internal view {
        console.log("=== Local Deployment Summary ===");
        console.log("MockERC20 Token:", address(mockToken));
        console.log("PriceOracle:", address(priceOracle));
        console.log("InterestRateModel:", address(interestRateModel));
        console.log("CollateralManager:", address(collateralManager));
        console.log("LendingPool:", address(lendingPool));
        console.log("");
        console.log("Configuration:");
        console.log("- Borrow Asset:", config.borrowAsset);
        console.log("- Initial ETH Price:", config.initialEthPrice);
        console.log("- Collateral Factor:", config.collateralFactor);
        console.log("- Liquidation Threshold:", config.liquidationThreshold);
        console.log("");
        console.log("[SUCCESS] Local deployment completed successfully!");
        console.log("");
        console.log("Test with:");
        console.log("- Deposit ETH as collateral: cast send <lendingPool> 'depositCollateral()' --value 1000000000000000000 --private-key <key>");
        console.log("- Deposit tokens: cast send <lendingPool> 'deposit(uint256)' 1000000000000000000 --private-key <key>");
        console.log("- Borrow tokens: cast send <lendingPool> 'borrow(uint256,address)' 100000000000000000 <receiver> --private-key <key>");
    }
}