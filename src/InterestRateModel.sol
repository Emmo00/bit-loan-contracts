// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {IInterestRateModel} from "./interfaces/IInterestRateModel.sol";

/**
 * @title Interest Rate Model
 * @author Emmo00
 * @notice A simple interest rate model where the borrow rate increases linearly with utilization
 */
contract InterestRateModel is IInterestRateModel {
    uint256 private constant BASE_RATE = 2e16; // 2% base rate
    uint256 private constant MULTIPLIER = 18e16; // 18% multiplier
    uint256 private constant UTILIZATION_SCALE = 1e18; // Scale for utilization rate

    /**
     * @notice Get the borrow rate based on the current utilization rate
     * @param utilization The current utilization rate of the lending pool (scaled by 1e18)
     * @return The borrow rate (scaled by 1e18)
     */
    function getBorrowRate(uint256 utilization) external pure override returns (uint256) {
        return BASE_RATE + (MULTIPLIER * utilization) / UTILIZATION_SCALE;
    }

    /**
     * @notice Get the supply rate based on the current utilization rate, borrow rate, and reserve factor
     * @param utilization The current utilization rate of the lending pool (scaled by 1e18)
     * @param borrowRate The current borrow rate (scaled by 1e18)
     * @param reserveFactor The reserve factor (scaled by 1e18)
     * @return The supply rate (scaled by 1e18)
     */
    function getSupplyRate(uint256 utilization, uint256 borrowRate, uint256 reserveFactor)
        external
        pure
        override
        returns (uint256)
    {
        uint256 oneMinusReserveFactor = UTILIZATION_SCALE - reserveFactor;
        return (utilization * borrowRate * oneMinusReserveFactor) / (UTILIZATION_SCALE * UTILIZATION_SCALE);
    }
}
