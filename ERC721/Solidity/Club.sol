pragma solidity ^0.4.23;
import "./SafeMath.sol";
//@dev The Club contract is a representation of a Sports Club and their athletes 
contract Club {
    using SafeMath for uint8;
    using SafeMath32 for uint32;
    
    string clubName;
    string clubId;
    string country;
    uint32 foundedDate;
    address clubAddress;

    constructor(string _clubName,string _clubId,string _country,uint32 _foundedDate) public{
        clubName = _clubName;
        clubId = _clubId;
        country = _country;
        foundedDate = _foundedDate;
        clubAddress = msg.sender;
    }
    
    struct Athlete{
        string name;
        string athleteId; //agentId should be unique too
        address athleteAddress;
        uint8 contractLength; // in Years
        uint32 contractStart; // contract starts upon instantiation.
        uint32 weeklySalary;
    }
    
    modifier correctAthlete (address athleteAddress){
        require(msg.sender == athleteAddress);
        _;
    }
    modifier correctClub (address thisClubAddress){
        require(msg.sender == thisClubAddress);
        _;
    }
    
    mapping(string=>address) clubLookup;
    mapping(string=>Athlete) athleteLookup;
    
    function createAgent(string name, string athleteId,address athleteAddress,uint8 contractLength, uint32 weeklySalary)
    public correctClub(clubAddress){
        clubLookup[athleteId] = msg.sender;
        athleteLookup[athleteId] = (Athlete(name,athleteId,athleteAddress,contractLength, uint32(now), weeklySalary));
    }
    function updateContractLength(string athleteId) public{
        uint32 contractStartDate = athleteLookup[athleteId].contractStart;
        uint32 contractLengthRemaining = athleteLookup[athleteId].contractLength;
        uint32 currentDate = uint32(now);
        if (currentDate - contractStartDate >= contractLengthRemaining.mul(365)){
            contractLengthRemaining = 0;
        }
        else{
            uint32 dayDifference = currentDate.sub(contractStartDate);
            uint8 numberOfYears = uint8(dayDifference.div(365));
            athleteLookup[athleteId].contractLength = uint8(contractLengthRemaining - numberOfYears);
        }
    }
    function newContract(string athleteId, uint32 contractStartDate, uint8 numberOfYears, uint32 newSalary) public{
        athleteLookup[athleteId].contractStart = contractStartDate;
        athleteLookup[athleteId].contractLength = numberOfYears;
        athleteLookup[athleteId].weeklySalary = newSalary;
    }
}