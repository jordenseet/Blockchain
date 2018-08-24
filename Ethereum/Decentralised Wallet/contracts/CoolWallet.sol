pragma solidity^0.4.24;
//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
//import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
import "./CoolWalletManager.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "oraclize-api/usingOraclize.sol";
import "./solidity-stringutils-master/src/strings.sol";

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
    address public manager;
    uint public dailyLimit;
    uint dayStart;
    uint dailySum = 0;
    uint exchangeRateFullDecimal;
    uint USDValueToPeg = 20;
    bool frozen;
    bool startedUpdate;
    CoolWalletManager walletManager;
    
    event newOraclizeQuery(string description);
    event updatedPrice(string price);
    
    constructor() public payable{
        owner = tx.origin;
        manager = msg.sender;
        dayStart = now;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    modifier enoughBalance(address[] recipients, uint256 value){
        uint outgoingValue = recipients.length.mul(value);
        require(outgoingValue <= this.balance);
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
    
    
    modifier sufficientBalance(){
        // This is to make it financially expensive for a troll to create multiple accounts and thus form majority
        // allowing him to freeze or destroy wallets as he pleases.
        // This would require the troll(s) to create > 500 accounts and have > USD$10000 in eth to play the system.
        require(startedUpdate == true);
        uint exchangeRate = exchangeRateFullDecimal;
        uint valueToPeg = USDValueToPeg.mul(100000000000000000000000).div(exchangeRate);
        require(this.balance >= valueToPeg);
        _;
    }
    
    modifier startUpdate(){
        require(startedUpdate == true);
        _;
    }
    
    function setManager() public{
        walletManager = CoolWalletManager(manager);
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
    
    function massSendInUSD(address[] recipients, uint256 usdValue) public onlyOwner enoughBalance(recipients, usdValue.mul(100000000000000000000000).div(exchangeRateFullDecimal)) underDailyLimit(recipients, usdValue.mul(100000000000000000000000).div(exchangeRateFullDecimal)) normalActivity startUpdate returns (bool){
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

    function unfreezeWallet() onlyManager external {
        frozen = false;
    }
    
    function abandonWallet() onlyManager external {
        require (frozen == true);
        selfdestruct(owner);
    }
    
    function voteToFreeze(bool vote) sufficientBalance public{
        walletManager.votingForFreeze(vote);
    }
    
    function voteToAbandon(bool vote) sufficientBalance public{
        walletManager.votingForAbandon(vote);
    }

    function decentraliseMore(int _minNumberToDecentralize) public{
        require(_minNumberToDecentralize >= 0);
        uint communityVoteNumber = uint(_minNumberToDecentralize);
        walletManager.communityVote(communityVoteNumber);
    }
    
    function getAddress() view returns (address thisWalletAddress){
        return address(this);
    }
    
    function getBalance() view returns(uint thisWalletBalance){
        return this.balance;
    }
    
    function() public payable{    
        //allow contract to receive money
    }
    
    //Oracle functions
    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
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
        if (oraclize.getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            startedUpdate = true;
            oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
        }
    }
}