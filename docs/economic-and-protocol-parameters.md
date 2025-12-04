---
description: >-
  These parameters determine how users can borrow, how interest evolves, when
  liquidations occur, and how the protocol generates revenue.
---

# Economic & Protocol Parameters

Below is a polished, publication-ready version of **Chapter 3: Economic & Protocol Parameters**, with improved clarity and expanded explanation while preserving your structure.

***

## **Economic & Protocol Parameters**

BitLoan’s behavior is driven by a set of economic constants and risk parameters.\
These parameters determine how much users can borrow, how interest evolves, when liquidations occur, and how the protocol generates revenue.\
This section documents every key scalar and explains its purpose in the system.

***

### **Fixed Parameters**

The following parameters are defined as immutable or configuration-level constants within the protocol:

| Parameter                  | Value  | Description                                                |
| -------------------------- | ------ | ---------------------------------------------------------- |
| **SCALE**                  | `1e18` | Base precision unit for all WAD math                       |
| **BASE\_RATE**             | `2%`   | Minimum borrow APR at 0% utilization                       |
| **INTEREST\_MULTIPLIER**   | `18%`  | Additional borrow APR at 100% utilization (linear model)   |
| **COLLATERAL\_FACTOR**     | `80%`  | Maximum borrowable percentage of collateral value          |
| **LIQUIDATION\_THRESHOLD** | `85%`  | Health barrier above which an account becomes liquidatable |
| **LIQUIDATION\_BONUS**     | `105%` | Liquidator receives 5% extra collateral for repaying debt  |
| **CLOSE\_FACTOR**          | `60%`  | Maximum portion of debt repaid per liquidation call        |
| **RESERVE\_FACTOR**        | `10%`  | Portion of interest kept as protocol revenue               |

These parameters can be adjusted in future protocol upgrades but remain fixed for the deployed version.

***

### **Meaning of Each Parameter**

Below are detailed definitions of what each parameter represents in protocol operations.

#### **Collateral Factor (80%)**

Defines how much a user can _safely borrow_ against their collateral.

If a user deposits 1 ETH worth 1,000 cNGN and the collateral factor is 80%, the maximum safe borrowable amount is:

```
1,000 cNGN × 0.80 = 800 cNGN
```

This ensures loans are always over-collateralized.

***

#### **Liquidation Threshold (85%)**

Determines the point at which the borrower’s position becomes unsafe and eligible for liquidation.

A user becomes liquidatable if:

```
Debt >= Collateral Value × Liquidation Threshold
```

This is intentionally higher than the collateral factor, creating a buffer between “allowed borrowing” and “liquidatable”.

***

#### **Close Factor (60%)**

Limits the portion of a borrower’s outstanding debt that a liquidator can repay in a single liquidation transaction.

If the user owes 1,000 cNGN and the close factor is 60%:

```
Max repayable in liquidation = 600 cNGN
```

This prevents aggressive liquidations and gives users a chance to recover.

***

#### **Liquidation Bonus (105%)**

Rewards liquidators with extra collateral for stabilizing unhealthy positions.

If a liquidator repays 100 cNGN of someone’s debt and the liquidation bonus is 105%, they receive collateral worth:

```
100 cNGN × 105% = 105 cNGN worth of ETH
```

This incentivizes external actors to maintain system solvency.

***

#### **Reserve Factor (10%)**

Determines what portion of interest paid by borrowers is diverted into protocol reserves rather than distributed to suppliers.

If borrowers pay 100 cNGN in interest:

```
90 cNGN → suppliers  
10 cNGN → protocol reserves
```

Reserves strengthen long-term liquidity and protocol sustainability.

***

### **What These Parameters Control**

These parameters collectively shape the core economic dynamics of BitLoan.

#### **Loan Safety**

* Collateral factor and liquidation threshold ensure loans remain over-collateralized.
* Prevents insolvency even during price volatility.

#### **Liquidation Frequency**

* Higher liquidation threshold = more sensitive to price drops.
* Lower liquidation threshold = fewer liquidations but higher systemic risk.

#### **Incentives for Liquidators**

* The liquidation bonus must be large enough to incentivize participation.
* Close factor ensures gradual and predictable liquidations.

#### **Protocol Revenue**

* Reserve factor defines how much the protocol earns long-term.
* Ensures sustainability without harming suppliers.

#### **Interest Rate Sensitivity**

* Base rate and multiplier determine how quickly borrow rates rise as utilization increases.
* High utilization ⇒ higher borrow APR ⇒ self-balancing liquidity incentives.

