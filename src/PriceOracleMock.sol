// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Price Oracle
 * @author Emmo00
 * @notice get the price of eth against the borrow asset of the lending pool
 */
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract PriceOracle is IPriceOracle, Ownable {
    uint256 private ethPrice;
    
    event PriceUpdated(uint256 newPrice);

    constructor(uint256 _initialPrice) Ownable(msg.sender) {
        require(_initialPrice > 0, "PriceOracle: invalid initial price");
        ethPrice = _initialPrice;
    }

    function setEthPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "PriceOracle: invalid price");
        ethPrice = _newPrice;
        emit PriceUpdated(_newPrice);
    }

    function getEthPrice() external view override returns (uint256) {
        return ethPrice;
    }
}
