# FAQ Page

#### 1. Can I lose my collateral?

Yes, collateral can be partially or fully seized if your **health factor** drops below 1.0. This occurs when your debt exceeds the safe borrowing limit relative to your deposited ETH. To minimize risk, monitor your health factor and avoid over-borrowing.

#### 2. What happens if ETH price crashes?

A sharp decline in ETH price reduces the value of your collateral. If your debt becomes too large relative to your collateral, your position may be liquidated. The **Liquidation Threshold** ensures the system remains solvent while giving borrowers a buffer before liquidation.

#### 3. How is interest calculated?

Interest is accrued continuously using **index-based accounting**:

* Borrow interest grows according to the **borrow rate**, which depends on **pool utilization**.
* Supply interest grows according to the **supply rate**, derived from the borrow rate and the **reserve factor**.
* Both borrow and supply balances are updated automatically when transactions occur.

#### 4. Is borrowing fixed or variable rate?

Borrowing uses a **variable rate**. The rate adjusts dynamically based on the pool’s utilization:

* Low utilization → lower borrow rate
* High utilization → higher borrow rate

This incentivizes efficient capital usage and maintains liquidity.

#### 5. Is the protocol audited?

BitLoan is designed with transparency and security in mind. Before mainnet deployment with significant TVL, it is strongly recommended to conduct professional **smart contract audits** and thorough testing.

#### 6. Is liquidation instant or delayed?

Liquidation can be executed **anytime a position becomes unsafe** (health factor < 1.0). The protocol allows anyone to perform liquidations, ensuring rapid correction of under-collateralized loans.

_Partial liquidation_ is applied according to the **Close Factor**, meaning only a portion of the debt can be liquidated per transaction to reduce slippage and allow borrower recovery.

#### 7. Can I increase my borrow limit after borrowing?

Yes. By depositing more ETH as collateral or repaying part of your debt, your **maximum borrowable amount** increases, improving your health factor and borrowing capacity.

#### 8. How do I repay my loan?

Repayments are made through the LendingPool contract:

1. Approve the ERC20 token to the contract.
2. Call `repay(amount)`.
3. Your debt and health factor update automatically.
4. Once fully repaid, you can withdraw your ETH collateral.

#### 9. Can I withdraw collateral anytime?

You can withdraw collateral only if your **health factor remains above 1.0** after withdrawal. The system automatically calculates `healthFactorAfterWithdrawCollateral` to prevent unsafe positions.

