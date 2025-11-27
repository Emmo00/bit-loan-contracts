// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {ICollateralManager} from "./interfaces/ICollateralManager.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";

/**
 * @title Collateral Manager
 * @author Emmo00
 * @dev Manages collateral deposits, withdrawals, and valuations in a lending protocol.
 */
contract CollateralManager is ICollateralManager {
    uint public collateralFactor;
    uint256 private constant SCALE = 1e18;
    uint256 private constant HEALTH_FACTOR_THRESHOLD = 1 * SCALE;

    IPriceOracle public immutable priceOracle;

    mapping(address => uint256) private _collaterals;
    ILendingPool public immutable lendingPool;

    constructor(address _priceOracle, address _lendingPool, uint256 _collateralFactor) {
        require(_priceOracle != address(0), "CollateralManager: Invalid price oracle address");
        require(_lendingPool != address(0), "CollateralManager: Invalid lending pool address");
        require(_collateralFactor > 0 && _collateralFactor <= SCALE, "CollateralManager: Invalid collateral factor");

        priceOracle = IPriceOracle(_priceOracle);
        lendingPool = ILendingPool(_lendingPool);
        collateralFactor = _collateralFactor;
    }

    function depositCollateral(address onBehalfOf) external payable override {
        require(msg.value > 0, "CollateralManager: Deposit amount must be greater than zero");
        _collaterals[onBehalfOf] += msg.value;

        emit CollateralDeposited(onBehalfOf, msg.value);
    }

    function withdrawCollateral(uint256 amount) external override {
        require(amount > 0, "CollateralManager: Withdraw amount must be greater than zero");
        require(_collaterals[msg.sender] >= amount, "CollateralManager: Insufficient collateral");
        require(
            lendingPool.healthFactorAfterWithdraw(msg.sender, amount) > HEALTH_FACTOR_THRESHOLD,
            "CollateralManager: Cannot withdraw collateral that would lead to undercollateralization"
        );

        _collaterals[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit CollateralWithdrawn(msg.sender, amount);
    }

    function getUserCollateral(address user) external view override returns (uint256) {
        return _collaterals[user];
    }

    function getCollateralValue(address user) public view override returns (uint256) {
        uint256 ethPrice = priceOracle.getEthPrice();
        return (_collaterals[user] * ethPrice) / SCALE;
    }

    function getCollateralizableValue(address user) external view override returns (uint256) {
        uint256 collateralValue = getCollateralValue(user);
        return (collateralValue * collateralFactor) / SCALE;
    }

    function seizeCollateral(address user, uint256 amount, address liquidator) external override {
        require(amount > 0, "CollateralManager: Seize amount must be greater than zero");
        require(_collaterals[user] >= amount, "CollateralManager: Insufficient collateral to seize");

        _collaterals[user] -= amount;
        payable(liquidator).transfer(amount);

        emit CollateralSeized(user, amount, liquidator);
    }
}
