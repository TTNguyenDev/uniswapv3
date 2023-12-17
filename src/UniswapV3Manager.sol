// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./UniswapV3Pool.sol";
import "./lib/TickMath.sol";
import "./lib/LiquidityMath.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3Manager.sol";
import "./interfaces/IUniswapV3Pool.sol";

contract UniswapV3Manager is IUniswapV3Manager {
    error TooLittleReceived(uint256);

    function mint(
        MintParams calldata params
    ) public returns (uint256 amount0, uint256 amount1) {
        IUniswapV3Pool pool = IUniswapV3Pool(params.poolAddress);

        (uint160 sqrtPriceX96, ) = pool.slot0();
        uint160 sqrtPriceLowerX96 = TickMath.getSqrtRatioAtTick(
            params.lowerTick
        );
        uint160 sqrtPriceUpperX96 = TickMath.getSqrtRatioAtTick(
            params.upperTick
        );

        uint128 liquidity = LiquidityMath.getLiquidityForAmounts(
            sqrtPriceX96,
            sqrtPriceLowerX96,
            sqrtPriceUpperX96,
            params.amount0Desired,
            params.amount1Desired
        );

        (amount0, amount1) = pool.mint(
            msg.sender,
            params.lowerTick,
            params.upperTick,
            liquidity,
            abi.encode(
                IUniswapV3Pool.CallbackData({
                    token0: pool.token0(),
                    token1: pool.token1(),
                    payer: msg.sender
                })
            )
        );
    }

    function swapSingle(
        SwapSingleParams calldata params
    ) public returns (uint256 amountOut) {
        amountOunt = _swap(
            params.amountIn,
            msg.sender,
            params.sqrtPriceLimitX96,
            SwapCallbackData({
                path: abi.encodePacked(
                    params.tokenIn,
                    params.tickSpacing,
                    params.tokenOut
                ),
                payper: msg.sender
            })
        );
    }

    function _swap(
        uint256 amountIn,
        address recipient,
        uint160 sqprtPriceLimitX96,
        SwapCallBackData memory data
    ) internal returns (uint256 amountOut) {
        (address tokenIn, address tokenOut, uint24 tickSpacing) = data
            .path
            .decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0, int256 amount1) = getPool(
            tokenIn,
            tokenOut,
            tickSpacing
        ).swap(
                recipient,
                zeroForOne,
                amountIn,
                sqprtPriceLimitX96 == 0
                    ? (
                        zeroForOne
                            ? TickMath.MIN_SQRT_RATIO + 1
                            : TickMath.MAX_SQRT_RATIO - 1
                    )
                    : sqprtPriceLimitX96,
                abi.encode(data)
            );

        amountOut = uint256(-(zeroForOne ? amount1 : amount0));
    }

    function getPool(
        address token0,
        address token1,
        uint24 tickSpacing
    ) internal view returns (IUniswapV3Pool pool) {
        (token0, token1) = token0 < token1
            ? (token0, token1)
            : (token1, token0);
        pool = IUniswapV3Pool(
            PoolAddress.computeAddress(factory, token0, token1, tickSpacing)
        );
    }

    function swap(SwapParams memory params) public returns (uint256 amountOut) {
        address payer = msg.sender;
        bool hasMultiplePools;

        while (true) {
            hasMultiplePools = params.path.hasMultiplePools();

            params.amountIn = _swap(
                params.amountIn,
                hasMultiplePools ? address(this) : params.recipient,
                0,
                SwapCallbackData({
                    path: params.path.getFirstPool(),
                    payer: payer
                })
            );

            if (hasMultiplePools) {
                payer = address(this);
                params.path = params.path.skipToken();
            } else {
                amountOut = params.amountIn;
                break;
            }

            if (amountOut < params.minAmountOut)
                revert TooLittleReceived(amoutOut);
        }
    }

    function uniswapV3SwapCallback(
        int256 amount0,
        int256 amount1,
        bytes calldata data_
    ) public {
        SwapCallbackData memory data = abi.decode(data_, (SwapCallbackData));
        (address tokenIn, address tokenOut, ) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;

        int256 amount = zeroForOne ? amount0 : amount1;

        if (data.payer == address(this)) {
            IERC20(tokenIn).transfer(msg.sender, uint256(amount));
        } else {
            IERC20(tokenIn).transferFrom(
                data.payer,
                msg.sender,
                uint256(amount)
            );
        }
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) public {
        UniswapV3Pool.CallbackData memory extra = abi.decode(
            data,
            (UniswapV3Pool.CallbackData)
        );

        IERC20(extra.token0).transferFrom(extra.payer, msg.sender, amount0);
        IERC20(extra.token1).transferFrom(extra.payer, msg.sender, amount1);
    }
}
