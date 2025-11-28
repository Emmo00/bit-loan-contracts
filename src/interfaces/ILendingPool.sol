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
     * Deposit collateral
     */
    function depositCollateral() external payable;

    /**
     * Withdraws a specified amount of the pool asset from the lending pool.
     * @param amount amount of the pool asset to withdraw
     * @param receiver address of the receiver
     */
    function withdraw(uint256 amount, address receiver) external;

    /**
     * Withdraw collateral from lending pool
     * @param amount amount of collateral to withdraw
     * @param receiver address to send the collateral to
     */
    function withdrawCollateral(uint256 amount, address receiver) external;

    /**
     * Gets the supply balance of a user (including interest).
     * @param user address of the user
     * @return supply balance of the user
     */
    function getSupplyBalance(address user) external view returns (uint256);

    //////////// BORROW ////////////
    /**
     * Borrows a specified amount of the pool asset from the lending pool.
     * @param amount amount of the pool asset to borrow
     * @param receiver address of the receiver of the loan
     */
    function borrow(uint256 amount, address receiver) external;

    /**
     * Repays a specified amount of the pool asset to the lending pool.
     * @param borrower address of the borrower whose debt is being paid
     * @param amount amount of the pool asset to repay
     */
    function repay(address borrower, uint256 amount) external;

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
     * Gets the health factor of the user after a hypothetical borrow
     * @param user address of the user
     * @param borrowAmount amount of the asset to be borrowed
     * @return health health factor of the user after hypothetical borrow (scaled)
     */
    function healthFactorAfterBorrow(address user, uint256 borrowAmount) external view returns (uint256);

    /**
     * Gets the health factor of a user after a hypothetical collateral withdrawal.
     * @param user address of the user
     * @param withdrawAmount amount of collateral to hypothetically withdraw
     * @return health factor of the user after the hypothetical withdrawal
     */
    function healthFactorAfterWithdrawCollateral(address user, uint256 withdrawAmount)
        external
        view
        returns (uint256);

    //////////// INTEREST RATES ////////////
    /**
     * Accrues interest on the lending pool.
     */
    function accrueInterest() external;

    /**
     * Gets the current borrow interest rate.
     * @return borrow interest rate
     */
    function borrowRate() external view returns (uint256);

    /**
     * Gets the current supply interest rate.
     * @return supply interest rate
     */
    function supplyRate() external view returns (uint256);

    /**
     * Gets the current utilization rate of the lending pool.
     * @return utilization rate
     */
    function utilization() external view returns (uint256);

    /**
     * Gets the total collateral deposited in the protocol.
     * @return total collateral amount
     */
    function totalCollateral() external view returns (uint256);

    //////////// LIQUIDATION ////////////
    /**
     * Liquidates a specified amount of a user's borrow.
     * @param user address of the user to liquidate
     * @param amount amount of the pool asset to liquidate
     */
    function liquidate(address user, uint256 amount) external;

    //////////// ADMIN ///////////////////
    function setCollateralFactor(uint256 newFactor) external;
    function setLiquidationThreshold(uint256 newThreshold) external;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount, address receiver);
    event Borrow(address indexed user, uint256 amount, address receiver);
    event Repay(address indexed payer, address indexed borrower, uint256 amount);
    event Liquidate(
        address indexed liquidator, address indexed borrower, uint256 repayAmount, uint256 seizedCollateral
    );
    event AccrueInterest(uint256 borrowIndex, uint256 supplyIndex, uint256 interestAccrued, uint256 reservesAdded);
}
