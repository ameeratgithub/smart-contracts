// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IWETH10.sol";

contract FlashMint {
    address private WETH = 0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9F;
    bytes32 public immutable CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    address public sender;
    address public token;

    event Log(string name, uint value);

    function flash() external {
        uint total = IERC20(WETH).totalSupply();

        uint amount = total+1;

        // Borrow more than total available (FlashMint)
        emit Log("total Supply",total);

        IERC20(WETH).approve(WETH, amount);

        bytes memory data = "";

        IWETH10(WETH).flashLoan(address(this), WETH, amount, data);
    }

    // Called by WETH10
    function onFlashLoan(
        address _sender,
        address _token,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _data
    ) external returns (bytes32){
        sender = _sender;
        token=_token;

        uint bal = IERC20(WETH).balanceOf(address(this)); 

        emit Log("Amount",_amount);
        emit Log("Fee",_fee);
        emit Log("Balance",bal);

        return CALLBACK_SUCCESS;
    }
}
