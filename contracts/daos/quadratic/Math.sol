// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

library Math {
    function sqrt(uint256 x) external pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
