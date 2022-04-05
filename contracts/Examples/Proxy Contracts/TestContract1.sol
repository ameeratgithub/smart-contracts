// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

contract TestContract1{
    address public owner = msg.sender;
    function setOwner(address _owner) public{
        require(msg.sender==owner,"Not owner");
        owner=_owner;
    }
}