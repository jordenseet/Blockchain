
var CoolWalletManager = artifacts.require("./CoolWalletManager.sol");
var CoolWallet = artifacts.require("./CoolWallet.sol");

module.exports = function(deployer) {
  deployer.deploy(CoolWallet);
  deployer.deploy(CoolWalletManager);
};
