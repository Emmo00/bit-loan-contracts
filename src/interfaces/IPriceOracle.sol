// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @title Price Oracle
 * @notice Interface for the price oracle used in the lending pool
 */
interface IPriceOracle {
    /**
     * @notice get the price of eth against the borrow asset of the lending pool
     */
    function getEthPrice() external view returns (uint256);
}
