---
description: >-
  This chapter provides a complete breakdown of the BitLoan smart contract
  architecture, including all core components, their responsibilities, and how
  they interact. The goal is to give readers—both te
---

# Protocol Architecture

### **Architecture Overview**

BitLoan follows a modular, highly-segmented architecture designed for clarity, security, and upgradeability. Each major responsibility in the lending lifecycle—collateral tracking, interest calculation, price feeds, and lending logic—is separated into its own contract.

#### **High-Level System Diagram**

<figure><img src="../.gitbook/assets/Untitled diagram-2025-12-06-001436.png" alt=""><figcaption></figcaption></figure>

#### **ETH Flows vs ERC-20 Flows**

**ETH Collateral Flow:**

* User → CollateralManager (via LendingPool entry point)
* Held entirely by CollateralManager
* Released only upon safe withdrawal or liquidation settlement

**ERC-20 Borrow Asset Flow:**

* User deposits ERC-20 → LendingPool
* Borrowers receive ERC-20 from LendingPool
* Repayments return ERC-20 to LendingPool
* LendingPool is the only contract that ever transfers ERC-20 tokens

#### **System Invariants**

The architecture enforces two critical invariants:

1. **Only the LendingPool moves ERC-20 funds.**\
   No other contract has custody of cNGN (or the borrow token).
2. **Only the CollateralManager holds ETH collateral.**\
   ETH is isolated from lending logic for security and clarity.

These invariants simplify auditing, reduce attack surface, and maintain strong separation of responsibilities.

***

### **Core Contracts**

Below is a breakdown of all core components.

***

### **LendingPool**

#### **Role**

The **central contract** that handles all lending, borrowing, and interest accounting. It coordinates all other components and provides the main user-facing API.

#### **Responsibilities**

* Track total supplied and total borrowed balances
* Maintain per-user borrow balances
* Accrue interest using the borrow index
* Update borrow and supply indices
* Validate collateral availability before borrowing or withdrawing
* Perform supply (deposit/withdraw) operations
* Perform borrowing and repayment
* Initiate and settle liquidations
* Compute dynamic metrics such as utilization, borrow rate, and supply rate
* Serve as the integration point for UI dashboards, SDKs, and external smart contracts

#### **Key Functions**

* **deposit(amount)**\
  Deposits ERC-20 tokens into the pool.
* **withdraw(amount)**\
  Withdraws available ERC-20 liquidity.
* **borrow(amount)**\
  Borrows ERC-20 tokens based on available collateral.
* **repay(amount)**\
  Repays ERC-20 debt; interest is applied automatically.
* **depositCollateral()**\
  Deposits ETH into the CollateralManager.
* **withdrawCollateral(amount)**\
  Withdraws ETH if safe to do so.
* **liquidate(user)**\
  Executes a liquidation when a user's health factor is below threshold.
* **accrueInterest()**\
  Updates interest indexes for the current block.
* **utilization()**
* **borrowRate()**
* **supplyRate()**

***

### **CollateralManager**

#### **Role**

Handles the storage and valuation of all ETH collateral in the system.

#### **Responsibilities**

* Maintain per-user ETH collateral balances
* Compute collateral value using the PriceOracle
* Enforce collateral factors and liquidation thresholds
* Compute the user’s health factor
* Perform “after operation” simulations for borrow and withdraw
* Supply collateral limits to the LendingPool
* Provide collateral seizure during liquidation events

#### **Key Functions**

* **getCollateral(user)**\
  Returns raw ETH balance.
* **getCollateralValue(user)**\
  Converts ETH → borrow token value using price feed.
* **getMaxBorrow(user)**\
  Maximum amount the user can borrow safely.
* **healthFactor(user)**\
  Real-time safety metric.
* **healthFactorAfterBorrow(user, amount)**\
  Predicts safety after borrowing.
* **healthFactorAfterWithdrawCollateral(user, amount)**\
  Predicts safety after withdrawing ETH.
* **seizeCollateral(user, amount)**\
  Used in liquidations to transfer collateral to the liquidator.

***

### **PriceOracle**

#### **Role**

Provides the current ETH → Borrow Token price.

#### **Responsibilities**

* Return an up-to-date, manipulaton-resistant price
* Serve as the valuation backbone for collateral management
* Allow mocking during local development
* Enable Chainlink or other oracle networks in production

#### **Key Function**

* **getEthPrice()**\
  Returns the value of 1 ETH denominated in the borrow asset (e.g., ETH → cNGN).

***

### **InterestRateModel**

#### **Role**

Computes interest rates based on pool utilization.

#### **Responsibilities**

* Provide borrow rate (APR)
* Provide supply rate (APR) after applying reserveFactor
* Define the rate curve (linear, kink, or multi-segment)
* Allow the LendingPool to compute interest in a deterministic, stateless way

#### **Key Functions**

* **getBorrowRate(utilization)**\
  Returns current borrow APR.
* **getSupplyRate(utilization, borrowRate, reserveFactor)**\
  Returns supply APR.

***

### **ERC-20 Borrow Asset**

The underlying token lent out by the protocol.

#### Properties

* Must comply with ERC-20
* May be mintable (stablecoin) or non-mintable
* Users must approve the LendingPool before deposit or repay
* Stored exclusively in the LendingPool

***
