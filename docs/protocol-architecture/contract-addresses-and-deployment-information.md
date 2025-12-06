---
description: >-
  This section provides all deployed contract addresses for reference, both for
  mainnet and testnets. Always ensure you are interacting with the correct
  network before performing any transactions.
---

# Contract Addresses & Deployment Information

#### Mainnet

| Contract Name      | Address | Purpose                                                       |
| ------------------ | ------- | ------------------------------------------------------------- |
| LendingPool        | `0x...` | Core contract managing supply, borrow, repay, and liquidation |
| CollateralManager  | `0x...` | Tracks ETH collateral and enforces collateral rules           |
| PriceOracle        | `0x...` | Provides ETH price in ERC20 terms                             |
| InterestRateModel  | `0x...` | Computes dynamic borrow and supply rates                      |
| ERC20 Borrow Asset | `0x...` | Token that users can borrow (e.g., cNGN)                      |

#### Testnet

| Contract Name      | Address | Purpose                                                 |
| ------------------ | ------- | ------------------------------------------------------- |
| LendingPool        | [`0x6c690eE5E2627B6880fCFB99a1949118bdc6f83E`](https://sepolia.basescan.org/address/0x6c690ee5e2627b6880fcfb99a1949118bdc6f83e) | Core contract for testing supply/borrow/repay/liquidate |
| CollateralManager  | [`0x71430593319C84679e4EA77ef798F8e389A361cc`](https://sepolia.basescan.org/address/0x71430593319C84679e4EA77ef798F8e389A361cc) | Testnet collateral tracking                             |
| PriceOracle        | [`0xC7A8699DEF93eF2eC2B5Fcb09A86B3976Df552e7`](https://sepolia.basescan.org/address/0xC7A8699DEF93eF2eC2B5Fcb09A86B3976Df552e7) | Mock or test oracle providing ETH price                 |
| InterestRateModel  | [`0xd1CBD4dff4cF1b27Dca8812D6c172D5196D66D7F`](https://sepolia.basescan.org/address/0xd1CBD4dff4cF1b27Dca8812D6c172D5196D66D7F) | Testnet interest rate calculations                      |
| ERC20 Borrow Asset | [`0xfa923504bbEeD541B0541e59EbD5B97FCc82E855`](https://sepolia.basescan.org/token/0xfa923504bbeed541b0541e59ebd5b97fcc82e855) | Mock ERC20 token for testing                            |
