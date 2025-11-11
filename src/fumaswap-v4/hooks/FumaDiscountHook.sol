// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseHook} from "../core/base/hooks/BaseHook.sol";
import {IPoolManager} from "../core/interfaces/IPoolManager.sol";
import {Hooks} from "../core/libraries/Hooks.sol";
import {PoolKey} from "../core/types/PoolKey.sol";
import {BalanceDelta} from "../core/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "../core/types/BeforeSwapDelta.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FumaDiscountHook
 * @notice Provides dynamic fee discounts to FUMA token holders
 * @dev This hook adjusts swap fees based on the swapper's FUMA balance
 */
contract FumaDiscountHook is BaseHook {
    using BeforeSwapDeltaLibrary for BeforeSwapDelta;

    /// @notice The FUMA token contract
    IERC20 public immutable fumaToken;

    /// @notice Discount tiers based on FUMA holdings
    struct DiscountTier {
        uint256 minBalance;  // Minimum FUMA balance required
        uint24 feeDiscount;  // Fee discount in basis points (e.g., 5000 = 50%)
    }

    /// @notice Array of discount tiers (sorted by minBalance ascending)
    DiscountTier[] public discountTiers;

    /// @notice Maximum fee discount (in basis points, 10000 = 100%)
    uint24 public constant MAX_DISCOUNT = 9000; // 90% max discount

    /// @notice Emitted when discount tiers are updated
    event DiscountTiersUpdated(DiscountTier[] tiers);

    /// @notice Emitted when a discount is applied
    event DiscountApplied(address indexed user, uint256 fumaBalance, uint24 discount);

    constructor(
        IPoolManager _poolManager,
        address _fumaToken
    ) BaseHook(_poolManager) {
        fumaToken = IERC20(_fumaToken);
        
        // Initialize default discount tiers
        _initializeDefaultTiers();
    }

    /// @notice Initialize default discount tiers
    function _initializeDefaultTiers() private {
        // Tier 1: 1,000 FUMA = 10% discount
        discountTiers.push(DiscountTier({
            minBalance: 1_000 * 1e18,
            feeDiscount: 1000
        }));

        // Tier 2: 10,000 FUMA = 25% discount
        discountTiers.push(DiscountTier({
            minBalance: 10_000 * 1e18,
            feeDiscount: 2500
        }));

        // Tier 3: 100,000 FUMA = 50% discount
        discountTiers.push(DiscountTier({
            minBalance: 100_000 * 1e18,
            feeDiscount: 5000
        }));

        // Tier 4: 1,000,000 FUMA = 75% discount
        discountTiers.push(DiscountTier({
            minBalance: 1_000_000 * 1e18,
            feeDiscount: 7500
        }));
    }

    /// @notice Returns the hook's permissions
    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,  // We modify fees before swap
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    /// @notice Called before a swap to apply fee discount
    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external override returns (bytes4, BeforeSwapDelta, uint24) {
        // Get user's FUMA balance
        uint256 fumaBalance = fumaToken.balanceOf(sender);

        // Calculate discount based on balance
        uint24 discount = _calculateDiscount(fumaBalance);

        // Apply discount to pool fee
        uint24 originalFee = key.fee;
        uint24 discountedFee = _applyDiscount(originalFee, discount);

        emit DiscountApplied(sender, fumaBalance, discount);

        // Return with modified fee
        return (
            BaseHook.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            discountedFee
        );
    }

    /// @notice Calculate discount based on FUMA balance
    /// @param balance User's FUMA token balance
    /// @return discount Discount in basis points
    function _calculateDiscount(uint256 balance) internal view returns (uint24 discount) {
        // Iterate through tiers from highest to lowest
        for (uint256 i = discountTiers.length; i > 0; i--) {
            DiscountTier memory tier = discountTiers[i - 1];
            if (balance >= tier.minBalance) {
                return tier.feeDiscount;
            }
        }
        return 0; // No discount
    }

    /// @notice Apply discount to fee
    /// @param originalFee Original fee in basis points
    /// @param discount Discount in basis points
    /// @return discountedFee Fee after discount
    function _applyDiscount(uint24 originalFee, uint24 discount) internal pure returns (uint24 discountedFee) {
        if (discount == 0) return originalFee;
        
        // Calculate discounted fee
        uint256 feeReduction = (uint256(originalFee) * uint256(discount)) / 10000;
        discountedFee = originalFee - uint24(feeReduction);
        
        return discountedFee;
    }

    /// @notice Get discount for a specific FUMA balance
    /// @param balance FUMA token balance
    /// @return discount Discount in basis points
    function getDiscountForBalance(uint256 balance) external view returns (uint24 discount) {
        return _calculateDiscount(balance);
    }

    /// @notice Get all discount tiers
    /// @return tiers Array of discount tiers
    function getDiscountTiers() external view returns (DiscountTier[] memory tiers) {
        return discountTiers;
    }

    /// @notice Update discount tiers (only owner)
    /// @param newTiers New discount tiers
    function updateDiscountTiers(DiscountTier[] calldata newTiers) external {
        require(msg.sender == address(poolManager), "Only pool manager");
        require(newTiers.length > 0, "Must have at least one tier");

        // Clear existing tiers
        delete discountTiers;

        // Add new tiers and validate
        for (uint256 i = 0; i < newTiers.length; i++) {
            require(newTiers[i].feeDiscount <= MAX_DISCOUNT, "Discount too high");
            if (i > 0) {
                require(newTiers[i].minBalance > newTiers[i-1].minBalance, "Tiers must be sorted");
                require(newTiers[i].feeDiscount > newTiers[i-1].feeDiscount, "Discounts must increase");
            }
            discountTiers.push(newTiers[i]);
        }

        emit DiscountTiersUpdated(newTiers);
    }
}
