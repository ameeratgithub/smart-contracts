// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

contract TestContract2{
    address public owner = msg.sender;
    uint256 public value = msg.value;
    uint256 public x;
    uint256 public y;
    constructor(uint256 _x, uint256 _y) payable{
        x=_x;
        y=_y;
    }
}