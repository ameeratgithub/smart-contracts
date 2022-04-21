// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ICompound.sol";

contract CompoundERC20 {
    IERC20 public token;
    CErc20 public cToken;

    constructor(address _token, address _cToken) {
        token = IERC20(_token);
        cToken = CErc20(_cToken);
    }

    function supply(uint256 _amount) external {
        token.transferFrom(msg.sender, address(this), _amount);
        token.approve(address(cToken), _amount);
        require(
            cToken.mint(_amount) == 0,
            "CompoundERC20::supply: Minting failed"
        );
    }

    function getCTokenBalance() external view returns (uint256) {
        return cToken.balanceOf(address(this));
    }

    // Not a view function
    function getInfo()
        external
        returns (uint256 exchangeRate, uint256 supplyRate)
    {
        // Amount of current exchange rate from cToken to underlying token
        exchangeRate = cToken.exchangeRateCurrent();

        // Amount added to your supply balance in this block
        supplyRate = cToken.supplyRatePerBlock();
    }

    function estimateBalanceOfUnderlying() external returns (uint256) {
        uint256 balance = this.getCTokenBalance();
        uint256 exchangeRate = cToken.exchangeRateCurrent();
        uint256 decimals = 8;
        uint256 cTokenDecimals = 8;

        return (balance * exchangeRate) / 10**(18 + decimals - cTokenDecimals);
    }

    function balanceOfUnderlying() external returns (uint256) {
        return cToken.balanceOfUnderlying(address(this));
    }

    function redeem(uint256 _cTokenAmount) external {
        require(cToken.redeem(_cTokenAmount) == 0, "Redeem failed");
    }
    
}
