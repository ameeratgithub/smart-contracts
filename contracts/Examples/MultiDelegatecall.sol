// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract MultiDelegatecall{
    error DelegatecallFailed();
    function multiDelegateCall(bytes[] calldata data) external payable returns(bytes[] memory results){
        results = new bytes[](data.length);
        for(uint i;i<data.length;i++){
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if(!ok){
                revert DelegatecallFailed();
            }
            results[i]=res;
        }
    }

 
}

/* 
    Why should we use multi delegatecall?? Why not multi call? Answer is to perserve the state variables

    alice -> multi call -- call --> test (msg.sender = multi call)

    alice -> multi delegatecall -- delegatecall --> test (msg.sender=alice)

 */

 contract TestMultiDelegatecall is MultiDelegatecall{

     event Log(address caller, string func, uint i);

     function func1(uint x, uint y) external{
         emit Log(msg.sender, "func1", x + y );
     }

     function func2() external returns (uint){
         emit Log(msg.sender,"func2",2);
         return 111;
     }

    mapping (address=>uint) public balanceOf;

    /* 
        WARNING: Unsafe code when used in combination with multi-delegatecall
        Mint function can be called more than 1 time in 1 transaction, so balanceOf[msg.sender]= msg.value*n
        where n = number of times mint called in multi-delegatecall
    
     */
    function mintFunc() external payable{
        balanceOf[msg.sender]+=msg.value;
    }
}

contract Helper{
    function getFunc1Data(uint x,uint y) external pure returns (bytes memory){
        return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector,x,y);
    }
    function getFunc2Data() external pure returns (bytes memory){
        return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
    }
    function getMintData() external pure returns (bytes memory){
        return abi.encodeWithSelector(TestMultiDelegatecall.mintFunc.selector);
    }
}