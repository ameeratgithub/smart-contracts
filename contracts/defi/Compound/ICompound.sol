// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

interface CErc20{
    function balanceOf(address) external view returns (uint);

    function mint(uint) external returns (uint);
    
    function exchangeRateCurrent() external returns (uint);
    
    function supplyRatePerBlock() external returns (uint);
    
    function balanceOfUnderlying(address) external returns(uint);
    
    function redeem(uint) external returns (uint);
    
    function redeemUnderlying(uint) external returns(uint);
}

interface CEth{
    function balanceOf(address) external view returns (uint);

    function mint(uint) external returns (uint);
    
    function exchangeRateCurrent() external returns (uint);
    
    function supplyRatePerBlock() external returns (uint);
    
    function balanceOfUnderlying(address) external returns(uint);
    
    function redeem(uint) external returns (uint);
    
    function redeemUnderlying(uint) external returns(uint);
}