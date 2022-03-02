A Design Decision document is available as design_decisions.md . Please read that to understand more about the design of this project.

To run this project, you need to install the dependencies. To do this, run `npm i`

After you have installed the dependencies, open a terminal and cd into this directory. Run Ganache by running `npm run ganache` on this terminal. When Ganache initialises, you would see something like this:

```
Ganache CLI v6.12.1 (ganache-core: 2.13.1)

Available Accounts
==================
(0) 0xe261e26aECcE52b3788Fac9625896FFbc6bb4424 (100 ETH)
(1) 0xcE16e8eb8F4BF2E65BA9536C07E305b912BAFaCF (100 ETH)
(2) 0x02f1c4C93AFEd946Cce5Ad7D34354A150bEfCFcF (100 ETH)
(3) 0x0B75F0b70076Fab3F18F94700Ecaf3B00fE528E7 (100 ETH)
(4) 0x7194d1F1d43c2c58302BB61a224D41B649e65C93 (100 ETH)
(5) 0xC9A2d92c5913eDEAd9a7C936C96631F0F2241063 (100 ETH)
(6) 0xD79BcDE5Cb11cECD1dfC6685B65690bE5b6a611e (100 ETH)
(7) 0xb6D080353f40dEcA2E67108087c356d3A1AfcD64 (100 ETH)
(8) 0x31A064DeeaD74DE7B9453beB4F780416D8859d3b (100 ETH)
(9) 0x37524a360a40C682F201Fb011DB7bbC8c8A247c6 (100 ETH)

Private Keys
==================
(0) 0x7f109a9e3b0d8ecfba9cc23a3614433ce0fa7ddcc80f2a8f10b222179a5a80d6
(1) 0x6ec1f2e7d126a74a1d2ff9e1c5d90b92378c725e506651ff8bb8616a5c724628
(2) 0xb4d7f7e82f61d81c95985771b8abf518f9328d019c36849d4214b5f995d13814
(3) 0x941536648ac10d5734973e94df413c17809d6cc5e24cd11e947e685acfbd12ae
(4) 0x5829cf333ef66b6bdd34950f096cb24e06ef041c5f63e577b4f3362309125863
(5) 0x8fc4bffe2b40b2b7db7fd937736c4575a0925511d7a0a2dfc3274e8c17b41d20
(6) 0xb6c10e2baaeba1fa4a8b73644db4f28f4bf0912cceb6e8959f73bb423c33bd84
(7) 0xfe8875acb38f684b2025d5472445b8e4745705a9e7adc9b0485a05df790df700
(8) 0xbdc6e0a69f2921a78e9af930111334a41d3fab44653c8de0775572c526feea2d
(9) 0x3e215c3d2a59626a669ed04ec1700f36c05c9b216e592f58bbfd3d8aa6ea25f9

```
Remember to copy the available accounts and their corresponding private keys seperately to keep reference.

Open another terminal and cd into this directory. Here, we will execute hardhat functions that interact with the Ganache test blockchain we ran previously.

To see a list of possible options and tasks, please run `npx hardhat --network localhost`

To run the existing testcases, please run `npx hardhat --network localhost test`

If you would like to run the tasks individually, please first configure the config.json file. You can set the contract names for the NFT Collection smart contract, NFT Marketplace smart contract, the collection name and symbol, the signatories for the marketplace, the number of signatures required for the multisignature scheme and the penalty amount (in percentage, upon 100).

Once this is done, you are ready to run the tasks. The order in which you should run would be:
1) `npx hardhat --network localhost compile`
    This compiles the smart contract code and pushes build info into the "artifacts" folder. This is required for our instantiation 
    of contracts when we call tasks later on.

2) `npx hardhat --network localhost deploy_collection`
    This deploys the NFT Collection smart contract into the blockchain. By default, this uses the first account provided by Ganache (index 0). 

    When the NFT Collection smart contract is deployed, the console would return a contract address. Please save this contract address under the "nftContractAddress" variable in mint_config.json.

3) `npx hardhat --network localhost mint`
    This mints NFTs into the NFT Collection smart contract. Please configure the minting configurations by modifying the mint_config json file before you run this command. 

    You can set the minter public key and private key, as well as the tokenURIs you want to mint for each NFT desired.

4) `npx hardhat --network localhost deploy_marketplace`
    This deploys the NFT Marketplace smart contract into the blockchain. By default, this uses the first account provided by Ganache (index 0). 

    When the NFT Marketplace smart contract is deployed, the console would return a contract address. Please save this contract address under the "marketplaceContractAddress" variable in mint_config.json.

5) `npx hardhat --network localhost approveMarketplace`
    This approves the Marketplace to act as an escrow for the NFT which the potential lister wants to list. Please ensure that the minterPublicKey and minterPrivateKey defined in mint_config.json is the correct account signer for the NFT listing approval. 
    The minterPublicKey and minterPrivateKey defined should be the owner of the NFT.

6) `npx hardhat --network localhost listNFT`
    This lists NFTs into the NFT Marketplace smart contract. Please ensure that the NFT to be listed has been previously approved by the approveMarketplace task. Please also configure the listing configurations by modifying the listing_config.json file before you run this command. 

    You can set the tokenID to be listed, the minimum bid price of the NFT (it should be greater than 100), the block number where the sale/auction starts and ends, the exercise period for the winning bidder to claim the NFT, the lister's public and private keys.

    The listerPublicKey and listerPrivateKey defined should be the owner of the NFT.

    The listNFT method emits an event on listeners which contain the listingID. You can see the listingID returned on Ganache.

7) `npx hardhat --network localhost bidNFT`
    This allows a bidder to bid for an NFT listing on the marketplace. Please configure the bidding configurations by modifying the bidding_config.json file before you run this command. 

    You can set the listingID of the NFT you want to bid for, the value you want to bid, the bidder's public and private keys.

    Please also ensure that the time of the bid is between the acceptable starting block number and ending block number, as defined by the listing, otherwise the task will fail.

8) `npx hardhat --network localhost claimNFT`
    This allows a bidder to attempt at claiming the NFT listing. If all conditions are met, the bidder would successfully claim the NFT
    listing. Please configure the claiming configurations by modifying the claim_config.json file before you run this command. 

    You can set the listingID of the NFT you want to claim, the claimant's public and private keys. Please ensure that the claimant's public and private keys correspond to that of the winning bidder, otherwise the task will fail.

    Please also ensure that the time of the claim is between the acceptable starting block number and ending block number, as defined by the listing's exercise period. This can be derived via adding the exercise period to the ending block number of the auction/sale. Otherwise, the task will fail.

9) `npx hardhat --network localhost proposeExpiry`
    This allows a signatory to propose expiry of an NFT listing which the winning bidder has not claimed during the exercise period.Please configure the proposal configurations by modifying the expiry_config.json file before you run this command. 

    You can set the listingID of the NFT you want to expire, the signatory's public and private keys. Please ensure that the signatory's public and private keys correspond to that of an actual signatory as defined in config.json.