// Set imports
const { parse } = require('@ethersproject/transactions');
const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { ethers } = require("hardhat")
const { nft_contract_name, marketplace_contract_name, collection_name, symbol, num_sigs } = require('../config.json');
const { tokenURIs } = require('../mint_config.json');

describe("Smart Contract Deployment Tests", function () {

    // Instantiate variables
    let collection;
    let marketplace;
    let minters;
    let signatories;
    let penalty_percent;

    console.log("Beginning Tests\n")
    // Retrieves signers before test execution
    this.beforeEach(async function () {
        [marketplace_owner, minter1, minter2, minter3, signatory1, signatory2, signatory3, signatory4, buyer1, buyer2] = await ethers.getSigners();

    })

    it("NFT Collection deployed successfully", async function () {

        // Retrieves Collection ABI and deploys it to network
        const Collection = await ethers.getContractFactory(nft_contract_name);
        collection = await Collection.deploy(collection_name, symbol);
        let actual_collection_name = await collection.name();
        let expected_collection_name = collection_name
        expect(actual_collection_name).to.equal(expected_collection_name);
        console.log("Passed NFT Collection deployment test:  Expected collection name: " + expected_collection_name + ", Actual collection name: " + actual_collection_name)
    })

    it("NFT Marketplace deployed successfully", async function () {
        signatories = [signatory1, signatory2, signatory3, signatory4];
        let signatory_addresses = [];
        signatories.forEach((signatory) => {
            signatory_addresses.push(signatory.address)
        });

        penalty_percent = 10;
        const Marketplace = await ethers.getContractFactory(marketplace_contract_name);
        marketplace = await Marketplace.deploy(signatory_addresses, num_sigs, penalty_percent);

        let actual_marketplace_owner = await marketplace.marketplace_owner()
        let expected_marketplace_owner = marketplace_owner.address
        expect(actual_marketplace_owner).to.equal(expected_marketplace_owner);
        console.log("Passed NFT Marketplace deployment test - Expected marketplace owner: " + expected_marketplace_owner + ", Actual marketplace owner: " + actual_marketplace_owner)
    })

    it("NFTs are minted successfully", async function () {

        minters = [minter1, minter2, minter3];

        for (const minter of minters) {
            let actual_premint_balance = await collection.balanceOf(minter.address)
            let expected_premint_balance = 0
            expect(actual_premint_balance).to.equal(expected_premint_balance);
            console.log("Passed NFT premint balance test for minter " + minter.address + " - Expected premint balance: " + expected_premint_balance + ", Actual premint balance: " + actual_premint_balance)
        }

        var tokenID = 0;

        for (i = 0; i < tokenURIs.length; i++) {
            let uri = tokenURIs[i]
            let minter = minters[i]
            await collection.connect(minter).mint(uri)
            let actual_postmint_balance = await collection.balanceOf(minter.address)
            let expected_postmint_balance = 1
            let actual_nft_uri = await collection.tokenURI(tokenID)
            let expected_nft_uri = uri

            expect(actual_postmint_balance).to.equal(expected_postmint_balance);
            console.log("Passed NFT premint balance test for tokenID " + tokenID + "- Expected postmint balance: " + expected_postmint_balance + ", Actual postmint balance: " + actual_postmint_balance)
            expect(actual_nft_uri).to.equal(expected_nft_uri);
            console.log("Passed NFT URI setting test for tokenID " + tokenID + " - Expected URI: " + expected_nft_uri + ", Actual URI: " + actual_nft_uri)
            tokenID++;
        }

    })

    it("Minters can list NFT on Marketplace", async function () {
        minters = [minter1, minter2, minter3];
        for (i = 0; i < minters.length; i++) {

            let minter = minters[i]
            let currentBlockNumber = await ethers.provider.getBlockNumber();
            let startBlock = currentBlockNumber + 10;
            let endBlock = currentBlockNumber + 20;

            await collection.connect(minter).approve(marketplace.address, i)
            let nft_owner = await collection.ownerOf(i);
            expect(nft_owner).to.equal(minter.address);
            console.log("Passed pre-escrow ownership test for tokenID " + i + " - Expected owner: " + minter.address + ", Actual owner: " + nft_owner)

            let tx = await marketplace.connect(minter).listNFT(collection.address, i, 100, startBlock, endBlock, 20);
            let receipt = await tx.wait();
            let listingID = parseInt(receipt.events?.filter((x) => { return x.event == "NFTListed" })[0].args.listingID._hex, 16);

            nft_owner = await collection.ownerOf(i);
            expect(nft_owner).to.equal(marketplace.address);
            console.log("Passed post-escrow ownership test for tokenID " + i + " - Expected owner: " + marketplace.address + ", Actual owner: " + nft_owner)

            let listing = await marketplace.listings(listingID)
            expect(listing.owner).to.equal(minter.address);
            console.log("Passed marketplace listing generation test for listingID " + i + " - Expected owner: " + minter.address + ", Actual owner: " + listing.owner)

        }
    })

    it("Buyers can buy from Marketplace", async function () {
        buyers = [buyer1, buyer2];
        signatories = [signatory1, signatory2, signatory3, signatory4];

        /*  Buyer 1 wants to bid for token 1 & 2
            Case 0: Buyer 1 is too early for bidding
            Case 1: Buyer 1 bids below the minimum price
            Case 2: Buyer 1 successfully bids for Token 1
            Case 3: Buyer 1 successfully bids for Token 2
        */

        // Buyer 1 wants to bid tokenID 1, however he is too early. He bids his standard amount, 1000 wei

        let buyer1_case0_revert = "Auction has not started yet";
        let buyer1_case1_revert = "Bid amount is less than Listing's minimum bid";
        let buyer2_case0_revert = "Bid amount is less than current highest bid"
        let buyer2_case2_revert = "Auction has ended";
        let buyer1_case4_revert = "Claimant is not winning bidder";
        let buyer1_case5_revert = "Exercise Period is over";

        const buyer1_bid = 1000;
        const buyer1_case0 = marketplace.connect(buyer1).bid(1, { value: buyer1_bid })
        await expect(buyer1_case0).to.be.revertedWith(buyer1_case0_revert)
        console.log("Passed Buyer 1 Case 0 (Bid too early): Reverted with " + buyer1_case0_revert)

        // Buyer 1 waits until auction is opened, and submits a bid which is below min price
        for (i = 0; i < 10; i++) {
            await ethers.provider.send("evm_mine");
        }

        const buyer1_case1 = marketplace.connect(buyer1).bid(0, { value: 5 })
        await expect(buyer1_case1).to.be.revertedWith(buyer1_case1_revert)
        console.log("Passed Buyer 1 Case 1 (Bid less than floor): Reverted with " + buyer1_case1_revert)

        // Buyer 1 Case 2
        await marketplace.connect(buyer1).bid(1, { value: buyer1_bid })

        let listing1 = await marketplace.listings(1);
        expect(listing1.highest_bidder).to.equal(buyer1.address);

        console.log("Passed Buyer 1 Case 2 (Successful bid, Token 1): - Expected highest bidder: " + buyer1.address + ", Actual highest bidder: " + listing1.highest_bidder)

        // Buyer 1 Case 3
        await marketplace.connect(buyer1).bid(2, { value: buyer1_bid })

        let listing2 = await marketplace.listings(2);
        expect(listing2.highest_bidder).to.equal(buyer1.address);

        console.log("Passed Buyer 1 Case 3 (Successful bid, Token 2): - Expected highest bidder: " + buyer1.address + ", Actual highest bidder: " + listing2.highest_bidder)

        /*  Buyer 2 wants to bid for all 3 tokens
            Case 0: Buyer 2 bids lower than Buyer 1 for Token 2
            Case 1: Buyer 2 successfullly bids for token 2, overtaking Buyer 1
            Case 2: Buyer 2 submits a bid after the auction
        */

        // // Buyer 2 Case 0
        const buyer2_case0 = marketplace.connect(buyer2).bid(2, { value: 500 })
        await expect(buyer2_case0).to.be.revertedWith(buyer2_case0_revert)
        console.log("Passed Buyer 2 Case 0 (Bid lower than highest bid): Reverted with " + buyer2_case0_revert)

        // Buyer 2 Case 1

        // Current highest bid by Buyer 1 for token 2
        let current_highest_bid = listing2.highest_bid;
        console.log("Current highest bid " + current_highest_bid);

        let buyer1_balance_before = await ethers.provider.getBalance(buyer1.address)

        await marketplace.connect(buyer2).bid(2, { value: 1500 })

        listing2 = await marketplace.listings(2);
        expect(listing2.highest_bidder).to.equal(buyer2.address)
        console.log("Passed Buyer 2 Case 1 (New highest bid) - Expected highest bidder: " + buyer2.address + ", Actual highest bidder: " + listing2.highest_bidder)

        let buyer1_balance_after = await ethers.provider.getBalance(buyer1.address)

        let buyer1_refund = buyer1_balance_after.sub(buyer1_balance_before).toString();
        console.log(buyer1_refund)

        expect(buyer1_refund).to.equal(current_highest_bid);
        console.log("Passed Buyer 2 Case 1 (Refund to outbidded) - Expected refund: " + current_highest_bid + ", Actual refund: " + buyer1_refund);


        //  Buyer 2 Case 2
        for (i = 0; i < 10; i++) {
            await ethers.provider.send("evm_mine");
        }

        const buyer2_case2 = marketplace.connect(buyer2).bid(2, { value: 1600 })
        await expect(buyer2_case2).to.be.revertedWith(buyer2_case2_revert)
        console.log("Passed Buyer 2 Case 2 (Bid after auction): Reverted with " + buyer2_case2_revert)

        /* 
        Buyer 1 and 2 now wants to settle the assets.

        Buyer 1 Case 4: Buyer 1 tries to claim Token 2, which was won by Buyer 2
        Buyer 2 Case 3: Buyer 2 successfully exercises the purchase of the NFT listing
        Buyer 1 Case 5: Buyer 1 is unable to claim TokenID 0 as the exercise period is over. Signatories expire his bid, and he gets penalised.
        */

        // Buyer 1 Case 4
        const buyer1_case4 = marketplace.connect(buyer1).claim(2)
        await expect(buyer1_case4).to.be.revertedWith(buyer1_case4_revert)
        console.log("Passed Buyer 1 Case 4 (Claim unwon token): Reverted with " + buyer1_case4_revert)

        // Buyer 2 Case 3
        await marketplace.connect(buyer2).claim(2)
        token2_owner = await collection.ownerOf(2);
        expect(token2_owner).to.equal(buyer2.address)
        console.log("Passed Buyer 2 Case 3 (Exercise Asset Claim): - Expected new owner: " + buyer2.address + ", Actual refund: " + token2_owner)

        // Buyer 1 Case 5
        for (i = 0; i < 20; i++) {
            await ethers.provider.send("evm_mine");
        }

        const buyer1_case5 = marketplace.connect(buyer1).claim(1)
        await expect(buyer1_case5).to.be.revertedWith(buyer1_case5_revert);
        console.log("Passed Buyer 1 Case 5 (Exercise Period elapsed): Reverted with " + buyer1_case5_revert)

        /* Preparing for expiration test case by retrieving Buyer, Seller and Marketplace owner balances, before and after
            Start by retrieving the listing details
        */

        let expired_listing = await marketplace.listings(1);
        let expired_highest_bid_hex = expired_listing.highest_bid._hex
        let expired_highest_bid = parseInt(expired_highest_bid_hex, 16)
        let seller = expired_listing.owner;

        let marketplace_before_escrow = await ethers.provider.getBalance(marketplace.address);

        // Retrieving Before Balance

        // Buyer before balances
        let buyer1_balance_before_2 = await ethers.provider.getBalance(buyer1.address)

        // Seller before balances
        let seller_balance_before = await ethers.provider.getBalance(seller)

        // Marketplace owner before balance
        let marketplace_balance_before = await ethers.provider.getBalance(marketplace_owner.address)

        // At this point, Signatories propose to expire Listing 1
        for (i = 0; i < signatories.length - 1; i++) { //-1 Because we only need 3 out of 4 signatories
            let signatory = signatories[i];
            await marketplace.connect(signatory).proposeExpiration(1)
        }

        // Listing has now been expired, retrieving after balances

        let marketplace_after_escrow = await ethers.provider.getBalance(marketplace.address);
        let after_escrow_balance = marketplace_before_escrow.sub(expired_highest_bid)

        expect(marketplace_after_escrow).to.equal(after_escrow_balance)
        console.log("Passed Buyer 1 Case 5 (Refunds originate from Marketplace Escrow: - Expected balance: " + after_escrow_balance + ", Actual balance: " + marketplace_after_escrow)

        // Buyer after balances  
        let buyer1_balance_after_2 = await ethers.provider.getBalance(buyer1.address)


        // Seller after balances
        let seller_balance_after = await ethers.provider.getBalance(seller)

        // Marketplace owner after balance
        let marketplace_balance_after = await ethers.provider.getBalance(marketplace_owner.address)

        let buyer1_penalty = buyer1_balance_after_2.sub(buyer1_balance_before_2).toNumber();
        let refund_amount = expired_highest_bid * penalty_percent / 100;
        let seller_refund = seller_balance_after.sub(seller_balance_before).toNumber();

        let marketplace_refund = marketplace_balance_after.sub(marketplace_balance_before).toNumber();

        let expected_penalty = expired_highest_bid * (100 - 2 * penalty_percent) / 100
        expect(buyer1_penalty).to.equal(expected_penalty)
        console.log("Passed Buyer 1 Case 5 (Buyer Refund " + (100 - 2 * penalty_percent) + "% of bid due to penalty): - Expected refund: " + expected_penalty + ", Actual refund: " + buyer1_penalty)

        expect(seller_refund).to.equal(refund_amount)
        console.log("Passed Buyer 1 Case 5 (Seller Refund " + penalty_percent + "% of bid due to penalty): - Expected refund: " + refund_amount + ", Actual refund: " + seller_refund)

        expect(marketplace_refund).to.equal(refund_amount);
        console.log("Passed Buyer 1 Case 5 (Marketplace Owner Refund " + penalty_percent + "% of bid due to penalty): - Expected refund: " + refund_amount + ", Actual refund: " + marketplace_refund)

        // Test if NFT is returned from Escrow
        let refunded_nft_owner = await collection.ownerOf(1);
        expect(refunded_nft_owner).to.equal(seller);
        console.log("Passed Buyer 1 Case 5 (NFT Refund): - Expected owner: " + seller + ", Actual owner: " + refunded_nft_owner)

    })

})