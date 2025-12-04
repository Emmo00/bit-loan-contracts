---
description: >-
  This section defines all the formulas that govern BitLoan’s economic behavior,
  interest dynamics, collateral safety, and liquidation mechanics.
---

# Mathematical Models

### Utilization

Measures how much of the supplied liquidity is currently borrowed.

```
U = totalBorrows / (totalSupply + totalBorrows)
```

Higher utilization results in higher variable interest rates.

***

### Borrow Rate

Linear interest rate model:

```
borrowRate = BASE_RATE + MULTIPLIER * U
```

Where:

* BASE\_RATE = minimum borrow rate
* MULTIPLIER = sensitivity of rates to utilization

***

### Supply Rate

Supplier yield is a function of borrow rate, utilization, and reserve factor.

```
supplyRate = borrowRate * U * (1 - reserveFactor)
```

Reserve Factor represents protocol revenue.

***

### Interest Accrual (per second)

Interest increases indices over time:

```
borrowIndex_new = borrowIndex_old * (1 + borrowRate * dt)

supplyIndex_new = supplyIndex_old * (1 + supplyRate * dt)
```

Indices ensure interest remains proportional for all users.

***

### Borrow Balance

A user’s current borrow balance:

```
borrowBalance = principal * (borrowIndex / userBorrowIndex)
```

***

### Supply Balance

A user’s current supply balance:

```
supplyBalance = principal * (supplyIndex / userSupplyIndex)
```

***

### Collateral Value

The USD (or base currency) value of the user’s ETH collateral:

```
collateralValue = ETH_amount * ETH_price
```

***

### Health Factor

Determines borrowing safety. If HF < 1.0, liquidation can occur.

```
HF = (collateralValue * liquidationThreshold) / borrowValue
```

***

### Maximum Borrow Amount

How much a user can borrow based on collateral factor:

```
maxBorrow = collateralValue * collateralFactor
```

***

### 5.10 Liquidation Seize Amount

Amount of ETH collateral the liquidator receives:

```
seizeAmount = repayAmount * liquidationBonus / ETH_price
```

The liquidation bonus ensures liquidators remain incentivized.

