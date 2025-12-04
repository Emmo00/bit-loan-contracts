# Summary

BitLoan is a unified, index-driven lending protocol where users leverage ETH collateral to borrow ERC20 assets under transparent, predictable rules. The system is composed of modular components, each responsible for a specific domain of protocol safety and economic behavior.

Key points:

* **ETH collateral enables borrowing ERC20s** — users lock ETH to open a borrow position.
* **LendingPool orchestrates all money movement** — deposits, borrows, repayments, withdrawals, and liquidations.
* **CollateralManager protects the system** — tracks collateral, enforces thresholds, and validates safety before any action.
* **PriceOracle defines collateral value** — the source of truth for real-time asset pricing.
* **InterestRateModel sets dynamic APRs** — rates adjust automatically based on utilization.
* **Borrowing and supplying use index-based interest** — ensuring fair, compounding and time-consistent accrual.
* **Health factor governs safety and liquidation** — a precise metric determining whether a position is secure or at risk.
* **System is mathematically predictable and fully transparent** — all operations follow deterministic formulas.

