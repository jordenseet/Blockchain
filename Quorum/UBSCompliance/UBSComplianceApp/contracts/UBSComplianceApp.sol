pragma solidity ^0.4.23;

contract UBSComplianceApp{
    address owner;
    mapping(address => bool) approvedPersonnel;
    
    mapping (address => Customer) public customerDatabase;
    mapping (address => bool) private oneAccountChecker;
    uint8 randomizer = 61;

    enum AssetClass{
        Unverified, LowSES, MediumSES, HighSES
    }
    enum RiskFactor{
        Unverified, LowRisk, MediumRisk, HighRisk
    }

    struct Customer{
        address customer;
        string name;
        //string nationality; nationality can be added if necessary
        uint8 age;
        uint8 mediaScore;
        AssetClass ses;
        RiskFactor risk;
    }

    constructor() public payable{ //payable to ensure liquidity of application
        owner = msg.sender; 
    }
    
    modifier onlyUBS(){
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyApprovedPersonnel(address toCheck){
        require(approvedPersonnel[toCheck] == true);
        _;
    }
    
    function approvePersonnel(address toApprove) public onlyUBS returns (bool){
        approvedPersonnel[toApprove] = true;
        return true;
    }

    function addCustomer(string name, uint8 age, uint monthlyIncome) public{
        require(oneAccountChecker[msg.sender] == false); //prevent DDOS attacks
        uint8  mediaScore = uint8((randomizer**age+monthlyIncome)%10);
        randomizer = mediaScore*age;
        Customer memory c = Customer(msg.sender, name, age, mediaScore, AssetClass.Unverified,RiskFactor.Unverified);
        oneAccountChecker[msg.sender] = true;
        //Simulate oracle retrieval of value, Customer clear KYC media check
        if (mediaScore >= 8){
            c.risk = RiskFactor.HighRisk;
        }
        else{
            if (monthlyIncome <= 3000){
                c.ses = AssetClass.LowSES;
            }
            else if (monthlyIncome <= 6000){
                c.ses = AssetClass.MediumSES;
            }
            else{
                c.ses = AssetClass.HighSES;
            }
        }
        if (mediaScore >= 9){
            c.risk = RiskFactor.HighRisk;
        }
        else if (mediaScore >= 6){
            if (age <= 50 && c.ses != AssetClass.LowSES){
                c.risk = RiskFactor.MediumRisk;
            }
            else {
                c.risk = RiskFactor.HighRisk;
            }
        }
        else if (mediaScore < 6){
            if (age <= 40 && c.ses == AssetClass.LowSES){
                c.risk = RiskFactor.MediumRisk;
            }
            if (age <= 40 && c.ses != AssetClass.LowSES){
                c.risk = RiskFactor.LowRisk;
            }
            else if (age <= 70 && c.ses != AssetClass.LowSES){
                c.risk = RiskFactor.MediumRisk;
            }
        }
        else {
            c.risk = RiskFactor.HighRisk;
        }
        customerDatabase[msg.sender] = c;
    }

    function updateSalary(uint monthlyIncome) public{
        require(oneAccountChecker[msg.sender] == true);
        Customer storage c = customerDatabase[msg.sender];
        if (monthlyIncome <= 3000){
            c.ses = AssetClass.LowSES;
        }
        else if (monthlyIncome <= 6000){
            c.ses = AssetClass.MediumSES;
        }
        else{
            c.ses = AssetClass.HighSES;
        }
        if (c.age <= 40 && c.ses != AssetClass.LowSES){
            c.risk = RiskFactor.LowRisk;
        }
        else if (c.age <= 60 && c.ses != AssetClass.LowSES){
            c.risk = RiskFactor.MediumRisk;
        }
        else {
            c.risk = RiskFactor.HighRisk;
        }
    }
    function updateAge() public returns (uint8) {
        require(oneAccountChecker[msg.sender] == true);
        customerDatabase[msg.sender].age++;
        return customerDatabase[msg.sender].age;
    }
    
    function getRiskStatus(address customer) view public onlyApprovedPersonnel(msg.sender) returns (string) {
        Customer storage c = customerDatabase[customer];
        if (c.risk == RiskFactor.LowRisk){
            return "Customer has low risk profile";
        }
        else if (c.risk == RiskFactor.MediumRisk){
            return "Customer has medium risk profile";
        }
        else if (c.risk == RiskFactor.HighRisk){
            return "Customer has HIGH risk profile";
        }
        else{
            return "Customer is still unverified";
        }
    }
}
