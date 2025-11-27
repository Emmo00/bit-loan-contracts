// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ICollateralManager
 * @dev Interface for managing collateral in a lending protocol.
 */
interface ICollateralManager {
    /**
     * @dev Deposits collateral on behalf of a user.
     * @param onBehalfOf The address of the user for whom the collateral is being deposited.
     */
    function depositCollateral(address onBehalfOf) external payable;

    /**
     * @dev Withdraws collateral for a user.
     * @param user The address of the user whose collateral is being withdrawn.
     * @param amount The amount of collateral to withdraw.
     * @param to The address to which the withdrawn collateral will be sent.
     */
    function withdrawCollateral(address user, uint256 amount, address to) external;

    /**
     * @dev Gets the total collateral of a user.
     * @param user The address of the user.
     * @return The total collateral amount of the user.
     */
    function getUserCollateral(address user) external view returns (uint256);

    /**
     * @dev Gets the collateral value of a user.
     * @param user The address of the user.
     * @return The collateral value of the user.
     */
    function getCollateralValue(address user) external view returns (uint256);

    /**
     * @dev Gets the collateralizable value of a user based on the collateral factor.
     * @param user The address of the user.
     * @return The collateralizable value of the user.
     */
    function getMaxBorrow(address user) external view returns (uint256);

    /**
     * @dev Seizes collateral from a user and transfers it to a liquidator(asset liquidation).
     * @param user The address of the user whose collateral is being seized.
     * @param amount The amount of collateral to seize.
     * @param liquidator The address of the liquidator receiving the seized collateral.
     */
    function seizeCollateral(address user, uint256 amount, address liquidator) external;

    /**
     * @dev Gets the current collateral factor.
     * @return The collateral factor.
     */
    function getLiquidationThreshold() external view returns (uint256);

    /**
     * @dev Sets a new collateral factor.
     * @param newFactor The new collateral factor to set.
     */
    function setCollateralFactor(uint256 newFactor) external;

    /**
     * @dev Sets a new liquidation threshold.
     * @param newThreshold The new liquidation threshold to set.
     */
    function setLiquidationThreshold(uint256 newThreshold) external;

    /////// Events ///////
    /**
     * @dev Emitted when collateral is deposited.
     * @param user The address of the user who deposited collateral.
     * @param amount The amount of collateral deposited.
     */
    event CollateralDeposited(address indexed user, uint256 amount);

    /**
     * @dev Emitted when collateral is withdrawn.
     * @param user The address of the user who withdrew collateral.
     * @param amount The amount of collateral withdrawn.
     */
    event CollateralWithdrawn(address indexed user, uint256 amount);

    /**
     * @dev Emitted when collateral is seized.
     * @param user The address of the user whose collateral was seized.
     * @param amount The amount of collateral seized.
     * @param liquidator The address of the liquidator who received the seized collateral.
     */
    event CollateralSeized(address indexed user, uint256 amount, address indexed liquidator);

    /**
     * @dev Emitted when the collateral factor is updated.
     * @param newFactor The new collateral factor.
     */
    event CollateralFactorUpdated(uint256 newFactor);

    /**
     * @dev Emitted when the liquidation threshold is updated.
     * @param newThreshold The new liquidation threshold.
     */
    event LiquidationThresholdUpdated(uint256 newThreshold);
}
