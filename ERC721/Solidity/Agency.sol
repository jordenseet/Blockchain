pragma solidity ^0.4.23;
import "./SafeMath.sol";
import "./Club.sol";

//@dev The Agency contract is a representation of a Sports Agency and their Agents
contract Agency{
    using SafeMath for uint8;
    using SafeMath32 for uint32;
    
    string agencyName;
    string agencyId;
    string country;
    uint32 foundedDate;
    address agencyAddress;

    constructor(string _agencyName, string _agencyId, string _country, uint32 _foundedDate){
        agencyName = _agencyName;
        agencyId = _agencyId;
        country = _country;
        foundedDate = _foundedDate;
        agencyAddress = msg.sender;
    }
    
    struct Agent{
        string name;
        string agentId; //agentId should be unique across agencies
        address agentAddress;
        uint8 contractLength; // in Years
        uint32 contractStart; // contract starts upon instantiation.
        uint32 weeklySalary;
    }
    
    modifier correctAgent(address agentAddress){
        require(msg.sender == agentAddress);
        _;
    }
    modifier correctAgency (address thisAgencyAddress){
        require(msg.sender == agencyAddress);
        _;
    }
    
    mapping(string=>address) agencyLookup;
    mapping(string=>Agent) agentLookup;
    
    function createAgent(string name, string agentId,address agentAddress,uint8 contractLength, uint32 weeklySalary)
     public correctAgency(agencyAddress){
        agencyLookup[agentId] = msg.sender;
        agentLookup[agentId] = (Agent(name,agentId,agentAddress,contractLength, uint32(now), weeklySalary));
    }
    function updateContractLength(string agentId) public{
        uint32 contractStartDate = agentLookup[agentId].contractStart;
        uint32 contractLengthRemaining = agentLookup[agentId].contractLength;
        uint32 currentDate = uint32(now);
        if (currentDate - contractStartDate >= contractLengthRemaining.mul(365)){
            contractLengthRemaining = 0;
        }
        else{
            uint32 dayDifference = currentDate.sub(contractStartDate);
            uint8 numberOfYears = uint8(dayDifference.div(365));
            agentLookup[agentId].contractLength = uint8(contractLengthRemaining - numberOfYears);
        }
    }
    function newContract(string agentId, uint32 contractStartDate, uint8 numberOfYears, uint32 newSalary) public{
        agentLookup[agentId].contractStart = contractStartDate;
        agentLookup[agentId].contractLength = numberOfYears;
        agentLookup[agentId].weeklySalary = newSalary;
    }
}