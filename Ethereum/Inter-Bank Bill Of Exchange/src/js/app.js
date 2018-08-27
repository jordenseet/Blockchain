App = {
    web3Provider: null,
    contracts: {},

    init: function () {
        console.log("App started")
        return App.initWeb3();
    },

    initWeb3: function () {
        // Is there an injected web3 instance?
        if (typeof web3 !== 'undefined') {
            App.web3Provider = web3.currentProvider;
        } else {
            // If no injected web3 instance is detected, fall back to Ganache
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
        }
        web3 = new Web3(App.web3Provider);

        return App.initContract();
    },

    initContract: function () {
        $.getJSON('LetterOfCredit.json', function (data) {
            // Get the necessary contract artifact file and instantiate it with truffle-contract
            var LetterOfCreditArtifact = data;
            App.contracts.LetterOfCredit = TruffleContract(LetterOfCreditArtifact);

            // Set the provider for our contract
            App.contracts.LetterOfCredit.setProvider(App.web3Provider);
        });

        return App.bindEvents();
    },

    bindEvents: function () {
        $(document).on('click', '.btn-create', App.createBOE);
        $(document).on('click', '.btn-set', App.setBOE);
        $(document).on('click', '.btn-exercise', App.exerciseBOE);
        $(document).on('click', '.btn-cert', App.certify);
    },

    createBOE: function(event) {
        event.preventDefault();

        var LetterOfCreditInstance;
        var importer = document.getElementById("importer").value;
        var exporter = document.getElementById("exporter").value;
        var shipper = document.getElementById("shipper").value;
        var shipmentValue = parseInt(document.getElementById("shipment").value);
        console.log("importer is " + importer)
        console.log("exporter is " + exporter)
        console.log("shipper is " + shipper)
        console.log("shipment value is " + shipmentValue)

        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.deployed().then(function (instance) {
                LetterOfCreditInstance = instance;
                console.log(LetterOfCreditInstance.address);
                // send to index.html LetterOfCreditInstance.address
                document.getElementById("contractAddress").innerHTML = "The contract address is " + LetterOfCreditInstance.address;
                
                return LetterOfCreditInstance.createBOE(importer,exporter,shipper,shipmentValue);
                console.log(instance.getBOEHolder());
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    setBOE: function(event) {

        console.log("hi there")
        event.preventDefault();

        var LetterOfCreditInstance;
        var value = parseInt(document.getElementById("boeValue").value)
        console.log(value)

        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.deployed().then(function (instance) {
                LetterOfCreditInstance = instance;
                return LetterOfCreditInstance.setBillOfExchangePrice(value);
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    
    exerciseBOE: function (event) {
        event.preventDefault();

        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.deployed().then(function (instance) {
                LetterOfCreditInstance = instance;
                return LetterOfCreditInstance.exerciseBillOfExchange();
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    certify: function (event) {
        event.preventDefault();

        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.deployed().then(function (instance) {
                LetterOfCreditInstance = instance;
                return LetterOfCreditInstance.certifyCertOfInspection();
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    }

};

$(function () {
    $(window).load(function () {
        App.init();
    });
});
