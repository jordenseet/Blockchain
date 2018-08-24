var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "brick amused relax oyster path tent captain armor focus chair common razor";
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/f61e631a2f894409a82b9917d36a95a7")
      },
      network_id: 3
    }   
  }
};