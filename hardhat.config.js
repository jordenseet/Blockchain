require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan")
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');


const { infuraProjectId, accountPublicKey, accountPrivateKey, etherscanApiKey } = require('./secrets.json');
const { contract_name, collection_name, symbol } = require('./config.json');
const { contractAddress,tokenURIs } = require('./mint_config.json');
extendEnvironment((hre) => {
  const Web3 = require("web3");
  hre.Web3 = Web3;

  // hre.network.provider is an EIP1193-compatible provider.
  hre.web3 = new Web3(hre.network.provider);
});

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

task("mint", "Mint individual NFTs", async(taskArgs, hre) => {

  const account_public_key = accountPublicKey;
  const account_private_key = accountPrivateKey;

  //step 2: Define our contract ABI (Application Binary Interface) & adresses
  const contract = require("./artifacts/contracts/NFT_Collection.sol/NFT_Collection.json");
  const contract_address = contractAddress;
  const nftContract = new hre.web3.eth.Contract(contract.abi, contract_address);
  
  //step 3: Define the minting function
  async function mintNFT(tokenURI) {
    console.log("entering function mintNFT()");
    const nonce = await hre.web3.eth.getTransactionCount(account_public_key, 'latest'); //get latest nonce
    console.log("Nonce obtained: " + nonce)
  
    //the transaction
    const tx = {
      'from': account_public_key,
      'to': contract_address,
      'nonce': nonce,
      'gas': 500000,
      'maxPriorityFeePerGas': 1999999987,
      'data': nftContract.methods.mint(tokenURI).encodeABI()
    };
  
    //step 4: Sign the transaction
    const signedTx = await hre.web3.eth.accounts.signTransaction(tx, account_private_key);
    console.log("Txn signed: " + signedTx);

    console.log("Sending transaction...");
    const transactionReceipt = await hre.web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    
    console.log(`Transaction receipt: ${JSON.stringify(transactionReceipt)}`);
  }
  
  //step 5: Call the mintNFT function

  for (const uri of tokenURIs){
    console.log("Minting NFT with URI: " + uri)
    await mintNFT(uri);
  }

  // await Promise.all(tokenURIs.map(async (uri) =>{
  //   console.log("Minting NFT with URI: " + uri)
  //   await mintNFT(uri);
  // }))

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
