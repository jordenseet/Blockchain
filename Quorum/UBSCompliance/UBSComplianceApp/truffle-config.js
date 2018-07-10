module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 22000, // was 8545
      network_id: "*", // Match any network id
      gasPrice: 0,
      gas: 4500000
    },
    nodefour:  {
      host: "127.0.0.1",
      port: 22003,
      network_id: "*", // Match any network id
      gasPrice: 0,
      gas: 4500000
    },
    nodeseven:  {
      host: "127.0.0.1",
      port: 22006,
      network_id: "*", // Match any network id
      gasPrice: 0,
      gas: 4500000
    }
  }
};