pragma solidity^0.4.24;
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract CoolWalletManager{
    mapping(address => bool) internal unlockedAccounts;
    mapping(address => bool) public freezeVotes;
    mapping(address => bool) public abandonVotes;
    address[] public accounts;
    address owner;
    bool public frozen = false;
    bool public abandoned = false;
    uint required = accounts.length/5;
    // The following variable is to prevent malicious actors from simply forming more than 30% of accounts at early stages and voting for freezing/abandoning.
    // Each wallet will get to vote on the minimum number of wallets made before it is safe to hand over control
    // of freezing and abandoning wallets to the people. 
    // The vote for the minimum number will be averaged out with every new wallet
    // The number is set high to counteract malicious votes on the minimum number
    uint public CommunityVotingMinNumber = 1000;
    
    constructor() public{
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
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
        require(voteNumber >= CommunityVotingMinNumber);
        require(voteNumber >= required);
        _;
    }
    
    function createWallet(int _minNumToDecentralize) public payable normalActivity{
        require(_minNumToDecentralize >= 0);
        require(unlockedAccounts[tx.origin] == false);
        unlockedAccounts[tx.origin] = true;
        accounts.push(tx.origin);
        CoolWallet newWallet = (new CoolWallet)(_minNumToDecentralize);
        newWallet.transfer(msg.value);
    }
    
    function freeze() onlyOwner multiSigFreeze public{
        frozen = true;
        for (uint i =0; i<accounts.length;i++){
            CoolWallet toFreeze = CoolWallet(accounts[i]);
            toFreeze.freezeWallet();
        }
    }
    
    function abandon() onlyOwner multiSigAbandon public{
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

contract CoolWallet is usingOraclize{
    /*
    The purpose of this app is simply to allow mass sending of a predetermined amount of Ether to multiple addresses. It functions mostly as a wallet.
    The app comes with a few functionalities:
        - Set a daily limit
        - Show the existing balance of the wallet
        - Accept payments to the wallet
        - Send to multiple addresses
        - Live Exchange rates updated per minute
        - Automatic live conversion from USD to Ether and sending (Useful if you owe money in USD and need to pay in Ether)
    You can use it with Remix browser: https://remix.ethereum.org
    */
    
    using SafeMath for uint;
    using strings for *;
    
    string public ETHUSD;
    address public owner;
    address manager;
    uint public dailyLimit;
    uint dayStart;
    uint dailySum = 0;
    uint exchangeRateFullDecimal;
    bool frozen;
    
    event newOraclizeQuery(string description);
    event updatedPrice(string price);
    
    constructor(int _minNumberToDecentralize) public payable{
        owner = tx.origin;
        manager = msg.sender;
        CoolWalletManager walletManager = CoolWalletManager(msg.sender);
        uint communityVoteNumber = uint(_minNumberToDecentralize);
        walletManager.communityVote(communityVoteNumber);
        dayStart = now;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update();
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    modifier enoughBalance(address[] recipients, uint256 value){
        uint outgoingValue = recipients.length.mul(value);
        require(outgoingValue <= balance());
        _;
    }
    
    modifier underDailyLimit(address[] recipients, uint256 value){
        require(dailySum <= dailyLimit);
        uint forecastedSum = dailySum;
        for (uint i = 0; i< recipients.length; i++){
            forecastedSum += value;
        }
        require(forecastedSum <= dailyLimit);
        _;
    }
    
    modifier normalActivity(){
        require(frozen == false);
        _;
    }
    
    modifier onlyManager(){
        require(msg.sender == manager);
        _;
    }
    
    function balance() public view returns (uint256){
        return address(this).balance;
    }
    
    function massSend(address[] recipients, uint256 value) public onlyOwner enoughBalance(recipients, value) underDailyLimit(recipients, value) normalActivity returns (bool){
        if (now > dayStart + 1 days){
            dailySum = 0;
            dayStart = now;
        }
        for (uint i = 0; i< recipients.length; i++){
            address toSend = recipients[i];
            toSend.transfer(value);
            dailySum += value;
        }
    } 
    
    function massSendInUSD(address[] recipients, uint256 usdValue) public onlyOwner enoughBalance(recipients, usdValue.mul(100000000000000000000000).div(exchangeRateFullDecimal)) underDailyLimit(recipients, usdValue.mul(100000000000000000000000).div(exchangeRateFullDecimal)) normalActivity returns (bool){
        if (now > dayStart + 1 days){
            dailySum = 0;
            dayStart = now;
        }
        uint value = usdValue.mul(100000000000000000000000).div(exchangeRateFullDecimal);
        for (uint i = 0; i< recipients.length; i++){
            address toSend = recipients[i];
            toSend.transfer(value);
            dailySum += value;
        }
    } 
    
    function setDailyLimit(uint value) public onlyOwner normalActivity{
        dailyLimit = value;
    }
    
    function freezeWallet() onlyManager external {
        frozen = true;
    }
    
    function abandonWallet() onlyManager external {
        require (frozen == true);
        selfdestruct(owner);
    }
    
    function voteToFreeze(bool vote) public{
        CoolWalletManager walletManager = CoolWalletManager(manager);
        walletManager.votingForFreeze(vote);
    }
    
    function voteToAbandon(bool vote) public{
        CoolWalletManager walletManager = CoolWalletManager(manager);
        walletManager.votingForAbandon(vote);
    }
    
    function() public payable{    
        //allow contract to receive money
    }
    
    //Oracle functions
    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) revert();
        ETHUSD = result;
        updatedPrice(ETHUSD);
        strings.slice memory temp = result.toSlice();
        string memory stringRate = temp.split("uint256: ".toSlice()).toString();
        strings.slice memory decimalsTemp = stringRate.toSlice();
        strings.slice memory integersTemp = decimalsTemp.split(".".toSlice());
        string memory decimals = decimalsTemp.toString();
        string memory integers = integersTemp.toString();
        string memory totalNumber = integers.toSlice().concat(decimals.toSlice());
        exchangeRateFullDecimal = parseInt(totalNumber);
        update();
    }
    
    function update() payable {
        if (oraclize.getPrice("URL") > address(this).balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
        }
    }
}