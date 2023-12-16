// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

interface IUniswapV3FlashCallback {
    function uniswapV3FlashCallback(bytes memory data) external;
}
