// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

contract FunctionSelector{
    /* 
        We can get bytes4 hash of function definition, same as first 4 bytes if msg.data
        For example if we call transfer(address,uint256) method, then first 4 bytes of msg.data will be
        '0xa9059cbb'. We can get same value by passing 'transfer(address,uint256)' as string to get selector
        function.
    
     */

    function getSelector(string calldata _func) external pure returns (bytes4){
        return bytes4(keccak256(bytes(_func)));
    }
}

/* 
    Contract shows example of msg.data, and what it contains. 
 */
contract Receiver{
    event Log(bytes data);

    function transfer(address _to, uint _amount) external {
        // Just trying to avoid warnings
        _to=_to;
        _amount=_amount;
        
        emit Log(msg.data);

        /* 0xa9059cbb - First 4 bytes encodes function to call
           
           Following data is address, first parameter of function
           000000000000000000000000d8b934580fce35a11b58c6d73adee468a2833fa8

           following data represents uint _amount
           000000000000000000000000000000000000000000000000000000000000007b        
         */
    }
}