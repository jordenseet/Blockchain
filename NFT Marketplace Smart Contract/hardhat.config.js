require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan")

const { nft_contract_name, marketplace_contract_name, collection_name, symbol,signatories, num_sigs, penalty } = require('./config.json');

const { nftContractAddress,marketplaceContractAddress,tokenURIs,minterPublicKey,minterPrivateKey} = require('./mint_config.json');
const { listingTokenID, minBid,saleStartBlockNumber,saleEndBlockNumber,exercisePeriod,listerPublicKey,listerPrivateKey } = require('./listing_config.json');
const { bidListingID, bidValue, bidderPublicKey,bidderPrivateKey } = require('./bidding_config.json');
const { claimListingID, claimantPublicKey, claimantPrivateKey } = require('./claim_config.json');
const { expiryListingID, signatoryPublicKey,signatoryPrivateKey } = require('./expiry_config.json');

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

task("deploy_collection", "Deploy the Collection smart contract to ganache", async(taskArgs, hre) => {

  const Collection = await hre.ethers.getContractFactory(nft_contract_name);
  const collection = await Collection.deploy(collection_name,symbol);

  await collection.deployed();

  console.log("Contract deployed to:", collection.address);
})

task("deploy_marketplace", "Deploy the Marketplace smart contract to ganache", async(taskArgs, hre) => {

  const Marketplace = await hre.ethers.getContractFactory(marketplace_contract_name);
  const marketplace = await Marketplace.deploy(signatories,num_sigs,penalty);

  await marketplace.deployed();

  console.log("Contract deployed to:", marketplace.address);

})

task("mint", "Mint individual NFTs", async(taskArgs, hre) => {

  const account_public_key = minterPublicKey;
  const account_private_key = minterPrivateKey;

  const contract_nft = require("./artifacts/contracts/NFT_Collection.sol/NFT_Collection.json");
  const nft_contract_address = nftContractAddress;
  const nftContract = new hre.web3.eth.Contract(contract_nft.abi, nft_contract_address);
  
  async function mintNFT(tokenURI) {
    const gasPrice = await hre.web3.eth.getGasPrice();
    const nonce = await hre.web3.eth.getTransactionCount(account_public_key, 'latest'); //get latest nonce
    const lastBlock = await web3.eth.getBlock("latest");
    const gasLimit = hre.web3.utils.toHex(lastBlock.gasLimit)
    console.log("Nonce obtained: " + nonce)
    
    const tx = {
      'from': account_public_key,
      'to': nft_contract_address,
      'nonce': nonce,
      'gasPrice':gasPrice,
      'gasLimit': gasLimit,
      'data': nftContract.methods.mint(tokenURI).encodeABI()
    };
  
    const signedTx = await hre.web3.eth.accounts.signTransaction(tx, account_private_key);
    console.log("Txn signed: " + signedTx);

    console.log("Sending transaction...");
    const transactionReceipt = await hre.web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    
    console.log(`Transaction receipt: ${JSON.stringify(transactionReceipt)}`);
  }
  
  for (const uri of tokenURIs){
    console.log("Minting NFT with URI: " + uri)
    await mintNFT(uri);
  }

})

task("approveMarketplace", "Approve Marketplace for listing", async(taskArgs, hre) => {

  const account_public_key = minterPublicKey;
  const account_private_key = minterPrivateKey;

  const contract_nft = require("./artifacts/contracts/NFT_Collection.sol/NFT_Collection.json");
  const nft_contract_address = nftContractAddress;
  const nftContract = new hre.web3.eth.Contract(contract_nft.abi, nft_contract_address);

  const marketplace_contract_address = marketplaceContractAddress;
  
  async function approveNFT(tokenID) {
    const gasPrice = await hre.web3.eth.getGasPrice();
    const nonce = await hre.web3.eth.getTransactionCount(account_public_key, 'latest'); //get latest nonce
    const lastBlock = await web3.eth.getBlock("latest");
    const gasLimit = hre.web3.utils.toHex(lastBlock.gasLimit)
    console.log("Nonce obtained: " + nonce)
    
    const tx = {
      'from': account_public_key,
      'to': nft_contract_address,
      'nonce': nonce,
      'gasPrice':gasPrice,
      'gasLimit': gasLimit,
      'data': nftContract.methods.approve(marketplace_contract_address,tokenID).encodeABI()
    };
  
    const signedTx = await hre.web3.eth.accounts.signTransaction(tx, account_private_key);
    console.log("Txn signed: " + signedTx);

    console.log("Sending transaction...");
    const transactionReceipt = await hre.web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    
    console.log(`Transaction receipt: ${JSON.stringify(transactionReceipt)}`);
  }
  
  for (i = 0; i< tokenURIs.length;i++){
    console.log("Approving Marketplace to escrow tokenID " + i)
    await approveNFT(i);
  }
})

