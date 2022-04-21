const { expect } = require("chai");
const { network, ethers } = require("hardhat");
const IERC20 = require('../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json');

const { USDC, USDC_WHALE } = require('../config')


describe("FlashLoan", function () {

  const WHALE = USDC_WHALE
  const TOKEN_BORROW = USDC

  const DECIMALS = 6

  const FUND_AMOUNT = new ethers.BigNumber.from(10 ** DECIMALS).mul(2000)
  const BORROW_AMOUNT = new ethers.BigNumber.from(10 ** DECIMALS).mul(1000)
  const SOLO = '0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e';
  let flashLoan
  let token, signer, whaleSigner


  beforeEach(async () => {

    await network.provider.request({
      method: 'hardhat_impersonateAccount',
      params: [WHALE]
    })

    whaleSigner = await ethers.getSigner(WHALE);

    console.log(`Whale signer address is ${whaleSigner.address}`)

    token = await ethers.getContractAtFromArtifact(IERC20, TOKEN_BORROW)
    const FlashLoan = await ethers.getContractFactory('DydxFlashLoan');
    flashLoan = await FlashLoan.deploy()
    signer = await ethers.getSigner()

    await flashLoan.deployed()

    console.log("Flash loan deployed at", flashLoan.address, " with signer", signer.address)

    const tx = await signer.sendTransaction({
      to: WHALE,
      value: ethers.utils.parseEther("1")
    })

    await tx.wait(1)

    const balance = await token.balanceOf(WHALE)

    console.log(balance.toString())

    // Balance should be more than given FUND AMOUNT
    expect(balance.gte(FUND_AMOUNT)).to.be.true

    // Transfer enough tokens to cover loan fee
    await token.connect(whaleSigner).transfer(flashLoan.address, FUND_AMOUNT)

    const soloBalance = await token.balanceOf(SOLO)

    console.log(`Solo balance: ${soloBalance.toString()}`)

    expect(soloBalance.gte(BORROW_AMOUNT)).to.be.true

  })

  it("Executes flashloan", async function () {
    const tx = await flashLoan.connect(whaleSigner).initiateFlashLoan(token.address, BORROW_AMOUNT)
    await tx.wait(1)
    
    let logsCount = 0;

    console.log(`${await flashLoan.flashUser()}`)

    return new Promise(function (resolve) {
      flashLoan.on('Log', (message, value) => {
        logsCount++;
        console.log(message, value.toString())
        if (logsCount == 3) {
          resolve();
        }
      })
    })
  });
});
