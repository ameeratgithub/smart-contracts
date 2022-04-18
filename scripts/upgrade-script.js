const {ethers, upgrades} = require("hardhat");

async function main(){
    
    const NUM2 = await ethers.getContractFactory("NUM2")
    console.log("NUM1 is upgrading....");

    const previousAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

    const num2 = await upgrades.upgradeProxy(previousAddress, NUM2)

    console.log(`Num1 updated to num 2`)
    
}

main().then(()=>{
    process.exit(0)
}).catch(err=>{
    console.error(err)
    process.exit(1)
})