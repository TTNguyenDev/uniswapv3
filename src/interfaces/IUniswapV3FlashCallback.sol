// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

interface IUniswapV3FlashCallback {
    function uniswapV3FlashCallback(
        int24 fee0,
        int24 fee1,
        bytes memory data
    ) external;
}
