pragma solidity ^0.4.21;

import "./Token.sol";

contract TestToken is Token {
    string public name = "TestToken";
    string public symbol = "TOK";
    uint8 public decimals = 2;
    uint public INITIAL_SUPPLY = 20000;

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}
