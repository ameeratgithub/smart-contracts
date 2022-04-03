// SPDX-License-Identifier: None

pragma solidity ^0.8.13;

contract HashFunc{
    function hash(string calldata text, uint num, address addr) external pure returns(bytes32){
        return keccak256(abi.encodePacked(text,num,addr));
    }
    function encode(string calldata text0, string calldata text1) external pure returns(bytes memory){
        return abi.encode(text0,text1);
    }
    function encodePacked(string calldata text0, string calldata text1) external pure returns(bytes memory){
        return abi.encodePacked(text0,text1);
    }
    function collision(string calldata text0, uint x,string calldata text1) external pure returns(bytes32 ){
        return keccak256(abi.encodePacked(text0,x,text1));
    }
}