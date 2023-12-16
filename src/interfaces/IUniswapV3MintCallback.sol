// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

interface IUniswapV3MintCallback {
    function uniswapV3MintCallback(
        int256 amount0,
        int256 amount1,
        bytes memory data
    ) external;
}
