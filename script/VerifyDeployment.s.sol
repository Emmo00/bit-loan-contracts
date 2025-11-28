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
 * @title Verify Deployment Script
 * @notice Verifies that deployed contracts are configured correctly
 * @dev Performs comprehensive checks on deployed protocol contracts
 */
contract VerifyDeployment is Script {
    LendingPool public lendingPool;
    CollateralManager public collateralManager;
    PriceOracle public priceOracle;
    InterestRateModel public interestRateModel;
    
    function run() external {
        // Load contract addresses from environment
        address lendingPoolAddr = vm.envAddress("LENDING_POOL_ADDRESS");
        address collateralManagerAddr = vm.envAddress("COLLATERAL_MANAGER_ADDRESS");
        address priceOracleAddr = vm.envAddress("PRICE_ORACLE_ADDRESS");
        address interestRateModelAddr = vm.envAddress("INTEREST_RATE_MODEL_ADDRESS");
        
        lendingPool = LendingPool(lendingPoolAddr);
        collateralManager = CollateralManager(collateralManagerAddr);
        priceOracle = PriceOracle(priceOracleAddr);
        interestRateModel = InterestRateModel(interestRateModelAddr);
        
        console.log("=== BitLoan Protocol Deployment Verification ===");
        console.log("");
        
        // Verify contract addresses
        verifyContractAddresses();
        
        // Verify contract configurations
        verifyConfigurations();
        
        // Verify contract relationships
        verifyRelationships();
        
        // Verify access control
        verifyAccessControl();
        
        // Perform sanity checks
        performSanityChecks();
        
        console.log("=== Verification Complete ===");
    }
    
    function verifyContractAddresses() internal view {
        console.log("1. Verifying Contract Addresses:");
        console.log("   LendingPool:", address(lendingPool));
        console.log("   CollateralManager:", address(collateralManager));
        console.log("   PriceOracle:", address(priceOracle));
        console.log("   InterestRateModel:", address(interestRateModel));
        
        // Check that contracts are deployed (have code)
        require(address(lendingPool).code.length > 0, "LendingPool not deployed");
        require(address(collateralManager).code.length > 0, "CollateralManager not deployed");
        require(address(priceOracle).code.length > 0, "PriceOracle not deployed");
        require(address(interestRateModel).code.length > 0, "InterestRateModel not deployed");
        
        console.log("   [SUCCESS] All contracts are deployed");
        console.log("");
    }
    
    function verifyConfigurations() internal view {
        console.log("2. Verifying Contract Configurations:");
        
        // LendingPool configuration
        address borrowAsset = address(lendingPool.borrowAsset());
        uint256 borrowIndex = lendingPool.borrowIndex();
        uint256 supplyIndex = lendingPool.supplyIndex();
        uint256 reserveFactor = lendingPool.reserveFactor();
        uint256 liquidationBonus = lendingPool.liquidationBonus();
        uint256 closeFactor = lendingPool.closeFactor();
        
        console.log("   LendingPool:");
        console.log("   - Borrow Asset:", borrowAsset);
        console.log("   - Borrow Index:", borrowIndex);
        console.log("   - Supply Index:", supplyIndex);
        console.log("   - Reserve Factor:", reserveFactor);
        console.log("   - Liquidation Bonus:", liquidationBonus);
        console.log("   - Close Factor:", closeFactor);
        
        require(borrowAsset != address(0), "Invalid borrow asset");
        require(borrowIndex == 1e18, "Invalid initial borrow index");
        require(supplyIndex == 1e18, "Invalid initial supply index");
        require(reserveFactor <= 1e18, "Invalid reserve factor");
        require(liquidationBonus >= 1e18, "Invalid liquidation bonus");
        require(closeFactor <= 1e18, "Invalid close factor");
        
        // CollateralManager configuration
        uint256 collateralFactor = collateralManager.getCollateralFactor();
        uint256 liquidationThreshold = collateralManager.getLiquidationThreshold();
        
        console.log("   CollateralManager:");
        console.log("   - Collateral Factor:", collateralFactor);
        console.log("   - Liquidation Threshold:", liquidationThreshold);
        
        require(collateralFactor > 0 && collateralFactor <= 1e18, "Invalid collateral factor");
        require(liquidationThreshold > 0 && liquidationThreshold <= 1e18, "Invalid liquidation threshold");
        require(liquidationThreshold > collateralFactor, "Liquidation threshold must be > collateral factor");
        
        // PriceOracle configuration
        uint256 ethPrice = priceOracle.getEthPrice();
        console.log("   PriceOracle:");
        console.log("   - ETH Price:", ethPrice);
        
        require(ethPrice > 0, "Invalid ETH price");
        
        console.log("   [SUCCESS] All configurations are valid");
        console.log("");
    }
    
    function verifyRelationships() internal view {
        console.log("3. Verifying Contract Relationships:");
        
        // Check that LendingPool has correct references
        require(address(lendingPool.collateralManager()) == address(collateralManager), "LendingPool: Wrong CollateralManager");
        require(address(lendingPool.priceOracle()) == address(priceOracle), "LendingPool: Wrong PriceOracle");
        require(address(lendingPool.interestRateModel()) == address(interestRateModel), "LendingPool: Wrong InterestRateModel");
        
        // Check that CollateralManager has correct references
        require(address(collateralManager.priceOracle()) == address(priceOracle), "CollateralManager: Wrong PriceOracle");
        require(address(collateralManager.lendingPool()) == address(lendingPool), "CollateralManager: Wrong LendingPool");
        
        console.log("   [SUCCESS] Contract references are correct");
        console.log("");
    }
    
    function verifyAccessControl() internal view {
        console.log("4. Verifying Access Control:");
        
        // Check ownership
        address lendingPoolOwner = lendingPool.owner();
        address collateralManagerOwner = collateralManager.owner();
        address priceOracleOwner = priceOracle.owner();
        
        console.log("   Owners:");
        console.log("   - LendingPool:", lendingPoolOwner);
        console.log("   - CollateralManager:", collateralManagerOwner);
        console.log("   - PriceOracle:", priceOracleOwner);
        
        // Check that owners are set (not zero address)
        require(lendingPoolOwner != address(0), "LendingPool: No owner");
        require(collateralManagerOwner != address(0), "CollateralManager: No owner");
        require(priceOracleOwner != address(0), "PriceOracle: No owner");
        
        console.log("   [SUCCESS] Access control is properly configured");
        console.log("");
    }
    
    function performSanityChecks() internal view {
        console.log("5. Performing Sanity Checks:");
        
        // Check interest rates are reasonable
        uint256 borrowRate = lendingPool.borrowRate();
        uint256 supplyRate = lendingPool.supplyRate();
        uint256 utilization = lendingPool.utilization();
        
        console.log("   Interest Rates:");
        console.log("   - Borrow Rate:", borrowRate);
        console.log("   - Supply Rate:", supplyRate);
        console.log("   - Utilization:", utilization);
        
        require(borrowRate <= 1e19, "Borrow rate too high (>1000%)"); // Max 1000% APR
        require(supplyRate <= borrowRate, "Supply rate cannot exceed borrow rate");
        
        // Check protocol state is clean (new deployment)
        uint256 totalBorrows = lendingPool.totalBorrows();
        uint256 totalSupply = lendingPool.totalSupply();
        uint256 totalReserves = lendingPool.totalReserves();
        
        console.log("   Protocol State:");
        console.log("   - Total Borrows:", totalBorrows);
        console.log("   - Total Supply:", totalSupply);
        console.log("   - Total Reserves:", totalReserves);
        
        require(totalBorrows == 0, "Protocol should start with zero borrows");
        require(totalSupply == 0, "Protocol should start with zero supply");
        require(totalReserves == 0, "Protocol should start with zero reserves");
        
        console.log("   [SUCCESS] All sanity checks passed");
        console.log("");
    }
}