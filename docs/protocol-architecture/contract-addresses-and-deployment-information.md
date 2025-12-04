---
description: >-
  This section provides all deployed contract addresses for reference, both for
  mainnet and testnets. Always ensure you are interacting with the correct
  network before performing any transactions.
---

# Contract Addresses & Deployment Information

#### 6.1 Mainnet

| Contract Name      | Address | Purpose                                                       |
| ------------------ | ------- | ------------------------------------------------------------- |
| LendingPool        | `0x...` | Core contract managing supply, borrow, repay, and liquidation |
| CollateralManager  | `0x...` | Tracks ETH collateral and enforces collateral rules           |
| PriceOracle        | `0x...` | Provides ETH price in ERC20 terms                             |
| InterestRateModel  | `0x...` | Computes dynamic borrow and supply rates                      |
| ERC20 Borrow Asset | `0x...` | Token that users can borrow (e.g., cNGN)                      |

#### 6.2 Testnet

| Contract Name      | Address | Purpose                                                 |
| ------------------ | ------- | ------------------------------------------------------- |
| LendingPool        | `0x...` | Core contract for testing supply/borrow/repay/liquidate |
| CollateralManager  | `0x...` | Testnet collateral tracking                             |
| PriceOracle        | `0x...` | Mock or test oracle providing ETH price                 |
| InterestRateModel  | `0x...` | Testnet interest rate calculations                      |
| ERC20 Borrow Asset | `0x...` | Mock ERC20 token for testing                            |
