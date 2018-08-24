pragma solidity^0.4.24;
import "./CoolWallet.sol";

contract CoolWalletManager{
    mapping(address => bool) internal unlockedAccounts;
    mapping(address => bool) public freezeVotes;
    mapping(address => bool) public abandonVotes;
    address[] public accounts;
    bool public frozen = false;
    bool public abandoned = false;
    uint required = accounts.length/2;
    // The following variable is to prevent malicious actors from simply forming more than 0% of accounts at early stages and voting for freezing/abandoning.
    // Each wallet will get to vote on the minimum number of wallets made before it is safe to hand over control
    // of freezing and abandoning wallets to the people. 
    // The vote for the minimum number will be averaged out with every new wallet
    // The number is set high to counteract malicious votes on the minimum number
    uint public CommunityVotingMinNumber = 1000;

    event WalletCreated(address walletAddress);
    
    constructor() public{
    }
    
    modifier normalActivity(){
        require(frozen == false && abandoned == false);
        _;
    }
    
    modifier unlockedAccount(){
        require(unlockedAccounts[tx.origin] == true);
        _;
    }
    
    modifier multiSigFreeze(){
        uint voteNumber = 0;
        for (uint i = 0; i<accounts.length;i++){
            if (freezeVotes[accounts[i]] == true){
                voteNumber++;
            }
        }
        require(voteNumber >= 1000);
        require(voteNumber >= CommunityVotingMinNumber);
        require(voteNumber >= required);
        _;
    }

    modifier multiSigUnfreeze(){
        uint voteNumber = 0;
        for (uint i = 0; i<accounts.length;i++){
            if (freezeVotes[accounts[i]] == false){
                voteNumber++;
            }
        }
        require(voteNumber >= 1000);
        require(voteNumber >= CommunityVotingMinNumber);
        require(voteNumber >= required);
        _;
    }
    
    modifier multiSigAbandon(){
        uint voteNumber = 0;
        for (uint i = 0; i<accounts.length;i++){
            if (abandonVotes[accounts[i]] == true){
                voteNumber++;
            }
        }
        require(voteNumber >= 1000);
        require(voteNumber >= CommunityVotingMinNumber);
        require(voteNumber >= required);
        _;
    }
    
    function createWallet() public payable normalActivity{
        require(unlockedAccounts[tx.origin] == false);
        unlockedAccounts[tx.origin] = true;
        accounts.push(tx.origin);
        CoolWallet newWallet = new CoolWallet();
        emit WalletCreated(address(newWallet));
        newWallet.transfer(msg.value);
    }
    
    function freeze() external multiSigFreeze{
        frozen = true;
        for (uint i =0; i<accounts.length;i++){
            CoolWallet toFreeze = CoolWallet(accounts[i]);
            toFreeze.freezeWallet();
        }
    }

    function unfreeze() external multiSigUnfreeze{
        frozen = false;
        for (uint i =0; i<accounts.length;i++){
            CoolWallet toUnfreeze = CoolWallet(accounts[i]);
            toUnfreeze.unfreezeWallet();
        }
    }
    
    function abandon() external multiSigAbandon{
        abandoned = true;
        for (uint i =0; i<accounts.length;i++){
            CoolWallet toAbandon = CoolWallet(accounts[i]);
            toAbandon.abandonWallet();
        }
    }
    
    function communityVote(uint minNumberToDecentralize) unlockedAccount external{
        CommunityVotingMinNumber += minNumberToDecentralize;
        CommunityVotingMinNumber /= accounts.length;
    }
    
    function votingForFreeze(bool toFreeze) unlockedAccount external {
        freezeVotes[tx.origin] = toFreeze;
    }
    
    function votingForAbandon(bool toAbandon) unlockedAccount external {
        abandonVotes[tx.origin] = toAbandon;
    }
    
    function() public payable{    
        //allow contract to receive money
    }
}