---
description: >-
  This chapter describes every action users can perform in the BitLoan protocol
  and explains how each operation affects their position and the overall system.
---

# User Flow

### **Supplying Liquidity (ERC20 → Earn Interest)**

Users who want to earn yield can supply the ERC20 borrow asset (e.g., cNGN) into the lending pool.\
Suppliers earn interest automatically from borrowers.

#### **Steps**

1. **Approve the LendingPool Contract**\
   The user allows the LendingPool to transfer their ERC20 tokens.
2. **Call `deposit(amount)`**\
   Tokens are transferred from the user to the LendingPool.
3. **Interest Accrual Begins**\
   Interest accumulates continuously through the supply index.
4. **Query `getSupplyBalance(user)`**\
   Returns:
   * supplied principal
   * plus accrued interest based on the supply index
5. **Call `withdraw(amount)`**\
   The user redeems tokens back from the pool.

#### **Outputs**

* Supplier’s balance grows continuously through interest.
* Total protocol liquidity (cash + borrows) increases.
* Utilization decreases (increasing available liquidity).

***

### **Depositing Collateral (ETH)**

Borrowers must deposit ETH before they can take a loan.\
Collateral is tracked separately from ERC20 supply funds.

#### **Steps**

1. **Call `depositCollateral()` with ETH value**\
   User sends ETH directly in the transaction.
2. **CollateralManager Updates User Balances**\
   The contract records the user’s collateral internally.
3.  **Collateral Valuation via Oracle**\
    CollateralManager converts ETH to its value in ERC20 units:

    ```
    collateralValue = collateralETH × price(ETH → ERC20)
    ```
4.  **Borrow Capacity Is Derived**

    ```
    maxBorrow = collateralValue × collateralFactor
    ```

#### **Outputs**

* User’s borrowable capacity increases immediately.
* Health factor improves (more collateral buffer).
* No interest is earned on collateral.

***

### **Borrowing ERC20 Tokens**

A user can borrow against deposited ETH.\
The system supports:

**A. Borrowing with existing collateral**\
**B. Borrowing with zero collateral** — frontend calculates required ETH, then user deposits and borrows in one flow.

#### **Steps**

1. **Call `accrueInterest()`**\
   Ensures borrow and supply indices are up to date.
2. **Check `healthFactorAfterBorrow(amount)`**\
   Prevents unsafe positions.
3. **Update Borrow Index + Balances**\
   Borrower’s debt is stored using the borrow index, ensuring correct interest accrual.
4. **Transfer ERC20 Tokens to User**\
   LendingPool sends the borrowed amount.
5. **Increment Total Borrows**\
   Protocol state is updated.

#### **Outputs**

* Borrower's outstanding debt increases.
* System utilization increases (driving interest rates up).
* Borrower’s health factor decreases.

***

### **Repaying Debt**

Borrowers may repay partially or fully at any time.

#### **Steps**

1. **Approve Tokens to LendingPool**\
   Allows debt repayment in ERC20 tokens.
2. **Call `repay(amount)`**\
   LendingPool pulls tokens from the payer.
3. **Reduce Borrow Balance Using Borrow Index**\
   The borrower’s indexed debt is updated.
4. **Protocol Accrues Interest (to current block)**\
   Ensures accurate debt reduction.

#### **Outputs**

* Borrower’s debt decreases.
* Health factor improves.
* Total protocol borrows decrease.

***

### **Withdrawing Collateral**

A borrower can withdraw ETH only if the remaining collateral keeps their position safe.

#### **Steps**

1. **Check `healthFactorAfterWithdraw(amount)`**\
   Ensures user remains above liquidation threshold.
2. **CollateralManager Reduces Collateral Balance**\
   The user’s collateral position is updated.
3. **ETH Is Transferred Back to User**\
   Native ETH is released.

#### **Outputs**

* Collateral amount decreases.
* User’s health factor decreases.
* Maximum borrowable limit decreases.

***

### **Liquidation**

A liquidation occurs when a borrower’s health factor falls below `1.0`, meaning:

```
Debt > Collateral Value × Liquidation Threshold
```

#### **Steps**

1. **Liquidator Selects an Unhealthy Borrower**\
   Any address can perform liquidation.
2.  **Determine Allowed Repay Amount**\
    Capped by the close factor:

    ```
    repayAmount ≤ debt × closeFactor
    ```
3. **LendingPool Repays Borrower’s Debt**\
   Tokens are pulled from the liquidator.
4.  **CollateralManager Computes Seize Amount**\
    Liquidator receives:

    ```
    seizedCollateral = repayAmount × liquidationBonus
    ```
5. **Collateral Is Transferred to Liquidator**\
   Borrower loses an equivalent portion of ETH.

#### **Outputs**

* Borrower’s debt reduces.
* Borrower loses collateral.
* Liquidator gains extra ETH as reward.
* Protocol removes unhealthy debt.
* System becomes safer and more solvent.

