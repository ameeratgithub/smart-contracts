const { expect } = require("chai");
const { network, ethers } = require("hardhat");
const IERC20 = require('../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json');

const { USDC, USDC_WHALE } = require('../config')


describe.only("FlashSwap", function () {

  const WHALE = USDC_WHALE
  const TOKEN_BORROW = USDC

  const DECIMALS = 6

  const FUND_AMOUNT = new ethers.BigNumber.from(10 ** DECIMALS).mul(2*10e3)
  const BORROW_AMOUNT = new ethers.BigNumber.from(10 ** DECIMALS).mul(10e3)

//   const LENDING_POOL_ADDRESS_PROVIDER = "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5"

  let flashSwap
  let token, signer, whaleSigner


  beforeEach(async () => {

    await network.provider.request({
      method: 'hardhat_impersonateAccount',
      params: [WHALE]
    })

    whaleSigner = await ethers.getSigner(WHALE);

    signer = await ethers.getSigner()

    token = await ethers.getContractAtFromArtifact(IERC20, TOKEN_BORROW)

    const FlashSwap = await ethers.getContractFactory('FlashSwap');
    flashSwap = await FlashSwap.deploy()
    await flashSwap.deployed()
    console.log("Flash loan deployed at", flashSwap.address, " with signer", signer.address)

    const tx = await signer.sendTransaction({
      to: WHALE,
      value: ethers.utils.parseEther("1")
    })

    const balance = await token.balanceOf(WHALE)

    console.log(balance.toString(), FUND_AMOUNT.toString())

    // Balance should be more than given FUND AMOUNT
    expect(balance.gte(FUND_AMOUNT)).to.be.true

    // Transfer enough tokens to cover loan fee
    await token.connect(whaleSigner).transfer(flashSwap.address, FUND_AMOUNT)

  })

  it("Executes flashloan", async function () {
    const tx = await flashSwap.connect(whaleSigner).testFlashSwap(token.address, BORROW_AMOUNT)
    await tx.wait(1)

    let logsCount = 0;

    return new Promise(function (resolve) {
      flashSwap.on('Log', (message, value) => {
        logsCount++;
        console.log(message, value.toString())
        if (logsCount == 5) {
          resolve();
        }
      })
    })
  });
});
