App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    console.log("App started")
    return App.initWeb3();
  },

  initWeb3: function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('LetterOfCredit.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var LetterOfCreditArtifact = data;
      App.contracts.LetterOfCredit = TruffleContract(LetterOfCreditArtifact);
    
      // Set the provider for our contract
      App.contracts.LetterOfCredit.setProvider(App.web3Provider);
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-set', App.setBOE);
  },

  setBOE: function(event) {
    event.preventDefault();

    var LetterOfCreditInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

     var account = accounts[0];

  App.contracts.LetterOfCredit.deployed().then(function(instance) {
    LetterOfCreditInstance = instance;

    // Execute adopt as a transaction by sending account
    return LetterOfCreditInstance.setBillOfExchangePrice(document.getElementById("boeValue"),{from: account});
  }).catch(function(err) {
    console.log(err.message);
  });
});
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
