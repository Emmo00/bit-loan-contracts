// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @title Interest Rate Model
 * @author Emmo00
 * @notice Interface for the interest rate model used in the lending pool
 */
interface IInterestRateModel {
    /**
     * @notice Get the borrow rate based on the current utilization rate
     * @param utilization The current utilization rate of the lending pool (scaled by 1e18)
     * @return The borrow rate (scaled by 1e18)
     */
    function getBorrowRate(uint256 utilization) external view returns (uint256);

    /**
     * @notice Get the supply rate based on the current utilization rate, borrow rate, and reserve factor
     * @param utilization The current utilization rate of the lending pool (scaled by 1e18)
     * @param borrowRate The current borrow rate (scaled by 1e18)
     * @param reserveFactor The reserve factor (scaled by 1e18)
     * @return The supply rate (scaled by 1e18)
     */
    function getSupplyRate(uint256 utilization, uint256 borrowRate, uint256 reserveFactor)
        external
        view
        returns (uint256);
}
