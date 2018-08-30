var Twilio = require('twilio');
var twillio = new Twilio.RestClient(process.env.TWILLIO_SID, process.env.TWILLIO_AUTH_TOKEN);
var Web3 = require('web3');
var web3 = new Web3(new Web3.providers.HttpProvider(process.env.ETHEREUM_RPC_URL));
var fs = require('fs');

fs.readFile('build/contracts/FoodApp.json', (error, json) => {
  var json = JSON.parse(json);
  var contract = web3
    .eth
    .contract(json.abi)
    .at(process.env.CONTRACT_ADDRESS);

  contract.Message().watch(function(error, event) {
    twillio.messages.create({
      body: event.args.body,
      to: event.args.to,
      from: process.env.TWILLIO_FROM_NUMBER,
    }, function(err, message) {
      console.log("Sent:" + message.sid);
    });
  });
});