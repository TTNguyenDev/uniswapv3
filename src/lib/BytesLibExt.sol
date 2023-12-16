// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "solidity-bytes-utils/contracts/BytesLib.sol";

library BytesLibExt {
    function toUint24(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (uint24) {
        require(_bytes.length >= _start + 3, "toUint24_outOfBounds");
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}
