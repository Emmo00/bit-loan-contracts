// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Deploy} from "./Deploy.s.sol";

/**
 * @title Mainnet Deploy Script
 * @notice Production deployment script for mainnet/testnet
 * @dev Uses real token addresses and production-ready configuration
 */
contract DeployMainnet is Deploy {
    // Production token addresses (update these for your target network)
    address public constant USDC_MAINNET = 0xA0B86a33E6441029525958EBD69E5757ac5557C3; // Example USDC address
    address public constant USDT_MAINNET = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // Example USDT address
    address public constant DAI_MAINNET = 0x6B175474E89094C44Da98b954EedeAC495271d0F;  // Example DAI address
    
    // Production configuration
    uint256 public constant MAINNET_COLLATERAL_FACTOR = 75e16;      // 75% (more conservative)
    uint256 public constant MAINNET_LIQUIDATION_THRESHOLD = 80e16;  // 80% (more conservative)
    uint256 public constant MAINNET_INITIAL_ETH_PRICE = 2500e18;    // $2500 per ETH (update based on current price)
    
    function run() external override {
        // Get borrow asset from environment or use default
        address borrowAsset = vm.envOr("MAINNET_BORROW_ASSET", USDC_MAINNET);
        
        // Create production deployment config
        DeploymentConfig memory config = DeploymentConfig({
            borrowAsset: borrowAsset,
            initialEthPrice: vm.envOr("MAINNET_ETH_PRICE", MAINNET_INITIAL_ETH_PRICE),
            collateralFactor: vm.envOr("MAINNET_COLLATERAL_FACTOR", MAINNET_COLLATERAL_FACTOR),
            liquidationThreshold: vm.envOr("MAINNET_LIQUIDATION_THRESHOLD", MAINNET_LIQUIDATION_THRESHOLD)
        });
        
        // Validate configuration
        validateConfig(config);
        
        vm.startBroadcast();
        
        console.log("=== BitLoan Protocol Mainnet Deployment ===");
        console.log("WARNING: This is a PRODUCTION deployment!");
        console.log("Deployer address:", msg.sender);
        console.log("Network chain ID:", block.chainid);
        console.log("Borrow asset:", config.borrowAsset);
        console.log("");
        
        // Deploy contracts in correct order
        deployPriceOracle(config.initialEthPrice);
        deployInterestRateModel();
        deployCollateralManager(config.collateralFactor, config.liquidationThreshold);
        deployLendingPool(config.borrowAsset);
        
        // Configure contracts
        configureContracts();
        
        vm.stopBroadcast();
        
        // Log deployment summary
        logMainnetDeploymentSummary(config);
    }
    
    function logMainnetDeploymentSummary(DeploymentConfig memory config) internal view {
        console.log("=== MAINNET Deployment Summary ===");
        console.log("PriceOracle:", address(priceOracle));
        console.log("InterestRateModel:", address(interestRateModel));
        console.log("CollateralManager:", address(collateralManager));
        console.log("LendingPool:", address(lendingPool));
        console.log("");
        console.log("Configuration:");
        console.log("- Network Chain ID:", block.chainid);
        console.log("- Borrow Asset:", config.borrowAsset);
        console.log("- Initial ETH Price:", config.initialEthPrice);
        console.log("- Collateral Factor:", config.collateralFactor);
        console.log("- Liquidation Threshold:", config.liquidationThreshold);
        console.log("");
        console.log("CRITICAL POST-DEPLOYMENT STEPS:");
        console.log("1. IMMEDIATELY verify all contracts on block explorer");
        console.log("2. Set up proper price oracle feeds (replace mock oracle)");
        console.log("3. Transfer ownership to multisig wallet");
        console.log("4. Set up monitoring and alerts");
        console.log("5. Conduct thorough testing with small amounts");
        console.log("6. Have contracts audited before significant TVL");
        console.log("");
        console.log("Contract Verification Commands:");
        console.log("Use the following commands to verify contracts:");
        console.log("PriceOracle:", address(priceOracle));
        console.log("InterestRateModel:", address(interestRateModel));
        console.log("CollateralManager:", address(collateralManager));
        console.log("LendingPool:", address(lendingPool));
    }
}