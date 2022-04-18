const {ethers, upgrades} = require("hardhat");

async function main(){
    
    const NUM1 = await ethers.getContractFactory("NUM1")
    const num1 = await upgrades.deployProxy(NUM1,[10],{
        initializer:'update'
    })

    await num1.deployed()

    console.log(`Num1 deployed at ${num1.address}`)
    
}

main().then(()=>{
    process.exit(0)
}).catch(err=>{
    console.error(err)
    process.exit(1)
})