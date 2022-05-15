const { expect } = require("chai");
const { ethers } = require("hardhat");


describe.only("Verify Signatures", function () {
    let verifySig, signer, signer2
    const MESSAGE = "Hi there!"

    const hash = ethers.utils.solidityKeccak256(['string'], [MESSAGE])

    const hashBytes = ethers.utils.arrayify(hash)

    beforeEach(async () => {
        [signer, signer2] = await ethers.getSigners()


        const VerifySig = await ethers.getContractFactory('VerifySig')

        verifySig = await VerifySig.deploy();

        await verifySig.deployed();

    })
    it("Verify signatures of a person", async function () {

        const signatures = await signer.signMessage(hashBytes)

        const verified = await verifySig.verify(signer.address, MESSAGE, signatures)

        expect(verified).to.be.true

    });
    it("doesn't verify wrong signer", async function () {

        const signatures = await signer.signMessage(hashBytes)

        const verified = await verifySig.verify(signer2.address, MESSAGE, signatures)

        expect(verified).to.be.false

    });
    it("doesn't verify wrong message", async function () {

        const signatures = await signer.signMessage(hashBytes)

        const verified = await verifySig.verify(signer.address, MESSAGE + '1', signatures)

        expect(verified).to.be.false

    });
});
