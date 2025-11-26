// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @title ILiquidationModule
 * @dev Interface for liquidating undercollateralized positions in a lending protocol.
 */
interface ILiquidationModule {
    /**
     * @dev Liquidates a borrower's position by repaying a portion of their debt and seizing their collateral.
     * @param borrower The address of the borrower whose position is being liquidated.
     * @param repayAmount The amount of debt to repay on behalf of the borrower.
     */
    function liquidate(address borrower, uint256 repayAmount) external;
}
