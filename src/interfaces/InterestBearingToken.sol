// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @title InterestBearingToken
 * @dev Interface for an interest-bearing token in a lending protocol.
 */
interface InterestBearingToken {
    /**
     * @dev Mints interest-bearing tokens to a specified address.
     * @param to The address to mint tokens to.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @dev Burns interest-bearing tokens from a specified address.
     * @param from The address to burn tokens from.
     * @param amount The amount of tokens to burn.
     */
    function burn(address from, uint256 amount) external;

    /**
     * @dev Returns the balance of interest-bearing tokens for a specified address.
     * @param account The address to query the balance of.
     * @return The balance of interest-bearing tokens.
     */
    function balanceOf(address account) external view returns (uint256);
}