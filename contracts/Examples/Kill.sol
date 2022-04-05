// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

// selfdestruct
// - Delete Contract
// - force send Ether to any address

contract Kill{
    constructor() payable{}
    function kill() external{
        selfdestruct(payable(msg.sender)); 
    }
    function testCall() external pure returns(uint){
        return 123;
    }
}

/* 
    Ever wondered if we can delete our smart contract? selfdestruct is here to help.
    we've to transfer ETHERS in smartcontract to some other EOA or contract. After transfering, smart contract
    will be deleted. Receiver contract doesn't have to implement fallback function to receive ethers, via
    selfdestruct() method

 */
contract Helper{
    function getBalance() external view returns(uint){
        return address(this).balance;
    }
    function kill(Kill _kill) external{
        _kill.kill();
    }
}


/* 

    PiggyBank is just simple example of selfdestruct(), where contract needs to destroy itself after successful
    withdrawl.

 */
contract PiggyBank{
    event Deposit(uint amount);
    event Withdraw(uint amount);
    address public owner = msg.sender;
    receive() external payable{
        emit Deposit(msg.value);
    }

    function withdraw() external{
        require(msg.sender==owner,"not owner");
        emit Withdraw(address(this).balance);
        selfdestruct(payable(msg.sender));
    }
}