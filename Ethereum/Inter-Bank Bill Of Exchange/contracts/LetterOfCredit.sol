pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract LetterOfCredit is Ownable {
    address exporter;
    address public importer;
    address shipper;
    string shipmentStatus; 
    uint256 shipmentValue;
    bool auctionStarted;
    bool auctionFailed;
    bool emergencyStop;
    uint auctionStartTime; 

    BillOfExchange public boe;
    BillOfExchange public winningBid;
    CertificateOfInspection coi;

    event BOESet(uint paymentAmt, address exporter);
    event BOEExercised(address newHolder);
    event CertificationDone(bool certified, uint date,string status);
    event BOEFailed(string startAuction);
    event Alert(string message);
    event WinningBid(address bidder);

    struct BillOfExchange {
        address holder;
        uint256 paymentAmount; 
    }

    struct CertificateOfInspection {
        bool certified;
        uint date; 
    }

    modifier normalActivity(){
        require(emergencyStop == false);
        _;
    }

    // The Letter of credit should only be instantiated by an exporter.  
    // In this exercise, we will only be simulating the Bill of Exchange, and Certificate of Inspection functions as smart contracts.
    constructor() public {
    }

//////////////// DO NOT EDIT CODE ABOVE THIS LINE ////////////////

    // Allow the Bill of Exchange Holder to set the value of the bill. 
    // This may only be performed by the holder of the bill.

    function createBOE(address exporterAddr, address importerAddr, address shipperAddr, uint256 shipmentVal) public {
        exporter = exporterAddr;
        importer = importerAddr; 
        shipper = shipperAddr;
        shipmentValue = shipmentVal; 
        shipmentStatus = "Shipped";
        boe = BillOfExchange({
            holder: exporterAddr,
            paymentAmount: shipmentValue
        });

        coi = CertificateOfInspection({
            certified: false,
            date: 0
        });
    }

    function emergencyOperationsStop() public onlyOwner{
        emergencyStop = true;
    }

    function resumeOperations() public onlyOwner{
        emergencyStop = false;
    }

    function getBOEHolder() public view returns (address holder){
        return boe.holder;
    }

    function getBOEPaymentAmt() public view returns (uint value){
        return boe.paymentAmount;
    }
    function setBillOfExchangePrice(uint256 value) public {
        if(msg.sender != getBOEHolder()){
            return;
        }

        boe.paymentAmount = value; 
        emit BOESet(boe.paymentAmount,boe.holder);
    }

    // This function will be performed by anyone seeking finance the Bill of Exchange.
    // First, the Financier (or msg.sender) will have to perform a transfer of funds to the current Bill Holder.
    // Next, if payment is successful, the ownership of the Bill of Exchange will be set to the new holder, and the Payment Amount would be set to the new exchange amount. 

    function unclaimedAuction(uint256 value) public normalActivity{
        // Assume 1 minute firesale auctions if BOE is left unclaimed
        if (!auctionStarted && auctionFailed){
            auctionStarted = true;
            auctionStartTime = now;
            winningBid = BillOfExchange({
                holder: exporter,
                paymentAmount: 0
            });
        }
        if(now >= auctionStartTime + 1 minutes){
            if (winningBid.holder == exporter && winningBid.paymentAmount == 0){
                //auction has failed with no bidders
                auctionStarted = false;
                auctionFailed = true;
                emit BOEFailed("Time to restart an Auction for the Bill of Exchange");
            }
            else{
                boe = winningBid;
                importer = boe.holder;
            }
        }
        else if (value > winningBid.paymentAmount){
            winningBid = BillOfExchange({
                holder: msg.sender,
                paymentAmount: value
            });
            emit WinningBid(msg.sender);
        }
        
    }
    function exerciseBillOfExchange() public normalActivity payable{
        // Attempt Transfer to BoE Holder
        if(boe.holder.send(getBOEPaymentAmt())){
            boe.holder = msg.sender;
            auctionFailed = false;
            emit BOEExercised(boe.holder);
        }
        else{
            auctionStarted = false;
            auctionFailed = true;
            emit BOEFailed("Time to start an Auction for the Bill of Exchange");
        }
    }

    // To be performed by the Importer once the goods are In-Port
    // After inspection is certified by the importer, the importer then transfer the shipmentValue to the current holder of the Bill of Exchange. 
     
    function certifyCertOfInspection() public normalActivity payable{
        require(importer == msg.sender);
        if(equal(shipmentStatus, "In-Port")){ 
            coi = CertificateOfInspection({
                certified: true,
                date: now
            });
            // Attempt Transfer funds to BoE Holder.
            if(boe.holder.send(shipmentValue)){
                shipmentStatus = "Collected"; 
                emit CertificationDone(coi.certified,coi.date,shipmentStatus);
            }
            else{
                emit Alert("sending shipment value failed");
            }
        }
        else{
            emit Alert("Item is not in port");
        }

    }

    function compare(string _a, string _b) private returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

//////////////// DO NOT EDIT CODE BELOW THIS LINE ////////////////


/// Given Functions

    /// @dev Changes the goods status from shipped to "In-Port" once goods are collected. 
    function completeShipment() public{
        if(shipper != msg.sender){
            return;
        }
        shipmentStatus = "In-Port";         
    }

    /// @dev Compares two strings and returns true if they are equal.
    function equal(string _a, string _b) private returns (bool) {
        return compare(_a, _b) == 0;
    }
}