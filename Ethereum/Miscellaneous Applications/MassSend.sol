pragma solidity^0.4.24;
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";

contract MassSend{
    /*
    The purpose of this app is simply to allow mass sending of a predetermined amount of Ether to multiple addresses. It functions mostly as a wallet.
    The app comes with a few functionalities:
        - Set a daily limit
        - Show the existing balance of the wallet
        - Accept payments to the wallet
        - Send to multiple addresses
    You can use it with Remix browser: https://remix.ethereum.org
    */
    using SafeMath for uint;
    address owner;
    uint dailyLimit;
    uint dayStart;
    uint dailySum = 0;

    constructor() public payable{
        owner = msg.sender;
        dayStart = now;
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
    
    modifier underDailyLimit(){
        require(dailySum <= dailyLimit);
        _;
    }

    function balance() public view returns (uint256){
        return address(this).balance;
    }
    
    function massSend(address[] recipients, uint256 value) public onlyOwner enoughBalance(recipients, value) underDailyLimit returns (bool){
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
    
    function setDailyLimit(uint value) public onlyOwner{
        dailyLimit = value;
    }
    
    function() private payable{    
        //allow contract to receive money
    }
}