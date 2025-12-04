# Introduction

### **1.1 What is BitLoan?**

BitLoan is a decentralized, collateralized lending protocol that enables users to borrow ERC-20 assets by locking ETH as collateral. It operates without intermediaries, using smart contracts to enforce the rules of borrowing, interest accrual, and liquidation.

The current version of BitLoan provides **one lending market**:

**ETH collateral → borrow cNGN (or another ERC-20 token).**

Key characteristics:

* **Single, unified borrow position per user:**\
  Each wallet maintains one continuous debt position rather than multiple fragmented loans. Borrowing more increases the same debt position; repaying reduces it.
* **Dynamic interest rates based on utilization:**\
  Borrowing costs automatically adjust depending on how much liquidity is currently used within the pool. High demand increases rates; low demand decreases them.
* **Fully on-chain accounting:**\
  Borrow balances, collateral, interest, and health factors are continuously computed and enforced by the protocol.

BitLoan aims to provide a simple, predictable lending experience while leveraging robust DeFi principles.

***

### **1.2 Why BitLoan Exists**

BitLoan addresses key needs in decentralized finance:

#### **Borrow stable assets using volatile collateral**

Users who hold ETH may want short-term liquidity without selling their ETH. BitLoan lets them lock ETH and borrow cNGN or other assets while retaining upside exposure.

#### **Efficient and transparent borrowing**

All calculations—interest, collateralization, liquidation thresholds—are transparent and deterministic. There are no hidden terms, no intermediaries, and no approval committees.

#### **Permissionless access to liquidity**

Anyone can supply liquidity or borrow against ETH without KYC, credit checks, or centralized approvals. The protocol is open to all wallets.

#### **Fair liquidations and strong risk controls**

BitLoan uses a predictable health factor model and clear liquidation rules designed to protect the protocol while minimizing excessive loss for users.\
The system ensures:

* Over-collateralization
* Real-time price checks via oracles
* Automatic liquidation of under-collateralized positions
* Reserve accumulation to sustain liquidity

BitLoan exists to make borrowing simple, fair, and transparent—powered entirely by smart contracts.

***

### **1.3 Target Users**

BitLoan serves multiple participant types, each playing a distinct role in the ecosystem.

#### **Borrowers**

Users who want to borrow ERC-20 assets (e.g., cNGN) while using ETH as collateral. Borrowers interact most with collateral deposits, borrow operations, and repayments.

#### **Suppliers**

Liquidity providers who deposit cNGN into the lending pool and earn interest from borrower repayments. Suppliers earn a yield that scales with pool utilization.

#### **Liquidators**

Participants who monitor borrower health and perform liquidations when positions fall below the required safety threshold. They receive financial incentives for restoring the system to solvency.

#### **Developers / Integrators**

Builders who integrate BitLoan into wallets, dashboards, or third-party applications. They rely on BitLoan’s simple interfaces, deterministic math, and robust contract architecture.

***

### **1.4 High-Level How It Works**

BitLoan operates through a straightforward flow:

#### **1. Deposit ETH as collateral**

Users lock ETH into the protocol’s Collateral Manager contract. This establishes their borrowing capacity.

#### **2. Borrow cNGN or another ERC-20 asset**

After depositing collateral, users can borrow cNGN up to a safe limit determined by:

* ETH value
* Collateral factor
* Market parameters
* Real-time price oracle data

Borrowing immediately increases the user’s unified debt position.

#### **3. Interest accrues automatically**

Interest does not require manual updates. It is tracked using a **borrow index**, calculated whenever the user interacts with the position. This ensures accurate, continuous accounting of interest owed.

#### **4. Collateral is only seized if the position becomes unsafe**

If ETH value drops or the user’s debt grows too large, the health factor may fall below the liquidation threshold. In that state, liquidators can repay part of the debt and claim a portion of the collateral.

#### **5. Suppliers earn interest**

All interest paid by borrowers is distributed to liquidity suppliers, minus a reserve factor that strengthens the protocol over time.

