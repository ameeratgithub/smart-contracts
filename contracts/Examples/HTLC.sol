// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

interface IERC20{
    function transfer(address recipient, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
}
contract Hash{
    function calculateHash(string calldata _key) external pure returns(bytes32){
        return keccak256(abi.encodePacked(_key));
    }
}

/* 
    We can exchange tokens between different blockchains via Atomic swaps. Let me explain how this will work

    1. Same token will be deployed to both blockchains (i.e Binance Smart Chain and Kovan)
    2. Alice and Bob will have accounts on both blockchains
    3. Alice has tokenA on Binance, and Bob has tokenB on Kovan
    4. Alice wants tokenB on Kovan, and Bob wants tokenA on Binance
    5. They will deploy Hash TimeLocked Contract on both Kovan and Binance Smart Chain
    6. Alice has tokenA on binance, and approved bob to spend her token
    7. Bob has tokenB on kovan, and approved alice to spend his token
    8. As soon as Bob withdraw his amount, by providing secret, and his secret will be revealed.
    9. Now Alice can see his secret and withdraw tokenB on Kovan

    
 */

contract HTLC{
    uint public startTime;
    uint public lockTime = 1 days;
    string public secret; // abracadabra
    bytes32 public hash;
    address public recipient;
    address public owner;
    uint public amount;

    IERC20 public token;

    constructor(bytes32 _hash, address _recipient,address _token, uint _amount){
        recipient=_recipient;
        hash=_hash;
        owner=msg.sender;
        amount=_amount;
        token=IERC20(_token);
    }

    function fund() external{
        startTime = block.timestamp;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(string memory _secret) external{
        require(keccak256(abi.encodePacked(_secret))==hash,"wrong secret");
        secret = _secret;
        token.transfer(recipient, amount);
    }

    function refund() external{
        require(block.timestamp>startTime+lockTime,"too early");
        token.transfer(recipient, amount);
    }

}