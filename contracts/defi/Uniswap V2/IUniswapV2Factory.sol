// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

interface IUniswapV2Factory{
    function getPair(address _tokenA, address _tokenB) external returns (address);
}