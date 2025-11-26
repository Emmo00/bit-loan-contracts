// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";

/**
 * @title Price Oracle
 * @author Emmo00
 * @notice get the price of eth against the borrow asset of the lending pool
 */
contract PriceOracle is IPriceOracle {
    uint256 private ethPrice;

    constructor(uint256 _initialPrice) {
        ethPrice = _initialPrice;
    }

    function setEthPrice(uint256 _newPrice) external {
        ethPrice = _newPrice;
    }

    function getEthPrice() external view override returns (uint256) {
        return ethPrice;
    }
}
