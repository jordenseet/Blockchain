var LetterOfCredit = artifacts.require("LetterOfCredit");

module.exports = function(deployer) {
  deployer.deploy(LetterOfCredit,web3.eth.accounts[1],web3.eth.accounts[2],50)
};
