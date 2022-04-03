// SPDX-License-Identifier: None

pragma solidity ^0.8.13;

import "./TestContract1.sol";
import "./TestContract2.sol";

contract Helper{
    // Get Bytecode to deploy TestContrat1 via Proxy Contract
    function getByteCodeOfContract1() external pure returns (bytes memory){
        bytes memory bytecode = type(TestContract1).creationCode;
        return bytecode;
    }

    // Get's bytecode with inputs. TestContract2 requires 2 constructor arguments while deploying
    function getByteCodeOfContract2(uint256 _x, uint256 _y) external pure returns (bytes memory){
        bytes memory bytecode = type(TestContract2).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_x,_y));
    }

    // Call data to call function setOwner from TestContract1
    function getCalldata(address _owner) external pure returns (bytes memory){
        return abi.encodeWithSignature("setOwner(address)",_owner);
    }
}