//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11; 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract NFT_Marketplace is ERC721Holder{

    // Marketplace listings are stored as struct for gas efficiency, as opposed to storing multiple mappings and arrays
    struct Listing{ 

        /*  
            Variables are grouped together to save gas as Solidity utilises tight variable packing to minimise storage slots
            (See https://docs.soliditylang.org/en/v0.8.10/internals/layout_in_storage.html)
        */
        address contract_address;
        address highest_bidder;
        address payable owner;
        uint token_id;

        /*  
            Min bid is instantiated as 100. This is because we use a divisor of 100 when calculating the penalty percentage, hence
            we set the min bid as 100 to prevent decimal point errors.
        */
        uint min_bid;
        uint highest_bid;

        /*
            Block timestamps are vulnerable to transaction ordering vulnerabilities since the timestamps are defined by the miners.
            (See https://consensys.github.io/smart-contract-best-practices/known_attacks/#timestamp-dependence)
            Therefore, we use block numbers as the canonical start and end for each listing epoch.

            However, it is important to recognise that this design is particular to the Ethereum blockchain. In other EVM blockchains,
            such as Avalanche, it is a best practice to use block.timestamp given their dynamic block production.
        */
        uint sale_start_block_number;
        uint sale_end_block_number; 

        /*
        Given the nature of smart contracts, settlement of purchase is requires seperate interaction from the bidding of the asset. 
        Therefore it is important that we have a mechanism to prevent non-settled bids, which can be used to arbitrarily lock up
        assets (NFTs) on the marketplace.

        An exercise period is therefore defined to allow a certain period of time where the winning bidder can claim the asset. 
        This exercise period is defined by the seller when uploading a listing. Should the exercise period be missed, the settlement
        is forfeited and the winning bidder receives a penalty (defined by the market place) on the refund. The penalty amount
        is disbursed to the seller and the marketplace owner as compensation for the opportunity cost of listing.
        */
        uint exercise_period;

        // Claimed is used to prevent double-spending of claimed NFTs.
        bool claimed;
    }

    /*  
        Variables are grouped together to save gas as Solidity utilises tight variable packing to minimise storage slots
        (See https://docs.soliditylang.org/en/v0.8.10/internals/layout_in_storage.html)
    */
    address payable public marketplace_owner;

    /*
        Centralisation of contracts has been exploited multiple times due to poor key management or other vulnerabilities due to the
        single source of failure. We use a multisignature pattern for approving transactions executed by the marketplace to mitigate
        these flaws. 

        The marketplace owner defines these signatories, which may or may not include the marketplace owner himself.

        If the business use-case of the platform requires a centralised entity, it can be set as such.
    */
    mapping(address => bool) public signatories;
    mapping (uint => Listing) public listings;

    // Expiration Agreements track the number of signatures for each expiration proposal
    mapping(uint => address[]) expirationAgreements;

    /* 
        In this version of the contract, the listing index is defined sequentially. This also serves to show the number of listings 
        in the platform.
    */ 
    uint public listing_index;

    // The number of required signatures from signatories to execute a marketplace transaction (m out of n)
    uint required_signatures;

    /*
        Booleans are more expensive than uint256 or any type that takes up a full word because each write operation emits
        an extra SLOAD to first read the slot's contents, replace the bits taken up by the boolean, and then write back. 
        This is the compiler's defense against contract upgrades and pointer aliasing, and it cannot be disabled.

        The values being non-zero value makes deployment a bit more expensive, but in exchange the refund on every call will 
        be lower in amount. Since refunds are capped to a percentage of the total transaction's gas, it is best to keep them
        low in cases like this one, to increase the likelihood of the full refund coming into effect.
    */
    uint private constant NOT_ENTERED = 1;
    uint private constant ENTERED = 2;
    uint private reentrant_status;

    /* 
        Defines the penalty percentage. The penalty is paid seperately to the seller and the marketplace owner.
        E.g if the penalty is 10%, the seller and marketplace owner receives 10% each, and the winning bidder receives 80%.
    */ 
    uint public penalty;

    // Sets some utility modifiers 
    modifier isSignatory(){
        require(signatories[msg.sender] == true, "Caller is not a Signatory");
        _;
    }

    modifier nonReentrant() {
        require(reentrant_status != ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        reentrant_status = ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200)
        reentrant_status = NOT_ENTERED;
    }

    // Sets events to be emitted
    event NFTListed(uint listingID);

    constructor(address[] memory _signatories, uint _required_signatures,uint _penalty){
        // Set up multisignature scheme
        uint num_signatories = _signatories.length;

        // Call require early for early gas refund
        require(num_signatories >= _required_signatures, "Number of signatories is less than required signatures");
        required_signatures = _required_signatures; 

        // Initialises signatories
        for (uint i = 0;i<num_signatories;i++){
            signatories[_signatories[i]] = true;
        }

        // Setting marketplace owner as a payable address for future implementation of royalties
        marketplace_owner = payable(msg.sender);
        listing_index = 0; //New Marketplace has no listings yet
        penalty = _penalty; //Out of 100, in %
        
        // Initialises reentrancy guard
        reentrant_status = NOT_ENTERED;
    }

    /* 
        Allow users to list their NFTs. The method creates the listing before escrowing the NFT in the marketplace.
        The escrow ensures the lister is the owner of the NFT, and the NFT is custodised in this smart contract.
        We cannot adopt a non-custodial method of auction as the owner can sell the NFT elsewhere, rendering the auction useless.

        As this method escrows the NFT to the marketplace, the code implements the Checks Effects Interaction design pattern to 
        prevent accidental reentrancy. (See https://docs.soliditylang.org/en/v0.8.11/security-considerations.html)

        It takes in 6 parameters: The NFT Contract address, the token ID, the minimum bid price, the sale start time and end time, and the exercise period
        It returns the listing ID
    */

    function listNFT(address contractAddress, uint tokenID,uint minBid,uint saleStartBlockNumber,uint saleEndBlockNumber, uint exercisePeriod) public returns (uint listingID){
        // Call require early for early gas refund and implements Check Effect Interaction design pattern
        require(saleStartBlockNumber < saleEndBlockNumber, "Sale start is later than end");
        require(minBid >= 100,"Minimum bid needs to be at least 100");

        // Creates a listing object with default and Seller defined parameters
        listings[listing_index] = Listing(
            contractAddress,
            address(0), //To prevent anyone from claiming when it is freshly listed
            payable(msg.sender),
            tokenID,
            minBid,
            0,
            saleStartBlockNumber,
            saleEndBlockNumber,
            exercisePeriod,
            false
        );

        emit NFTListed(listing_index);

        // Updates the listing index as best practice against reentrancy
        listing_index+=1;

        // Escrows the NFT to the marketplace
        IERC721(contractAddress).safeTransferFrom(msg.sender, address(this), tokenID);

        return listing_index;
    }

    /* 
        Allow users to buy NFTs by placing bids. The funds are escrowed in the Marketplace to ensure trustless settlement of purchase.
        This contract uses the withdrawal design pattern to prevent re-entrancy attacks similar to the DAO Hack.
        As this method executes refunds, it has a re-entrancy guard to prevent potential re-entrancy exploits

        As this method executes value transfers, the code implements the Checks Effects Interaction design pattern to 
        prevent accidental reentrancy. (See https://docs.soliditylang.org/en/v0.8.11/security-considerations.html)

        It takes in 1 parameter: The listing ID, and updates the state of the marketplace listing if there is an outbid
    */
    function bid(uint listingID) public payable nonReentrant{
        Listing memory listing = listings[listingID];

        // Implement Checks Effects Interaction design pattern
        require(block.number >= listing.sale_start_block_number,"Auction has not started yet");
        require(block.number <= listing.sale_end_block_number,"Auction has ended");
        require(msg.value > listing.min_bid,"Bid amount is less than Listing's minimum bid");
        require(msg.value > listing.highest_bid,"Bid amount is less than current highest bid");

        /*
            Initialises refunding address as payable only here to reduce the number of external payment vectors.
            This reduces the number of attack vectors for external payment exploits
        */
        address payable toRefund = payable(listing.highest_bidder);
        uint refundValue = listing.highest_bid;
        listing.highest_bidder = msg.sender;
        listing.highest_bid = msg.value;

        // Updates the listing with the new state
        listings[listingID] = listing;

        // Execute refund to previous highest_bidder
        toRefund.transfer(refundValue);
    }

    /*  
        Allows the successful bidder to settle the asset withdrawal after the auction ends. 
        This contract uses the withdrawal design pattern to prevent re-entrancy attacks similar to the DAO Hack.
        As this method executes value transfers, it has a re-entrancy guard to prevent potential re-entrancy exploits

        As this method executes value transfers, the code implements the Checks Effects Interaction design pattern to 
        prevent accidental reentrancy. (See https://docs.soliditylang.org/en/v0.8.11/security-considerations.html)

        It takes in 1 parameter: The listing ID, executes transfer of the NFT to the winning bidder, and the bid amount to the seller
    */
    function claim(uint listingID) public nonReentrant{
        Listing memory listing = listings[listingID];

        // Implement Checks Effects Interaction design pattern
        require(msg.sender == listing.highest_bidder,"Claimant is not winning bidder");
        require(block.number > listing.sale_end_block_number,"Auction has not ended");
        require(block.number < listing.sale_end_block_number + listing.exercise_period,"Exercise Period is over");
        require(listing.claimed == false);

        listing.claimed = true; // Prevents double-spending claims
        listings[listingID] = listing; // updates listing with the new state
        
        IERC721(listing.contract_address).safeTransferFrom(address(this), listing.highest_bidder,listing.token_id);
        listing.owner.transfer(listing.highest_bid);
    }

    /*  
        Given the nature of smart contracts, settlement of purchase is requires seperate interaction from the bidding of the asset. 
        Therefore it is important that we have a mechanism to prevent non-settled bids, which can be used to arbitrarily lock up
        assets (NFTs) on the marketplace.

        An expiration policy allows recourse to locked-up assets for the seller. A penalty would be imposed on the buyer who exceeded
        the exercise period, and the penalty would be disseminated to the seller and marketplace owner as compensation for opportunity
        cost of listing.

        The seller is not designated to execute this expiration as this could lead sellers to set arbitrarily short exercise periods,
        then expiring auctions as soon as possible to retrieve the asset and the penalty compensation. This could be a problem
        with EVM chains with short block times, such as Polygon (approx 2 seconds, see https://polygonscan.com/chart/blocktime)

        The marketplace owner and/or the marketplace itself should not execute the expiration proposals since this leads to centralisation
        risks (single source of failure). Therefore, we decentralise the execution of this function to multiple approved signatories.

        It takes in 1 parameter: The listing ID, and executes transfer of the NFT to the winning bidder, and the bid amount to the seller
    */
    function proposeExpiration(uint listingID) public isSignatory{
        Listing memory listing = listings[listingID];
        if (isExpired(listing)){
            /*
                If number of signatures prior to current signing is one less than the required, this signing would reach the quorum
                needed in this execution. Therefore, we execute the expireClaim() function.
            */
            if (expirationAgreements[listingID].length == required_signatures - 1){ 
                expireClaim(listingID);
            }
            else{
                // If quorum has not been met, update the expiration agreements with the latest signature
                expirationAgreements[listingID].push(msg.sender);
            }
        }
        else{
            // Returns unused gas if execution fails
            revert();
        }

    }

    /*  
        Allows claims to be expired upon reaching a quorum of signatures. This method is private by design,
        to reduce the ability of malicious actors from attempting to execute value transfers.

        This contract uses the withdrawal design pattern to prevent re-entrancy attacks similar to the DAO Hack.
        As this method executes value transfers, it has a re-entrancy guard to prevent potential re-entrancy exploits

        As this method executes value transfers, the code implements the Checks Effects Interaction design pattern to 
        prevent accidental reentrancy. (See https://docs.soliditylang.org/en/v0.8.11/security-considerations.html)

        It takes in 1 parameter: The listing ID, and executes:
            1) The penalty compensation to the seller and marketplace owner
            2) The penalised refund to the winning bidder
            3) The return of the NFT to the seller
    */
    function expireClaim(uint listingID) private nonReentrant{
        Listing memory listing = listings[listingID];
        if(isExpired(listing)){
            listing.claimed = true;

            /*  Penalty scheme: pays x% of escrowed amount to owner, x% to marketplace_owner, and refunds remainder to bidder
                Penalty scheme is required to disincentivise fraudulent bids that lock up listings arbitrarily, and to compensate
                seller and marketplace for their time and effort
            */
            uint penaltyAmount = (listing.highest_bid*penalty)/100;
            uint refundAmount = listing.highest_bid - (2*penaltyAmount);

            // returns NFT to original owner
            IERC721(listing.contract_address).safeTransferFrom(address(this), listing.owner,listing.token_id);

            //Executes penalties and refund
            listing.owner.transfer(penaltyAmount);
            marketplace_owner.transfer(penaltyAmount);

            /*
                Initialises refunding address as payable only here to reduce the number of external payment vectors.
                This reduces the number of attack vectors for external payment exploits
            */
            address payable toRefund = payable(listing.highest_bidder);

            toRefund.transfer(refundAmount); //refunds penalised amount to winning bidder

        }
        else{
            // Returns unused gas if execution fails
            revert();
        }
 
    }

    //Utility methods
    function isExpired(Listing memory listing) public view returns (bool hasExpired){
        require(listing.claimed == false, "Listing has been claimed");
        require(block.number > listing.sale_end_block_number + listing.exercise_period,"Exercise period still ongoing");
        return true;
    }
}