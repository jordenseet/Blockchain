
var Dish = artifacts.require("./Dish.sol");

module.exports = function(deployer) {
  deployer.deploy(Dish);
};
