// SPDX-License-Identifier: None

pragma solidity ^0.8.13;

contract TestDelegateCall{
    uint public num;
    address public sender;
    uint public value;

    /* 
        Adding 4th variable to end of variables list, perserving same order as contract which will call this contract,
        while updating contract. Otherwise it will show strange behaviour in outputs
     */
    address public owner;

    function setVars(uint _num)external payable{
        num = 2 * _num;
        sender = msg.sender;
        value=msg.value;
    }
}


/* 

    Delegate calls just perserve the context of calling contract. For example we're calling 
    function of other contract, but delegate call will update/use our state variables. It can be
    used to update smart contracts. To use delegate call, we must have same state variables as
    contract we're calling. See the code for further clarification

 */
contract DelegateCall{
    uint public num;
    address public sender;
    uint public value;
    function setVars(address _test, uint _num) external payable{
        // First Way to call function
        // _test.delegatecall(abi.encodeWithSignature("setVars(uint256)",_num));

        // Second way to call function
        (bool success,)= _test.delegatecall(
            abi.encodeWithSelector(TestDelegateCall.setVars.selector,_num)
            );
        require(success,"call failed");
    }
}