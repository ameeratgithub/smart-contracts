require("@nomiclabs/hardhat-waffle");
require("solidity-coverage")
require("hardhat-gas-reporter")

/* For smart contracts upgrades */

require("@nomiclabs/hardhat-ethers")
require("@openzeppelin/hardhat-upgrades")

require("dotenv").config();
require("@openzeppelin/test-helpers/configure")({
  provider: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`
})

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  paths: {
    // sources:"./contracts", // default
    // sources:"./contracts/examples/Upgradables",
    sources: "./contracts/defi/Compound",
  },
  networks: {
    hardhat: {
      forking: {
        // url: `https://mainnet.infura.io/v3/${process.env.INFURA_PROJECT_ID}`
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`
      }
    }
  },
  mocha: {
    timeout: 400000
  }
};
