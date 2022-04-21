// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IWETH10 {
  function flashLoan(
    address receiver,
    address token,
    uint value,
    bytes calldata data
  ) external returns (bool);
}