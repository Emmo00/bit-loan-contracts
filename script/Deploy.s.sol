// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {LendingPool} from "../src/LendingPool.sol";
import {CollateralManager} from "../src/CollateralManager.sol";
import {PriceOracle} from "../src/PriceOracleMock.sol";
import {InterestRateModel} from "../src/InterestRateModel.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

/**
 * @title Deploy Script
 * @notice Main deployment script for the BitLoan protocol
 * @dev Deploys all contracts in the correct order and configures them
 */
contract Deploy is Script {
    // Default deployment parameters (can be overridden via environment variables)
    uint256 public constant DEFAULT_INITIAL_ETH_PRICE = 3000e18; // $3000 per ETH (scaled by 1e18)
    uint256 public constant DEFAULT_COLLATERAL_FACTOR = 8e17; // 80% (0.8 * 1e18)
    uint256 public constant DEFAULT_LIQUIDATION_THRESHOLD = 85e16; // 85% (0.85 * 1e18)
    
    // Contract instances
    PriceOracle public priceOracle;
    InterestRateModel public interestRateModel;
    CollateralManager public collateralManager;
    LendingPool public lendingPool;

    struct DeploymentConfig {
        address borrowAsset;
        uint256 initialEthPrice;
        uint256 collateralFactor;
        uint256 liquidationThreshold;
    }

    function run() external virtual {
        // Load deployment configuration
        DeploymentConfig memory config = getDeploymentConfig();
        
        // Validate configuration
        validateConfig(config);
        
        vm.startBroadcast();
        
        console.log("=== BitLoan Protocol Deployment ===");
        console.log("Deployer address:", msg.sender);
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
        logDeploymentSummary(config);
    }
    
    function deployPriceOracle(uint256 initialEthPrice) internal {
        console.log("Deploying PriceOracle...");
        priceOracle = new PriceOracle(initialEthPrice);
        console.log("PriceOracle deployed at:", address(priceOracle));
        console.log("Initial ETH price:", initialEthPrice);
        console.log("");
    }
    
    function deployInterestRateModel() internal {
        console.log("Deploying InterestRateModel...");
        interestRateModel = new InterestRateModel();
        console.log("InterestRateModel deployed at:", address(interestRateModel));
        console.log("");
    }
    
    function deployCollateralManager(uint256 collateralFactor, uint256 liquidationThreshold) internal {
        console.log("Deploying CollateralManager...");
        collateralManager = new CollateralManager(
            address(priceOracle),
            collateralFactor,
            liquidationThreshold
        );
        console.log("CollateralManager deployed at:", address(collateralManager));
        console.log("Collateral factor:", collateralFactor);
        console.log("Liquidation threshold:", liquidationThreshold);
        console.log("");
    }
    
    function deployLendingPool(address borrowAsset) internal {
        console.log("Deploying LendingPool...");
        lendingPool = new LendingPool(
            borrowAsset,
            address(collateralManager),
            address(priceOracle),
            address(interestRateModel)
        );
        console.log("LendingPool deployed at:", address(lendingPool));
        console.log("");
    }
    
    function configureContracts() internal {
        console.log("Configuring contracts...");
        
        // Set the lending pool address in the collateral manager
        collateralManager.setLendingPool(address(lendingPool));
        console.log("[SUCCESS] Lending pool address set in CollateralManager");
        
        console.log("[SUCCESS] All contracts configured successfully");
        console.log("");
    }
    
    function getDeploymentConfig() internal view returns (DeploymentConfig memory) {
        return DeploymentConfig({
            borrowAsset: vm.envOr("BORROW_ASSET", address(0)),
            initialEthPrice: vm.envOr("INITIAL_ETH_PRICE", DEFAULT_INITIAL_ETH_PRICE),
            collateralFactor: vm.envOr("COLLATERAL_FACTOR", DEFAULT_COLLATERAL_FACTOR),
            liquidationThreshold: vm.envOr("LIQUIDATION_THRESHOLD", DEFAULT_LIQUIDATION_THRESHOLD)
        });
    }
    
    function validateConfig(DeploymentConfig memory config) internal pure {
        require(config.borrowAsset != address(0), "Deploy: BORROW_ASSET must be set");
        require(config.initialEthPrice > 0, "Deploy: Initial ETH price must be > 0");
        require(config.collateralFactor > 0 && config.collateralFactor <= 1e18, "Deploy: Invalid collateral factor");
        require(config.liquidationThreshold > 0 && config.liquidationThreshold <= 1e18, "Deploy: Invalid liquidation threshold");
        require(config.liquidationThreshold > config.collateralFactor, "Deploy: Liquidation threshold must be > collateral factor");
    }
    
    function logDeploymentSummary(DeploymentConfig memory config) internal view {
        console.log("=== Deployment Summary ===");
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
        console.log("[SUCCESS] Deployment completed successfully!");
        console.log("");
        console.log("Next steps:");
        console.log("1. Verify contracts on block explorer");
        console.log("2. Transfer ownership if needed");
        console.log("3. Update ETH price oracle as needed");
        console.log("4. Test protocol functionality");
    }
}