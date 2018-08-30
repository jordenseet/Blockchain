
var Dish = artifacts.require("./FoodApp.sol");

module.exports = function(deployer) {
  deployer.deploy(Dish);
};
