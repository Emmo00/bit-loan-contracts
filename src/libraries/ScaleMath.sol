// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ScaleMath {
    function scaleMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b) / 1e18;
    }

    function scaleDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * 1e18) / b;
    }
}
