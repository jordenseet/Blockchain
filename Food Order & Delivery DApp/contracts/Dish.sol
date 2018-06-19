pragma solidity ^0.4.23;

contract Dish {

  /* set owner */
  address owner;

  /* Add a variable called dishNumberCount to track the most recent dishNumber # */
  uint dishNumberCount;

  /* Add a line that creates a public mapping that maps the dishNumber (a number) to a Dish.
     Call this mappings dishes
  */
  mapping (uint => Dish) public dishes;

  /* Add a line that creates an enum called State. This should have 4 states
    Preparing
    Delivering
    AwaitingPayment
    Payed
    (declaring them in this order is important for testing)
  */
  enum State{
      Preparing, Delivering, AwaitingPayment, Paid
  }

  /* Create a struct named Dish.
    Here, add a name, dishNumber, price, state, seller, and buyer
  */
  struct Dish{
      string name;
      uint dishNumber; //each dish will have a unique dishNumber for traceability purposes
      uint price;
      State state;
      address seller;
      address buyer;
  }

  /* Create 4 events with the same name as each possible State (see above)
    Each event should accept one argument, the dishNumber*/
    event Preparing(uint dishNumber);
    event Delivering(uint dishNumber);
    event AwaitingPayment(uint dishNumber);
    event Paid(uint dishNumber);

/* Create a modifer that checks if the msg.sender is the owner of the contract */

  modifier verifyCaller (address _address) {
      require (msg.sender == _address); 
      _;
  }

  modifier paidEnough(uint _price) {
      require(msg.value >= _price);
      _;
  }
  modifier checkValue(uint _dishNumber) {
    //refund them after pay for Dish UTXO style
    _;
    uint _price = dishes[_dishNumber].price;
    uint amountToRefund = msg.value - _price;
    dishes[_dishNumber].buyer.transfer(amountToRefund);
  }

  modifier preparing(uint dishNumber){
      Dish storage dish = dishes[dishNumber];
      require(dish.state == State.Preparing);
      _;
  }
  modifier delivering(uint dishNumber){
      Dish storage dish = dishes[dishNumber];
      require(dish.state == State.Delivering);
      _;
  }
  modifier awaitingPayment(uint dishNumber){
      Dish storage dish = dishes[dishNumber];
      require(dish.state == State.AwaitingPayment);
      _;
  }
  modifier paid(uint dishNumber){
      Dish storage dish = dishes[dishNumber];
      require(dish.state == State.Paid);
      _;
  }


  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set the dishNumberCount to 0. */
       owner = msg.sender;
       dishNumberCount = 0;
  }

  function addDish(string _name, uint _price) public {
    emit Preparing(dishNumberCount);
    dishes[dishNumberCount] = Dish({
        name: _name, dishNumber: dishNumberCount, price: _price, state: State.Preparing, seller: owner, buyer: msg.sender
        });
    dishNumberCount = dishNumberCount + 1;
  }

  function preparedDish(uint dishNumber) public preparing(dishNumber) {
      dishes[dishNumber].state = State.Delivering;
      emit Delivering(dishNumber);
  }
  
  function reachedDestination(uint dishNumber) public delivering(dishNumber){
      dishes[dishNumber].state = State.AwaitingPayment;
      emit AwaitingPayment(dishNumber);
  }

  function pay(uint dishNumber) public payable awaitingPayment(dishNumber) paidEnough(dishes[dishNumber].price) checkValue(dishNumber){
      uint price = dishes[dishNumber].price;
      address buyer = msg.sender;
      dishes[dishNumber].buyer = buyer;
      owner.transfer(price);
      dishes[dishNumber].state = State.Paid;
      emit Paid(dishNumber);
      
  }

  /* For test purposes */
  function fetchDish(uint _dishNumber) public view returns (string name, uint dishNumber, uint price, uint state, address seller, address buyer) {
    name = dishes[_dishNumber].name;
    dishNumber = dishes[_dishNumber].dishNumber;
    price = dishes[_dishNumber].price;
    state = uint(dishes[_dishNumber].state);
    seller = owner;
    buyer = dishes[_dishNumber].buyer;
    return (name, dishNumber, price, state, seller, buyer);
  }

}
