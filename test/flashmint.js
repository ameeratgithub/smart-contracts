const { expect } = require("chai");
const { network, ethers } = require("hardhat");
const IERC20 = require('../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json');

const { WETH_10 } = require('../config')


describe("FlashMint", function () {

  let flashMint
  let weth


  beforeEach(async () => {

    weth = await ethers.getContractAtFromArtifact(IERC20, WETH_10)

    const FlashMint = await ethers.getContractFactory('FlashMint');
    flashMint = await FlashMint.deploy()
    await flashMint.deployed()
    
  })

  it("Executes flashMint", async function () {
    const tx = await flashMint.flash()
    await tx.wait(1)

    console.log(`contract: ${flashMint.address}`)
    console.log(`sender: ${await flashMint.sender()}`)
    console.log(`token: ${await flashMint.token()}`)

    let logsCount = 0;

    return new Promise(function (resolve) {
      flashMint.on('Log', (message, value) => {
        logsCount++;
        console.log(message, value.toString())
        if (logsCount == 4) {
          resolve();
        }
      })
    })
  });
});
