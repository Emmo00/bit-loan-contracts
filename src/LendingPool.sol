// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ILendingPool} from "./interfaces/ILendingPool.sol";
import {IInterestRateModel} from "./interfaces/IInterestRateModel.sol";
import {ICollateralManager} from "./interfaces/ICollateralManager.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {ScaleMath} from "./libraries/ScaleMath.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract LendingPool is ILendingPool, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using ScaleMath for uint256;

    uint256 private constant SCALE = 1e18;
    uint256 private constant SECONDS_PER_YEAR = 365 days;

    IERC20 public immutable borrowAsset;
    ICollateralManager public immutable collateralManager;
    IPriceOracle public immutable priceOracle;
    IInterestRateModel public interestRateModel;

    uint256 public borrowIndex;
    uint256 public supplyIndex;

    uint256 public lastAccrualTimestamp;

    // Totals
    uint256 public totalBorrows; // raw units (borrowAsset)
    uint256 public totalSupply; // raw units (borrowAsset) deposited by suppliers
    uint256 public totalReserves; // protocol reserves in borrowAsset

    // Parameters
    uint256 public reserveFactor = 1e17; // 10% by default
    uint256 public liquidationBonus = 105e16; // 1.05x factor used when computing seize: multiply repayValue by this (i.e., 5% bonus)
    uint256 public closeFactor = 6e17; // 60% max repay per liquidation by default

    // Per-user accounting
    mapping(address => uint256) public principalBorrow; // user's principal (raw units)
    mapping(address => uint256) public borrowerIndex; // user-specific borrow index at last update

    mapping(address => uint256) public principalSupply; // user's supply principal (raw units)
    mapping(address => uint256) public supplierIndex; // user-specific supply index at last update

    constructor(address _borrowAsset, address _collateralManager, address _oracle, address _interestModel)
        Ownable(msg.sender)
    {
        require(_borrowAsset != address(0), "LendingPool: invalid borrow asset");
        require(_collateralManager != address(0), "LendingPool: invalid collateral manager");
        require(_oracle != address(0), "LendingPool: invalid oracle");
        require(_interestModel != address(0), "LendingPool: invalid interest model");

        borrowAsset = IERC20(_borrowAsset);
        collateralManager = ICollateralManager(_collateralManager);
        priceOracle = IPriceOracle(_oracle);
        interestRateModel = IInterestRateModel(_interestModel);

        borrowIndex = SCALE;
        supplyIndex = SCALE;
        lastAccrualTimestamp = block.timestamp;
    }

    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "LendingPool: deposit zero");
        accrueInterest();

        // transfer tokens from supplier to pool
        borrowAsset.safeTransferFrom(msg.sender, address(this), amount);

        // update user's principal supply using indices
        uint256 userSupply = getSupplyBalance(msg.sender);
        uint256 newSupply = userSupply + amount;

        principalSupply[msg.sender] = newSupply;
        supplierIndex[msg.sender] = supplyIndex;

        totalSupply += amount;

        emit Deposit(msg.sender, amount);
    }

    function depositCollateral() external payable override nonReentrant {
        require(msg.value > 0, "LendingPool: deposit zero");
        collateralManager.depositCollateral{value: msg.value}(msg.sender);
    }

    function withdraw(uint256 amount, address receiver) external override nonReentrant {
        require(amount > 0, "LendingPool: withdraw zero");
        require(receiver != address(0), "LendingPool: invalid receiver");
        accrueInterest();

        uint256 userSupply = getSupplyBalance(msg.sender);
        require(userSupply >= amount, "LendingPool: insufficient supply");

        uint256 newSupply = userSupply - amount;
        // Store the updated principal and index consistently
        principalSupply[msg.sender] = newSupply;
        supplierIndex[msg.sender] = supplyIndex;

        totalSupply -= amount;

        // transfer tokens out
        borrowAsset.safeTransfer(receiver, amount);

        emit Withdraw(msg.sender, amount, receiver);
    }

    function withdrawCollateral(uint256 amount, address receiver) external override nonReentrant {
        require(amount > 0, "LendingPool: withdraw zero");
        require(receiver != address(0), "LendingPool: invalid receiver");
        accrueInterest();

        // check health factor after withdrawal
        uint256 hfAfter = healthFactorAfterWithdrawCollateral(msg.sender, amount);
        require(hfAfter >= SCALE, "LendingPool: health factor too low");

        // withdraw collateral from collateral manager
        collateralManager.withdrawCollateral(msg.sender, amount, receiver);
    }

    function borrow(uint256 amount, address receiver) external override nonReentrant {
        require(amount > 0, "LendingPool: borrow zero");
        require(receiver != address(0), "LendingPool: invalid receiver");
        accrueInterest();

        // check health factor after borrow: collateral value and liquidation threshold from collateral manager
        uint256 hfAfter = healthFactorAfterBorrow(msg.sender, amount);
        require(hfAfter >= SCALE, "LendingPool: health factor too low after borrow");

        uint256 borrowerCurrentDebt = getBorrowBalance(msg.sender);
        uint256 newDebt = borrowerCurrentDebt + amount;

        // update state
        principalBorrow[msg.sender] = newDebt;
        borrowerIndex[msg.sender] = borrowIndex;

        totalBorrows += amount;

        // transfer underlying to borrower
        borrowAsset.safeTransfer(receiver, amount);

        emit Borrow(msg.sender, amount, receiver);
    }

    function repay(address borrower, uint256 amount) external nonReentrant {
        require(amount > 0, "LendingPool: repay zero");
        accrueInterest();

        uint256 curDebt = getBorrowBalance(borrower);
        require(curDebt > 0, "LendingPool: no debt");

        uint256 repayAmount = amount;
        if (repayAmount > curDebt) repayAmount = curDebt;

        // pull tokens from payer
        borrowAsset.safeTransferFrom(msg.sender, address(this), repayAmount);

        // update borrower principal
        uint256 newDebt = curDebt - repayAmount;
        if (newDebt == 0) {
            principalBorrow[borrower] = 0;
            borrowerIndex[borrower] = 0;
        } else {
            principalBorrow[borrower] = newDebt;
            borrowerIndex[borrower] = borrowIndex;
        }

        totalBorrows -= repayAmount;

        emit Repay(msg.sender, borrower, repayAmount);
    }

    function liquidate(address borrower, uint256 repayAmount) external nonReentrant {
        require(repayAmount > 0, "LendingPool: repay zero");
        accrueInterest();

        // require borrower unhealthy now
        uint256 hfNow = healthFactor(borrower);
        require(hfNow < SCALE, "LendingPool: borrower healthy");

        uint256 borrowerDebt = getBorrowBalance(borrower);
        // cap repayAmount to closeFactor * borrowerDebt
        uint256 maxRepay = borrowerDebt.scaleMul(closeFactor);
        if (repayAmount > maxRepay) repayAmount = maxRepay;

        // pull repayAmount from liquidator
        borrowAsset.safeTransferFrom(msg.sender, address(this), repayAmount);

        // compute seizeValue = repayValue * liquidationBonus
        // liquidationBonus like 1.05e18 means 5% bonus => multiply repayValue by 1.05
        uint256 seizeValue = repayAmount.scaleMul(liquidationBonus); // still in borrowAsset units (raw scaled WAD)

        // get collateral price (borrowAsset units per 1 collateral token, scaled WAD)
        uint256 priceCollateral = priceOracle.getEthPrice();

        // amount of collateral tokens to seize (raw collateral units)
        // seizeCollateralAmount = seizeValue / priceCollateral
        // both in WAD, so compute: (seizeValueWad * WAD) / priceCollateralWad -> yields collateral token units scaled to WAD
        uint256 seizeCollateralTokens = seizeValue.scaleDiv(priceCollateral);

        // if computed seize is zero due to rounding, set minimal to 1 (if borrower has collateral)
        if (seizeCollateralTokens == 0) {
            uint256 colRaw = collateralManager.getUserCollateral(borrower);
            require(colRaw > 0, "LendingPool: nothing to seize");
            seizeCollateralTokens = 1;
        }

        // Cap seizeCollateralTokens to borrower's available collateral
        uint256 borrowerCollateral = collateralManager.getUserCollateral(borrower);
        if (seizeCollateralTokens > borrowerCollateral) {
            seizeCollateralTokens = borrowerCollateral;
        }

        // update borrower debt (reduce)
        uint256 newDebt = borrowerDebt - repayAmount;
        if (newDebt == 0) {
            principalBorrow[borrower] = 0;
            borrowerIndex[borrower] = 0;
        } else {
            // store principal as normalized to borrowerIndex
            principalBorrow[borrower] = newDebt;
            borrowerIndex[borrower] = borrowIndex;
        }
        totalBorrows -= repayAmount;

        // transfer seized collateral to liquidator
        collateralManager.seizeCollateral(borrower, seizeCollateralTokens, msg.sender);

        emit Liquidate(msg.sender, borrower, repayAmount, seizeCollateralTokens);
    }

    function accrueInterest() public {
        uint256 timestamp = block.timestamp;
        uint256 elapsed = timestamp - lastAccrualTimestamp;
        if (elapsed == 0) return;

        // compute rates (annual) in WAD
        uint256 brApr = borrowRate();
        uint256 srApr = supplyRate();

        // interestFactor = (rate * elapsed) / SECONDS_PER_YEAR
        uint256 interestFactor = (brApr * elapsed) / SECONDS_PER_YEAR;
        
        // Prevent overflow for very large elapsed times
        require(elapsed <= 365 days, "LendingPool: elapsed time too large");

        // interestAccrued = totalBorrows * interestFactor
        uint256 interestAccrued = totalBorrows.scaleMul(interestFactor);

        // reserves increase
        uint256 reservesAdded = interestAccrued.scaleMul(reserveFactor);

        // update totals
        totalBorrows = totalBorrows + interestAccrued;
        totalReserves = totalReserves + reservesAdded;

        // update indices: borrowIndex *= (1 + interestFactor)
        borrowIndex = borrowIndex.scaleMul(SCALE + interestFactor);

        // supplyIndex grows by supplyRate
        uint256 supplyFactor = (srApr * elapsed) / SECONDS_PER_YEAR; // WAD
        supplyIndex = supplyIndex.scaleMul(SCALE + supplyFactor);

        lastAccrualTimestamp = timestamp;

        emit AccrueInterest(borrowIndex, supplyIndex, interestAccrued, reservesAdded);
    }

    /**
     * Admin setters (add access control in production) **
     */
    function setReserveFactor(uint256 newReserveFactorWad) external onlyOwner {
        require(newReserveFactorWad <= SCALE, "LendingPool: factor>1");
        reserveFactor = newReserveFactorWad;
    }

    function setCloseFactor(uint256 newCloseFactorWad) external onlyOwner {
        require(newCloseFactorWad <= SCALE, "LendingPool: close>1");
        closeFactor = newCloseFactorWad;
    }

    function setLiquidationBonus(uint256 newLiquidationBonusWad) external onlyOwner {
        require(newLiquidationBonusWad >= SCALE, "LendingPool: bonus<1");
        liquidationBonus = newLiquidationBonusWad;
    }

    function setInterestModel(address newModel) external onlyOwner {
        require(newModel != address(0), "LendingPool: zero model");
        interestRateModel = IInterestRateModel(newModel);
    }

    function setCollateralFactor(uint256 newFactor) external onlyOwner {
        collateralManager.setCollateralFactor(newFactor);
    }

    function setLiquidationThreshold(uint256 newThreshold) external onlyOwner {
        collateralManager.setLiquidationThreshold(newThreshold);
    }

    /// @notice get current cash in the pool (borrowAsset tokens held by contract)
    function getCash() public view returns (uint256) {
        return borrowAsset.balanceOf(address(this));
    }

    /// @notice utilization U = totalBorrows / (cash + totalBorrows)
    function utilization() public view returns (uint256) {
        uint256 cash = getCash();
        if (totalBorrows == 0) return 0;
        // note: if cash + totalBorrows == 0 then division by zero unlikely since totalBorrows > 0
        return totalBorrows.scaleDiv(cash + totalBorrows);
    }

    /// @notice current borrow APR (WAD)
    function borrowRate() public view returns (uint256) {
        return interestRateModel.getBorrowRate(utilization());
    }

    /// @notice current supply APR (WAD)
    function supplyRate() public view returns (uint256) {
        uint256 br = borrowRate();
        return interestRateModel.getSupplyRate(utilization(), br, reserveFactor);
    }

    /// @notice user borrow balance including interest
    function getBorrowBalance(address user) public view returns (uint256) {
        uint256 principal = principalBorrow[user];
        if (principal == 0) return 0;
        uint256 idx = borrowerIndex[user];
        if (idx == 0) idx = borrowIndex; // in case never set (shouldn't happen)
        // current = principal * (borrowIndex / idx)
        return (principal * borrowIndex) / idx;
    }

    /// @notice user supply balance including interest
    function getSupplyBalance(address user) public view returns (uint256) {
        uint256 principal = principalSupply[user];
        if (principal == 0) return 0;
        uint256 idx = supplierIndex[user];
        if (idx == 0) idx = supplyIndex;
        return (principal * supplyIndex) / idx;
    }

    /// @notice Compute user's borrow value in borrow asset units (raw tokens) — here it's identical to getBorrowBalance()
    function getBorrowValue(address user) public view returns (uint256) {
        return getBorrowBalance(user);
    }

    /// @notice Health factor = (collateralValue * liquidationThreshold) / borrowValue. returns WAD scale.
    /// If borrowValue == 0 returns type(uint256).max
    function healthFactor(address user) public view returns (uint256) {
        uint256 borrowValue = getBorrowValue(user);
        if (borrowValue == 0) return type(uint256).max;
        uint256 collateralValue = collateralManager.getCollateralValue(user); // WAD
        uint256 lt = collateralManager.getLiquidationThreshold(); // WAD
        // hf = (collateralValue * lt) / borrowValue
        return (collateralValue.scaleMul(lt)).scaleDiv(borrowValue);
    }

    function healthFactorAfterBorrow(address user, uint256 borrowAmount) public view returns (uint256) {
        // compute new borrow value (after borrowing)
        uint256 borrowerCurrentDebt = getBorrowBalance(user); // Fixed: use 'user' not 'msg.sender'
        uint256 newDebt = borrowerCurrentDebt + borrowAmount;
        if (newDebt == 0) return type(uint256).max;
        
        uint256 collateralValueWad = collateralManager.getCollateralValue(user);
        uint256 lt = collateralManager.getLiquidationThreshold(); // Fixed: use liquidationThreshold

        uint256 hfAfter = (collateralValueWad.scaleMul(lt)).scaleDiv(newDebt);
        return hfAfter;
    }

    function healthFactorAfterWithdrawCollateral(address user, uint256 withdrawAmount) public view returns (uint256) {
        uint256 borrowValue = getBorrowValue(user);
        if (borrowValue == 0) return type(uint256).max;

        uint256 collateralValueWad = collateralManager.getCollateralValue(user);
        // withdrawAmount is already in ETH wei, convert to borrow asset value
        uint256 withdrawValueInBorrowAsset = (withdrawAmount * priceOracle.getEthPrice()) / SCALE;
        
        if (collateralValueWad <= withdrawValueInBorrowAsset) return 0;
        uint256 collateralValueAfter = collateralValueWad - withdrawValueInBorrowAsset;
        uint256 lt = collateralManager.getLiquidationThreshold();

        return (collateralValueAfter.scaleMul(lt)).scaleDiv(borrowValue);
    }

    /// @notice get total collateral deposited in the protocol
    function totalCollateral() external view returns (uint256) {
        return collateralManager.totalCollateral();
    }
}
