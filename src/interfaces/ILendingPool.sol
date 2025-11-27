// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ILendingPool
 * @dev Interface for a lending pool in a decentralized finance protocol.
 */
interface ILendingPool {
    //////////// SUPPLY ////////////
    /**
     * Deposits a specified amount of the pool asset into the lending pool.
     * @param amount amount of the pool asset to deposit
     */
    function deposit(uint256 amount) external;

    /**
     * Withdraws a specified amount of the pool asset from the lending pool.
     * @param amount amount of the pool asset to withdraw
     */
    function withdraw(uint256 amount) external;

    /**
     * Gets the supply balance of a user.
     * @param user address of the user
     * @return supply balance of the user
     */
    function getSupplyBalance(address user) external view returns (uint256);

    //////////// BORROW ////////////
    /**
     * Borrows a specified amount of the pool asset from the lending pool.
     * @param amount amount of the pool asset to borrow
     */
    function borrow(uint256 amount) external;

    /**
     * Repays a specified amount of the pool asset to the lending pool.
     * @param amount amount of the pool asset to repay
     */
    function repay(uint256 amount) external;

    /**
     * Gets the borrow balance of a user.
     * @param user address of the user
     * @return borrow balance of the user
     */
    function getBorrowBalance(address user) external view returns (uint256);

    /**
     * Gets the health factor of a user.
     * @param user address of the user
     * @return health factor of the user
     */
    function healthFactor(address user) external view returns (uint256);

    /**
     * Gets the health factor of a user after a hypothetical collateral withdrawal.
     * @param user address of the user
     * @param withdrawAmount amount of collateral to hypothetically withdraw
     * @return health factor of the user after the hypothetical withdrawal
     */
    function healthFactorAfterWithdraw(address user, uint256 withdrawAmount) external view returns (uint256);

    //////////// INTEREST RATES ////////////
    /**
     * Accrues interest on the lending pool.
     */
    function accrueInterest() external;

    /**
     * Gets the current borrow interest rate.
     * @return borrow interest rate
     */
    function getBorrowRate() external view returns (uint256);

    /**
     * Gets the current supply interest rate.
     * @return supply interest rate
     */
    function getSupplyRate() external view returns (uint256);

    /**
     * Gets the current utilization rate of the lending pool.
     * @return utilization rate
     */
    function getUtilizationRate() external view returns (uint256);

    //////////// LIQUIDATION ////////////
    /**
     * Liquidates a specified amount of a user's borrow.
     * @param user address of the user to liquidate
     * @param amount amount of the pool asset to liquidate
     */
    function liquidate(address user, uint256 amount) external;

    /**
     * Gets the available liquidity in the lending pool.
     * @return available liquidity
     */
    function getAvailableLiquidity() external view returns (uint256);
}
