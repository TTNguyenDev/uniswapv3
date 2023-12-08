// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(uint256 amount0, uint256 amount1) external;
}
