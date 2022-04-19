// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./DydxFlashLoanBase.sol";
import "./IDydx.sol";

contract DydxFlashLoan is ICallee, DydxFlashloanBase {
    address private constant SOLO = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;

    address public flashUser;

    event Log(string message, uint256 val);

    struct MyCustomData {
        address token;
        uint256 repayAmount;
    }

    function initiateFlashLoan(address _token, uint256 _amount) external {
        ISoloMargin solo = ISoloMargin(SOLO);

        /*  
        0. WETH
        1. SAI
        2. USDC
        3. DAI
         */

        uint256 marketId = _getMarketIdFromTokenAddress(SOLO, _token);

        // Calculate repay amount (_amount + 2 wei)
        uint256 repayAmount = _getRepaymentAmountInternal(_amount);

        IERC20(_token).approve(SOLO, repayAmount);

        /* 
        1. Withdraw
        2. Call callFunction()
        3. DepositBack
         */

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](3);
        actions[0] = _getWithdrawAction(marketId, _amount);
        actions[1] = _getCallAction(
            abi.encode(MyCustomData({token: _token, repayAmount: repayAmount}))
        );
        actions[2] = _getDepositAction(marketId, _amount);

        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = _getAccountInfo();

        solo.operate(accounts, actions);
    }

    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public {
        require(msg.sender == SOLO, "Invalid caller");
        require(sender == address(this), "Invalid initiator");

        MyCustomData memory mcd = abi.decode(data, (MyCustomData));
        uint256 repayAmount = mcd.repayAmount;

        uint256 balance = IERC20(mcd.token).balanceOf(address(this));
        require(balance >= repayAmount, "Insufficient balance");

        // Do complex logic here
        flashUser = sender;
        emit Log("balance", balance);
        emit Log("repay amount", repayAmount);
        emit Log("balance - repay", balance - repayAmount);
    }
}
