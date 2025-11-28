// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICollateralManager} from "./interfaces/ICollateralManager.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

/**
 * @title Collateral Manager
 * @author Emmo00
 * @dev Manages collateral deposits, withdrawals, and valuations in a lending protocol.
 */
contract CollateralManager is ICollateralManager, Ownable {
    uint256 public collateralFactor;
    uint256 public liquidationThreshold;
    uint256 private constant SCALE = 1e18;
    uint256 private constant HEALTH_FACTOR_THRESHOLD = 1 * SCALE;

    IPriceOracle public immutable priceOracle;

    mapping(address => uint256) private _collateralBalance;
    ILendingPool public lendingPool;

    modifier onlyLendingPool() {
        require(msg.sender == address(lendingPool), "CollateralManager: Caller is not the lending pool");
        _;
    }

    constructor(address _priceOracle, uint256 _collateralFactor, uint256 _liquidationThreshold) Ownable(msg.sender) {
        require(_priceOracle != address(0), "CollateralManager: Invalid price oracle address");
        require(_collateralFactor > 0 && _collateralFactor <= SCALE, "CollateralManager: Invalid collateral factor");
        require(
            _liquidationThreshold > 0 && _liquidationThreshold <= SCALE,
            "CollateralManager: Invalid liquidation threshold"
        );

        priceOracle = IPriceOracle(_priceOracle);
        collateralFactor = _collateralFactor;
        liquidationThreshold = _liquidationThreshold;
    }

    function depositCollateral(address onBehalfOf) external payable override onlyLendingPool {
        require(msg.value > 0, "CollateralManager: Deposit amount must be greater than zero");
        _collateralBalance[onBehalfOf] += msg.value;

        emit CollateralDeposited(onBehalfOf, msg.value);
    }

    function withdrawCollateral(address user, uint256 amount, address to) external override onlyLendingPool {
        require(amount > 0, "CollateralManager: Withdraw amount must be greater than zero");
        require(_collateralBalance[user] >= amount, "CollateralManager: Insufficient collateral");

        _collateralBalance[user] -= amount;
        payable(to).transfer(amount);
        emit CollateralWithdrawn(user, amount);
    }

    function seizeCollateral(address user, uint256 amount, address liquidator) external override onlyLendingPool {
        require(amount > 0, "CollateralManager: Seize amount must be greater than zero");

        uint256 userBalance = _collateralBalance[user];
        uint256 seizeAmount = amount > userBalance ? userBalance : amount;

        _collateralBalance[user] -= seizeAmount;
        payable(liquidator).transfer(seizeAmount);

        emit CollateralSeized(user, seizeAmount, liquidator);
    }

    function getUserCollateral(address user) external view override returns (uint256) {
        return _collateralBalance[user];
    }

    function getCollateralValue(address user) public view override returns (uint256) {
        uint256 userCollateral = _collateralBalance[user];
        if (userCollateral == 0) {
            return 0;
        }
        uint256 ethPrice = priceOracle.getEthPrice();
        // userCollateral is in wei (18 decimals), ethPrice is scaled to 18 decimals
        // Result should be in borrow asset units (also 18 decimals)
        return (userCollateral * ethPrice) / SCALE;
    }

    function getMaxBorrow(address user) external view override returns (uint256) {
        uint256 collateralValue = getCollateralValue(user);
        return (collateralValue * collateralFactor) / SCALE;
    }

    function getLiquidationThreshold() external view override returns (uint256) {
        return liquidationThreshold;
    }

    function getCollateralFactor() external view override returns (uint256) {
        return collateralFactor;
    }

    function setCollateralFactor(uint256 newFactor) external override onlyLendingPool {
        require(newFactor > 0 && newFactor <= SCALE, "CollateralManager: Invalid collateral factor");
        collateralFactor = newFactor;
        emit CollateralFactorUpdated(newFactor);
    }

    function setLiquidationThreshold(uint256 newThreshold) external override onlyLendingPool {
        require(newThreshold > 0 && newThreshold <= SCALE, "CollateralManager: Invalid liquidation threshold");
        liquidationThreshold = newThreshold;
        emit LiquidationThresholdUpdated(newThreshold);
    }

    function setLendingPool(address _lendingPool) external onlyOwner {
        require(address(lendingPool) == address(0), "CollateralManager: lending pool already set");
        require(_lendingPool != address(0), "CollateralManager: invalid lending pool address");
        lendingPool = ILendingPool(_lendingPool);
    }
}
