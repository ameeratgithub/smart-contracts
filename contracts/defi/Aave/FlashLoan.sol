// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./FlashLoanReceiverBase.sol";

contract FlashLoan is FlashLoanReceiverBase {
    event Log(string message, uint256 amount);

    constructor(ILendingPoolAddressesProvider _addressesProvider)
        FlashLoanReceiverBase(_addressesProvider)
    {}

    function flashLoan(address asset, uint256 amount) external {
        uint256 balance = IERC20(asset).balanceOf(address(this));

        require(balance > amount, "FlashLoan::flashLoan:Not enough balance");

        address receiverAddress = address(this); // Who's gonna receive loan amount

        address[] memory assets = new address[](1); //User can borrow multiple assets/tokens
        assets[0] = asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        /* 
            Three modes of loans for each asset.
            0 -> no debt, 1-> stable, 2-> variable
            '0' must be paid in same transaction (Flash Loan)
         */
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        /* if mode is 1 or 2, loan will be received on behalf of following address */
        address onBehalfOf = address(this);

        bytes memory params = ""; // extra data to pass abi.encode

        uint16 referralCode = 0; // Not sure what this is :)

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    /* 
    This method will be called by Aave Protocol
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums, // Fees we need to payback for borrowing
        address initiator, // Who initiated the flash loan (in this case address(this))
        bytes calldata params
    ) external override returns (bool) {
        // Do stuff here (arbitrage, liquidation, exploiting something... etc)
        // abi.decode(params) to decode params

        // Simple example
        for (uint256 i; i < assets.length; i++) {
            emit Log("Borrowed", amounts[i]);
            emit Log("fee", premiums[i]);

            uint256 amountOwed = amounts[i] + premiums[i];
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwed);
        }

        // Repay aave
        return true;
    }
}
