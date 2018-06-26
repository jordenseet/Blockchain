pragma solidity ^0.4.23;

contract SupplyChain {

  /* set owner */
  address owner;

  /* Add a variable called skuCount to track the most recent sku # */
  uint skuCount;

  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items
  */
  mapping (uint => Item) public items;

  /* Add a line that creates an enum called State. This should have 4 states
    ForSale
    Sold
    Shipped
    Received
    (declaring them in this order is important for testing)
  */
  enum State{
      ForSale, Sold, Shipped, Received
  }

  /* Create a struct named Item.
    Here, add a name, sku, price, state, seller, and buyer
  */
  struct Item{
      string name;
      uint sku;
      uint price;
      State state;
      address buyer;
      address seller;
  }

  /* Create 4 events with the same name as each possible State (see above)
    Each event should accept one argument, the sku*/
    event ForSale(uint sku);
    event Sold(uint sku);
    event Shipped(uint sku);
    event Received(uint sku);

/* Create a modifer that checks if the msg.sender is the owner of the contract */

  modifier verifyCaller (address _address) {
      require (msg.sender == _address); 
      _;
  }

  modifier paidEnough(uint _price) {
      require(msg.value >= _price);
      _;
  }
  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }

  modifier forSale(uint sku){
      Item storage item = items[sku];
      require(item.state == State.ForSale);
      _;
  }
  modifier sold(uint sku){
      Item storage item = items[sku];
      require(item.state == State.Sold);
      _;
  }
  modifier shipped(uint sku){
      Item storage item = items[sku];
      require(item.state == State.Shipped);
      _;
  }
  modifier received(uint sku){
      Item storage item = items[sku];
      require(item.state == State.Received);
      _;
  }


  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set the skuCount to 0. */
       owner = msg.sender;
       skuCount = 0;
  }

  function addItem(string _name, uint _price) public {
    emit ForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: 0});
    skuCount = skuCount + 1;
  }

  /*This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold.This function uses 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent.*/
 
  function buyItem(uint sku) public payable forSale(sku) paidEnough(items[sku].price) checkValue(sku){
      uint price = items[sku].price;
      address buyer = msg.sender;
      items[sku].buyer = buyer;
      address seller = items[sku].seller;
      seller.transfer(price);
      items[sku].state = State.Sold;
      emit Sold(sku);
      
  }

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped.*/
  function shipItem(uint sku) sold(sku) verifyCaller(items[sku].seller) public{
      items[sku].state = State.Shipped;
      emit Shipped(sku);
  }

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received.*/
  function receiveItem(uint sku) public {
      items[sku].state = State.Received;
      emit Received(sku);     
  }

  /* For test purposes */
  function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }

}
