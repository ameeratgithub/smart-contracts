// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

contract Proxy{
    event Deployed(address);


    // We're using fallback because any contract can send ethers back to this contract 
    fallback() external payable{}
    receive() external payable {}

    /* Can deploy any contract */
    function deploy(bytes memory _code) external payable returns(address addr){
        assembly{
            addr:= create(
                // Amount of ether(s) to send to contract. In assembly, msg.value doesn't work
                callvalue(), 
                /* 
                    Pointer in First 32 bytes encode lengths of the code. Actuall code starts after 32 bytes.
                    That's why we're skipping first 32 bytes
                 */
                add(_code, 0x20),
                mload(_code) // Gets size of the ode
            )
        }

        require(addr!=address(0),"Deployment failed");
        emit Deployed(addr);
    }

    function execute(address _target, bytes memory _data) external payable{
        (bool success,) = _target.call{value:msg.value}(_data);
        require(success,"Failed");
    }
}

