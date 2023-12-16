// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "solidity-bytes-utils/contracts/BytesLib.sol";
import "../lib/BytesLibExt.sol";

library Path {
    using BytesLib for bytes;
    using BytesLibExt for bytes;

    uint256 private constant ADDR_SIZE = 20;
    uint256 private constant TICKSPACING_SIZE = 3;
    uint256 private constant NEXT_OFFSET = ADDR_SIZE + TICKSPACING_SIZE;
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH =
        POP_OFFSET + NEXT_OFFSET;

    function numPools(bytes memory path) internal pure returns (uint256) {
        return (path.length - ADDR_SIZE) / NEXT_OFFSET;
    }

    function hashMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    function getFirstPool(
        bytes memory path
    ) internal pure returns (bytes memory) {
        return path.slice(0, POP_OFFSET);
    }

    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }

    function decodeFirstPool(
        bytes memory path
    )
        internal
        pure
        returns (address tokenIn, address tokenOut, uint24 tickSpacing)
    {
        tokenIn = path.toAddress(0);
        tickSpacing = path.toUint24(ADDR_SIZE);
        tokenOut = path.toAddress(NEXT_OFFSET);
    }
}
