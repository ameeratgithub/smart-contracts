const { expect } = require("chai");
const { network, ethers } = require("hardhat");
const IERC20 = require('../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json');

const {USDC, USDC_WHALE} = require('../config')


describe.only("FlashLoan", function () {

  const WHALE = USDC_WHALE
  const TOKEN_BORROW = USDC

  const DECIMALS = 6

  const FUND_AMOUNT = new ethers.BigNumber.from(10**DECIMALS).mul(2000)
  const BORROW_AMOUNT = new ethers.BigNumber.from(10**DECIMALS).mul(1000)

  const LENDING_POOL_ADDRESS_PROVIDER  = "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5"

  let flashLoan
  let token, signer


  beforeEach(async()=>{
    token = await ethers.getContractAtFromArtifact(IERC20, TOKEN_BORROW)
    const FlashLoan = await ethers.getContractFactory('FlashLoan');
    flashLoan = await FlashLoan.deploy(LENDING_POOL_ADDRESS_PROVIDER)
    signer = await ethers.getSigner()

    await flashLoan.deployed()

    console.log("Flash loan deployed at", flashLoan.address, " with signer", signer.address)

    const tx = await signer.sendTransaction({
      to: WHALE,
      value: ethers.utils.parseEther("1")
    })

    const balance = await token.balanceOf(WHALE)

    console.log(balance.toString())

    // Balance should be more than given FUND AMOUNT
    expect(balance.gte(FUND_AMOUNT)).to.be.true

    // await token.transfer(flashLoan.address, FUND_AMOUNT)

  })
    
  it("Deploy the smart contract", async function () {
    // await network.provider.request({
    //   method: 'hardhat_impersonateAccount',
    //   params: [DAI_WHALE]
    // })

    // const signer= await ethers.getSigner(DAI_WHALE);
    

    // const TokenSwap = new ethers.ContractFactory(TokenSwapInterface.abi,TokenSwapInterface.bytecode, signer);

    
    // const tokenSwap = await TokenSwap.deploy();
    
    // await tokenSwap.deployed();

  });
});
