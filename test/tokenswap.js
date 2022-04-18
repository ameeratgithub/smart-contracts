const { expect } = require("chai");
const { network, ethers } = require("hardhat");
const TokenSwapInterface = require('../artifacts/contracts/defi/Uniswap V2/TokenSwap.sol/TokenSwap.json');
const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";
const DAI_WHALE = "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE";


describe("TokenSwap", function () {
  it("Deploy the smart contract", async function () {
    await network.provider.request({
      method: 'hardhat_impersonateAccount',
      params: [DAI_WHALE]
    })

    const signer= await ethers.getSigner(DAI_WHALE);
    

    const TokenSwap = new ethers.ContractFactory(TokenSwapInterface.abi,TokenSwapInterface.bytecode, signer);
    
    const tokenSwap = await TokenSwap.deploy();
    
    await tokenSwap.deployed();

  });
});
