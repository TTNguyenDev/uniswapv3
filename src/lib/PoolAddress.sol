// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "../UniswapV3Pool.sol";

library PoolAddress {
    function computeAddress(
        address factory,
        address token0,
        address token1,
        uint24 tickSpacing
    ) internal pure returns (address pool) {
        require(token0 < token1);

        pool = address(
            uint160(
                uint256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(
                            abi.encodePacked(token0, token1, tickSpacing),
                            keccak256(type(UniswapV3Pool).creationCode)
                        )
                    )
                )
            )
        );
    }
}
