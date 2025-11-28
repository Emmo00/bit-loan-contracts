// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {LendingPool} from "../src/LendingPool.sol";
import {CollateralManager} from "../src/CollateralManager.sol";
import {PriceOracle} from "../src/PriceOracleMock.sol";

/**
 * @title Protocol Management Script
 * @notice Utility script for managing deployed protocol contracts
 * @dev Provides functions for updating parameters, ownership transfers, etc.
 */
contract ManageProtocol is Script {
    LendingPool public lendingPool;
    CollateralManager public collateralManager;
    PriceOracle public priceOracle;
    
    function run() external {
        // Load contract addresses from environment variables
        address lendingPoolAddr = vm.envAddress("LENDING_POOL_ADDRESS");
        address collateralManagerAddr = vm.envAddress("COLLATERAL_MANAGER_ADDRESS");
        address priceOracleAddr = vm.envAddress("PRICE_ORACLE_ADDRESS");
        
        lendingPool = LendingPool(lendingPoolAddr);
        collateralManager = CollateralManager(collateralManagerAddr);
        priceOracle = PriceOracle(priceOracleAddr);
        
        vm.startBroadcast();
        
        console.log("=== Protocol Management ===");
        console.log("Managing protocol contracts...");
        
        // Example management operations (uncomment as needed)
        // updateEthPrice();
        // updateCollateralFactor();
        // updateLiquidationThreshold();
        // transferOwnership();
        
        vm.stopBroadcast();
    }
    
    function updateEthPrice() internal {
        uint256 newPrice = vm.envUint("NEW_ETH_PRICE");
        console.log("Updating ETH price to:", newPrice);
        priceOracle.setEthPrice(newPrice);
        console.log("[SUCCESS] ETH price updated");
    }
    
    function updateCollateralFactor() internal {
        uint256 newFactor = vm.envUint("NEW_COLLATERAL_FACTOR");
        console.log("Updating collateral factor to:", newFactor);
        lendingPool.setCollateralFactor(newFactor);
        console.log("[SUCCESS] Collateral factor updated");
    }
    
    function updateLiquidationThreshold() internal {
        uint256 newThreshold = vm.envUint("NEW_LIQUIDATION_THRESHOLD");
        console.log("Updating liquidation threshold to:", newThreshold);
        lendingPool.setLiquidationThreshold(newThreshold);
        console.log("[SUCCESS] Liquidation threshold updated");
    }
    
    function updateReserveFactor() internal {
        uint256 newReserveFactor = vm.envUint("NEW_RESERVE_FACTOR");
        console.log("Updating reserve factor to:", newReserveFactor);
        lendingPool.setReserveFactor(newReserveFactor);
        console.log("[SUCCESS] Reserve factor updated");
    }
    
    function updateCloseFactor() internal {
        uint256 newCloseFactor = vm.envUint("NEW_CLOSE_FACTOR");
        console.log("Updating close factor to:", newCloseFactor);
        lendingPool.setCloseFactor(newCloseFactor);
        console.log("[SUCCESS] Close factor updated");
    }
    
    function updateLiquidationBonus() internal {
        uint256 newBonus = vm.envUint("NEW_LIQUIDATION_BONUS");
        console.log("Updating liquidation bonus to:", newBonus);
        lendingPool.setLiquidationBonus(newBonus);
        console.log("[SUCCESS] Liquidation bonus updated");
    }
    
    function transferOwnership() internal {
        address newOwner = vm.envAddress("NEW_OWNER");
        console.log("Transferring ownership to:", newOwner);
        
        lendingPool.transferOwnership(newOwner);
        collateralManager.transferOwnership(newOwner);
        priceOracle.transferOwnership(newOwner);
        
        console.log("[SUCCESS] Ownership transferred for all contracts");
    }
    
    function getProtocolInfo() external view {
        console.log("=== Protocol Information ===");
        console.log("LendingPool:", address(lendingPool));
        console.log("CollateralManager:", address(collateralManager));
        console.log("PriceOracle:", address(priceOracle));
        console.log("");
        
        console.log("Current Parameters:");
        console.log("- ETH Price:", priceOracle.getEthPrice());
        console.log("- Collateral Factor:", collateralManager.getCollateralFactor());
        console.log("- Liquidation Threshold:", collateralManager.getLiquidationThreshold());
        console.log("- Reserve Factor:", lendingPool.reserveFactor());
        console.log("- Close Factor:", lendingPool.closeFactor());
        console.log("- Liquidation Bonus:", lendingPool.liquidationBonus());
        console.log("");
        
        console.log("Protocol State:");
        console.log("- Total Borrows:", lendingPool.totalBorrows());
        console.log("- Total Supply:", lendingPool.totalSupply());
        console.log("- Total Reserves:", lendingPool.totalReserves());
        console.log("- Utilization:", lendingPool.utilization());
        console.log("- Borrow Rate:", lendingPool.borrowRate());
        console.log("- Supply Rate:", lendingPool.supplyRate());
    }
}