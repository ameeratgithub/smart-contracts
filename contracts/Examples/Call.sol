// SPDX-License-Identifier: None

pragma solidity ^0.8.13;

contract TestCall{
    string public message;
    uint public x;

    event Log(string message);

    // fallback() external payable{
    //     emit Log("Fallback was called");
    // }
    function foo(string calldata _message, uint _x) external payable returns (bool, uint){
        message=_message;
        x=_x;
        return (true,999);
    }
}

contract Call{
    bytes public data;

    /* Need to deploy TestCall contract, and then pass address to callFoo */
    function callFoo(address _testContractAddress) external payable{
        (bool success, bytes memory _data) = _testContractAddress.call{value:111}(abi.encodeWithSignature("foo(string,uint256)","call foo",123));
        require(success, "Call failed");
        data=_data;
    }
    function callDoesnotExist(address _testContractAddress) external payable{
        (bool success,) = _testContractAddress.call(abi.encodeWithSignature("callDoesntExist()"));
        require(success, "Call failed");
    }
}