task("listNFT", "List NFT on marketplace", async(taskArgs, hre) => {
  const account_public_key = listerPublicKey;
  const account_private_key = listerPrivateKey;

  const contract_marketplace = require("./artifacts/contracts/NFT_Marketplace.sol/NFT_Marketplace.json");
  const marketplace_contract_address = marketplaceContractAddress;
  const marketplaceContract = new hre.web3.eth.Contract(contract_marketplace.abi, marketplace_contract_address);

  const nft_contract_address = nftContractAddress;

  const gasPrice = await hre.web3.eth.getGasPrice();
  const nonce = await hre.web3.eth.getTransactionCount(account_public_key, 'latest'); //get latest nonce
  const lastBlock = await web3.eth.getBlock("latest");
  const gasLimit = hre.web3.utils.toHex(lastBlock.gasLimit)
  console.log("Nonce obtained: " + nonce)
  console.log("Method args",nft_contract_address,listingTokenID,minBid,saleStartBlockNumber,saleEndBlockNumber,exercisePeriod)
  
  const tx = {
    'from': account_public_key,
    'to': marketplace_contract_address,
    'nonce': nonce,
    'gasPrice':gasPrice,
    'gasLimit': gasLimit,
    'data': marketplaceContract.methods.listNFT(nft_contract_address,listingTokenID,minBid,saleStartBlockNumber,saleEndBlockNumber,exercisePeriod).encodeABI()
  };

  const signedTx = await hre.web3.eth.accounts.signTransaction(tx, account_private_key);
  console.log("Txn signed: " + signedTx);

  console.log("Sending transaction...");
  const transactionReceipt = await hre.web3.eth.sendSignedTransaction(signedTx.rawTransaction);
  
  console.log(`Transaction receipt: ${JSON.stringify(transactionReceipt)}`);

})

task("bidNFT", "Bid for NFT listing on marketplace", async(taskArgs, hre) => {

  const account_public_key = bidderPublicKey;
  const account_private_key = bidderPrivateKey;

  const contract_marketplace = require("./artifacts/contracts/NFT_Marketplace.sol/NFT_Marketplace.json");
  const marketplace_contract_address = marketplaceContractAddress;
  const marketplaceContract = new hre.web3.eth.Contract(contract_marketplace.abi, marketplace_contract_address);

  const gasPrice = await hre.web3.eth.getGasPrice();
  const nonce = await hre.web3.eth.getTransactionCount(account_public_key, 'latest'); //get latest nonce
  const lastBlock = await web3.eth.getBlock("latest");
  const gasLimit = hre.web3.utils.toHex(lastBlock.gasLimit)

  const tx = {
    'from': account_public_key,
    'to': marketplace_contract_address,
    'nonce': nonce,
    'gasPrice':gasPrice,
    'gasLimit': gasLimit,
    'data': marketplaceContract.methods.bid(bidListingID).encodeABI(),
    'value': bidValue
  };

  const signedTx = await hre.web3.eth.accounts.signTransaction(tx, account_private_key);
  console.log("Txn signed: " + signedTx);

  console.log("Sending transaction...");
  const transactionReceipt = await hre.web3.eth.sendSignedTransaction(signedTx.rawTransaction);
  
  console.log(`Transaction receipt: ${JSON.stringify(transactionReceipt)}`);

})

task("claimNFT", "claim NFT listing on marketplace", async(taskArgs, hre) => {

  const account_public_key = claimantPublicKey;
  const account_private_key = claimantPrivateKey;

  const contract_marketplace = require("./artifacts/contracts/NFT_Marketplace.sol/NFT_Marketplace.json");
  const marketplace_contract_address = marketplaceContractAddress;
  const marketplaceContract = new hre.web3.eth.Contract(contract_marketplace.abi, marketplace_contract_address);

  const gasPrice = await hre.web3.eth.getGasPrice();
  const nonce = await hre.web3.eth.getTransactionCount(account_public_key, 'latest'); //get latest nonce
  const lastBlock = await web3.eth.getBlock("latest");
  const gasLimit = hre.web3.utils.toHex(lastBlock.gasLimit)

  const tx = {
    'from': account_public_key,
    'to': marketplace_contract_address,
    'nonce': nonce,
    'gasPrice':gasPrice,
    'gasLimit': gasLimit,
    'data': marketplaceContract.methods.claim(claimListingID).encodeABI()
  };

  const signedTx = await hre.web3.eth.accounts.signTransaction(tx, account_private_key);
  console.log("Txn signed: " + signedTx);

  console.log("Sending transaction...");
  const transactionReceipt = await hre.web3.eth.sendSignedTransaction(signedTx.rawTransaction);
  
  console.log(`Transaction receipt: ${JSON.stringify(transactionReceipt)}`);

})

task("proposeExpiry", "Propose expiry of listing on marketplace", async(taskArgs, hre) => {

  const account_public_key = signatoryPublicKey;
  const account_private_key = signatoryPrivateKey;

  const contract_marketplace = require("./artifacts/contracts/NFT_Marketplace.sol/NFT_Marketplace.json");
  const marketplace_contract_address = marketplaceContractAddress;
  const marketplaceContract = new hre.web3.eth.Contract(contract_marketplace.abi, marketplace_contract_address);

  const gasPrice = await hre.web3.eth.getGasPrice();
  const nonce = await hre.web3.eth.getTransactionCount(account_public_key, 'latest'); //get latest nonce
  const lastBlock = await web3.eth.getBlock("latest");
  const gasLimit = hre.web3.utils.toHex(lastBlock.gasLimit)

  const tx = {
    'from': account_public_key,
    'to': marketplace_contract_address,
    'nonce': nonce,
    'gasPrice':gasPrice,
    'gasLimit': gasLimit,
    'data': marketplaceContract.methods.proposeExpiration(expiryListingID).encodeABI()
  };

  const signedTx = await hre.web3.eth.accounts.signTransaction(tx, account_private_key);
  console.log("Txn signed: " + signedTx);

  console.log("Sending transaction...");
  const transactionReceipt = await hre.web3.eth.sendSignedTransaction(signedTx.rawTransaction);
  
  console.log(`Transaction receipt: ${JSON.stringify(transactionReceipt)}`);

})

module.exports = {
  solidity: "0.8.11",
};
