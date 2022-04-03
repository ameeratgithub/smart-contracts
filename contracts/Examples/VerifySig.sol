// SPDX-License-Identifier: None

pragma solidity ^0.8.13;

/* 
    Verifying Signature Contract is a contract where we can check that if given message was signed by the actual
    given signer. We'll need signer (who signed the message), message, and signatures of message.

 */
contract VerifySig{
    function verify(address _signer, string calldata _message, bytes calldata _sig) external pure returns(bool){
        // Simply getting keccak256 hash
        bytes32 messageHash = getMessageHash(_message);
        
        // Getting signed hash with predefined prefix
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        // recover function will return address of signer by provding signature and ethSignedMessageHash as input
        return recover(ethSignedMessageHash,_sig) == _signer;
    }
    function getMessageHash(string calldata _message) public pure returns (bytes32){
        return keccak256(abi.encodePacked(_message));
    }
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32){
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            _messageHash
            ));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes calldata _sig) public pure returns (address){
        /* 
            Need to split signatures into 3 different variables: r,s and v.
            We need that variables separately to pass as params to built-in method ecrecover
         */
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash,v,r,s);
    }
    function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v){
        require(_sig.length==65,"Invalid signature length");
        assembly{ // mload() is only available in assembly
            r:= mload(add(_sig,32)) // mload() skips first 32 bytes, as they encode size
            s:= mload(add(_sig,64)) // skipping bytes32 for size, and bytes32 for r
            // skipping bytes32(size)+bytes32(r)+bytes32(s) and converting to single byte (=uint8)
            v:= byte(0,mload(add(_sig,96))) 
        }
    
    }
}