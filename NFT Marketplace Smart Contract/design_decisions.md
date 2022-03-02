The project is to design a very basic NFT marketplace smart contract with the following restrictions:
1. Using any existing libraries for simple tasks (for example openzeppelin libraries for Ethereum) is not recommended. This is to reduce third-party dependencies.
2. The project is designed to first be run in an air-gapped environment, and the code needs to be extensible towards public mainnet deployment.
3. The marketplace smart contract should allow any user to list an ERC721 (or the platform’s own  implementation if any) NFT for sale  
4. The seller can specify the sale end time and the minimum bid price for the token. Potential buyers can bid for the NFT using fungible tokens (the candidate can choose to implement using ERC20/Security Token/Ether)  
5. The bid value should be greater than the previous bid (or minimum bid value if it’s the first bid).  For new bids, the previous bidder will get a refund.  
6. Once the sale is ended, the token can be claimed by the highest bidder and the bid amount will  be transferred to the seller.  

To approach this project, we require two smart contracts: An NFT (ERC721) Collection smart contract that mints various NFTs, and a Marketplace smart contract that lists certain NFTs. Alongside Restriction 1 on not using existing libraries for simple tasks, the smart contracts in this project only use the ERC721 and ERC721Holder libraries.

The NFT Collection smart contract is designed to be as minimalist as possible, with only minimal implementation of interface functions.

Given that the NFT Marketplace was required to function as an escrow of funds (as required by Restriction 4 which states that previous bidders would get a refund upon being outbidded), the NFT Marketplace was designed to be as secure as possible. The following measures were taken:
1)  Decentralised Approvals
    Centralised approvals for function execution has historically acted as a single point of failure against malicious actors. Since the Marketplace escrows funds, where the Marketplace has to execute a transaction containing transfers of value, such transactions require multisignature approvals to execute. 

2)  Reentrancy Guards
    Reentrancy attacks, made famous by the DAO Hack, have the ability to drain the majority, if not all, of the funds in a smart contract to a malicious actor. In order to prevent such attacks, three methods were utilised:
        i) A nonReentrant modifier is used to prevent race conditions and reentrancy by locking the recursive execution of methods declared nonReentrant.
        ii) The Checks Effects Interactions design pattern is used to update variables before recursive execution and prevent recursive execution as a result of unlimited access via outdated variables.
        iii) Addresses are only declared payable as required, to prevent flow of funds to malicious actors.

3)  Timestamp Independency
    Timestamp dependency in the form of using block.timestamp is a known vulnerability to transaction ordering exploits in the Ethereum blockchain. Timestamp dependency in the form of using centralised oracles has known concerns over the centralisation vulnerabilities of the oracle, such as server downtime. Timestamp dependency on decentralised oracles, such as Chainlink, is not implementable in this project given the expectation to deploy this in an airgapped environment.

    Therefore, the NFT Marketplace smart contract uses block numbers to determine the sale/auction start and end times. 

4)  Exercise period
    Whilst the project requirements did not require the implementation of an exercise period after the auction has ended, I implemented an exercise period to prevent Denial-of-Service attacks. For example, a bidder could make an arbitrarily high bid (provided the bidder has sufficient funds), win the auction/sale but refuse to claim the NFT. Without an exercise period, this would result in a Denial-of-Service style attack, where the seller has no recourse to the listed NFT.

    A penalty is implemented on bidders who won but do not claim the asset to disincentivise such actions on the marketplace. Furthermore, decentralised approvals allows us to offer recourse to the seller by refunding the NFT to the seller if the penalty is implemented.

Traditional smart contract optimisation techniques were used in the design of the NFT Marketplace smart contract, such as tight variable packing and usage of structs/uints over mappings/booleans. This is elaborated in greater detail as commented in the NFT Marketplace smart contract.

Future enhancements to this project solution can include:
1) Usage of Gnosis Safe Multisig as conduit for decentralised approval  
2) Usage of Chainlink VRF for generation of tokenIDs
3) Usage of Chainlink Timestamp oracles for usage of timestamp for auction/sale start and end (It is more practical than using block numbers)
4) Usage of other OpenZeppelin libraries to enhace security i.e. SafeMath
5) Decentralised approvals for inclusion/ejection of signatories in multisignature scheme
