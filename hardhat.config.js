require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan")

const { infuraProjectId, accountPrivateKey, etherscanApiKey } = require('./secrets.json');
const { contract_name, collection_name, symbol } = require('./config.json');

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("deploy", "Deploy the smart contracts", async(taskArgs, hre) => {

  const Collection = await hre.ethers.getContractFactory(contract_name);
  const collection = await Collection.deploy(collection_name,symbol);

  await collection.deployed();

  console.log("Contract deployed to:", collection.address);

  await hre.run("verify:verify", {
    address: collection.address,
    constructorArguments: [
      collection_name,
      symbol
    ]
  })

})

module.exports = {
  solidity: "0.8.11",
  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${infuraProjectId}`,
      accounts: [accountPrivateKey]
      },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${infuraProjectId}`,
      accounts: [accountPrivateKey]
      },
      goerli: {
        url: `https://goerli.infura.io/v3/${infuraProjectId}`,
        accounts: [accountPrivateKey]
        },
      kovan: {
        url: `https://kovan.infura.io/v3/${infuraProjectId}`,
        accounts: [accountPrivateKey]
        },
    bsc_testnet: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
      accounts: [accountPrivateKey]
    }
  },
  etherscan: {
    apiKey: etherscanApiKey,
  }
};
