pragma solidity^0.4.24;
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract MassSend is usingOraclize{
-    /*
-    The purpose of this app is simply to allow mass sending of a predetermined amount of Ether to multiple addresses. It functions mostly as a wallet.
-    The app comes with a few functionalities:
-        - Set a daily limit
-        - Show the existing balance of the wallet
-        - Accept payments to the wallet
-        - Send to multiple addresses
         - Live Exchange rates updated per minute
         - Automatic live conversion from USD to Ether and sending (Useful if you owe money in USD and need to pay in Ether)
-    You can use it with Remix browser: https://remix.ethereum.org
-    */
    
    using SafeMath for uint;
    using strings for *;
    
    string public ETHUSD;
    address owner;
    uint dailyLimit;
    uint dayStart;
    uint dailySum = 0;
    uint public exchangeRateFullDecimal;
    
    event newOraclizeQuery(string description);
    event updatedPrice(string price);
    
    constructor() public payable{
        owner = msg.sender;
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
    function balance() public view returns (uint256){
        return address(this).balance;
    }
    
    function massSend(address[] recipients, uint256 value) public onlyOwner enoughBalance(recipients, value) underDailyLimit(recipients, value) returns (bool){
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
    
        function massSendInUSD(address[] recipients, uint256 usdValue) public onlyOwner enoughBalance(recipients, usdValue.mul(100000000000000000000000).div(exchangeRateFullDecimal)) underDailyLimit(recipients, usdValue.mul(100000000000000000000000).div(exchangeRateFullDecimal)) returns (bool){
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
    
    function setDailyLimit(uint value) public onlyOwner{
        dailyLimit = value;
    }
    
    function() private payable{    
        //allow contract to receive money
    }
    
    //Oracle functions
    function __callback(bytes32 myid, string result) {
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