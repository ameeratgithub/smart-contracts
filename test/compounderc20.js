const { time } = require('@openzeppelin/test-helpers')
const { expect } = require("chai");
const { network, ethers } = require("hardhat");
const IERC20 = require('../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json');
const CERC20 = require('../artifacts/contracts/defi/Compound/ICompound.sol/CErc20.json');

const { WBTC_WHALE, WBTC, CWBTC } = require('../config')

const DEPOSIT_AMOUNT = new ethers.BigNumber.from(10 ** 8)

describe.only("compounderc20", function () {

    const WHALE = WBTC_WHALE
    const TOKEN = WBTC
    const C_TOKEN = CWBTC

    let provider
    let compound
    let token, cToken, whaleSigner, signer


    beforeEach(async () => {
        provider = new ethers.providers.AlchemyProvider('homestead', process.env.ALCHEMY_API_KEY)

        await network.provider.request({
            method: 'hardhat_impersonateAccount',
            params: [WHALE]
        })

        whaleSigner = await ethers.getSigner(WHALE);

        signer = await ethers.getSigner()

        await signer.sendTransaction({
            to: WHALE,
            value: ethers.utils.parseEther("1")
        })

        token = await ethers.getContractAtFromArtifact(IERC20, TOKEN)
        cToken = await ethers.getContractAtFromArtifact(CERC20, C_TOKEN)

        const Compound = await ethers.getContractFactory('CompoundERC20');
        compound = await Compound.deploy(TOKEN, C_TOKEN)
        await compound.deployed()

        const balance = await token.balanceOf(WHALE)
        expect(balance.gte(DEPOSIT_AMOUNT)).to.be.true
    })

    const snapshot = async (compound, token, cToken) => {
        const { exchangeRate, supplyRate } = await compound.callStatic.getInfo()

        return {
            exchangeRate, supplyRate,
            estimateBalanceOfUnderlying: await compound.callStatic.estimateBalanceOfUnderlying(),
            balanceOfUnderlying: await compound.callStatic.balanceOfUnderlying(),
            token: await token.balanceOf(compound.address),
            cToken: await cToken.balanceOf(compound.address)
        }
    }

    it("Should supply and redeem", async function () {

        await token.connect(whaleSigner).approve(compound.address, DEPOSIT_AMOUNT)
        await compound.connect(whaleSigner).supply(DEPOSIT_AMOUNT)

        let after = await snapshot(compound, token, cToken)

        console.log('---------- Supply -----------')
        console.log(`exchangeRate: ${after.exchangeRate}`)
        console.log(`supplyRate: ${after.supplyRate}`)
        console.log(`estimateBalanceOfUnderlying: ${after.estimateBalanceOfUnderlying}`)
        console.log(`balanceOfUnderlying: ${after.balanceOfUnderlying}`)
        console.log(`token: ${after.token}`)
        console.log(`cToken: ${after.cToken}`)


        // Accrue interest on supply
        // const blockNumber = await provider.getBlockNumber()
        // console.log(`Current block: ${blockNumber}, futureBlock: ${blockNumber+2000}`)
        const block = await provider.getBlockNumber()
        console.log(`Current test block: ${block}`)
        await time.advanceBlockTo(block+10)

        console.log("After moving forward")
        console.log(`Current provider block: ${await provider.getBlockNumber()}`)

        after = await snapshot(compound, token, cToken)

        console.log(`--- after some time ---`)
        console.log(`estimate balance of underlying ${after.estimateBalanceOfUnderlying}`)
        console.log(`balance of underlying ${after.balanceOfUnderlying}`)
        console.log(`token ${after.token}`)
        console.log(`cToken ${after.cToken}`)

        // Redeeming cTokens
        const cTokenAmount = await cToken.balanceOf(compound.address)
        await compound.connect(whaleSigner).redeem(cTokenAmount)

        after = await snapshot(compound, token, cToken)

        console.log(`--- after redeeming ---`)
        console.log(`estimate balance of underlying: ${after.estimateBalanceOfUnderlying}`)
        console.log(`balanceOfUnderlying: ${after.balanceOfUnderlying}`)
        console.log(`token: ${after.token}`)
        console.log(`cToken: ${after.cToken}`)
    });
});
