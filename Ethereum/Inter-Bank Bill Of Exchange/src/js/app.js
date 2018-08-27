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
        $(document).on('click', '.btn-create', App.createBoe);
        $(document).on('click', '.btn-set', App.setBOE);
        $(document).on('click', '.btn-exercise', App.exerciseBOE);
        $(document).on('click', '.btn-auction', App.auction);
        $(document).on('click', '.btn-auctionEnd', App.auctionEnd);
        $(document).on('click', 'btn-ship', App.setShip);
        $(document).on('click', '.btn-cert', App.certify);
        $(document).on('click','.btn-details',App.getDetails);
        $(document).on('click','.btn-stop',App.stop);
        $(document).on('click','.btn-start',App.start);
    },

    createBoe: function(event) {
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
                return LetterOfCreditInstance.createBOE(exporter,importer,shipper,shipmentValue).then(function(){
                    document.getElementById("contractAddress").innerHTML = "The contract address is " + LetterOfCreditInstance.address;
                    document.getElementById("boeCreation").innerHTML = "Contract " + LetterOfCreditInstance.address + " successfully updated with value " + shipmentValue;
                    document.getElementById("boeCreatedDetails").innerHTML = "Importer: " + importer +"<br> Exporter: " + exporter + "<br> Shipper: " + shipper;
                });
            }).catch(function (err) {
                console.log(err);
            });
        });
    },

    setBOE: function(event) {
        event.preventDefault();

        var LetterOfCreditInstance;
        var value = parseInt(document.getElementById("boeValue").value);
        var address = document.getElementById("desiredContract").value;

        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance;
                return LetterOfCreditInstance.setBillOfExchangePrice(value).then(function(){
                    document.getElementById("newBOEValue").innerHTML = address + "'s BOE value changed to " + value;
                });
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    
    exerciseBOE: function (event) {
        event.preventDefault();
        var address = document.getElementById("exerciseContract").value;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }
            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance;
                LetterOfCreditInstance.getBOEPaymentAmt().then(function(result){
                    return LetterOfCreditInstance.exerciseBillOfExchange({value:result.toNumber()}).then(function(){
                        document.getElementById("exercisedBOE").innerHTML = address + " successfully exercised!";
                    });
                });

            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    auction: function (event) {
        event.preventDefault();
        var address = document.getElementById("auctionContract").value;
        var bid = document.getElementById("auctionValue").value;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance; 
                return LetterOfCreditInstance.unclaimedAuction(bid).then(function(){
                    document.getElementById("auctionBOE").innerHTML = "Successfully bid " + bid + " amount for " + address;
                });
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    auctionEnd: function (event) {
        event.preventDefault();
        var address = document.getElementById("auctionEndContract").value;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance;
                LetterOfCreditInstance.getWinningBOEPaymentAmt().then(function(res1){
                    LetterOfCreditInstance.getWinningBOEHolder().then(function(res2){
                        return LetterOfCreditInstance.endAuction().then(function(){
                             document.getElementById("auctionEndBOE").innerHTML = "Ending Auction now, winning bid is " + res1 + " by " + res2;
                        });
                    })
                });
                
                
                
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    setShip: function (event) {
        event.preventDefault();
        var address = document.getElementById("shippedContract").value
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }
            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance;
                return LetterOfCreditInstance.completeShipment().then(function(){
                    document.getElementById("ship").innerHTML = address + " successfully shipped!";
                });
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    certify: function (event) {
        event.preventDefault();
        var address = document.getElementById("certifiableContract").value;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance;
                return LetterOfCreditInstance.certifyCertOfInspection().then(function(){
                    document.getElementById("cert").innerHTML = address + " successfully certified and imported!";
                });
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },

    getDetails: function (event) {
        event.preventDefault();
        var address = document.getElementById("detailsContract").value;
        var holder;
        var value;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance;
                                
                LetterOfCreditInstance.getBOEHolder().then(function(result){
                    console.log(result);
                    holder = result;
                    document.getElementById("thisBoeHolder").innerHTML = "BOE Holder: " + holder;
                });

                LetterOfCreditInstance.getBOEPaymentAmt().then(function(result){
                    console.log(result);
                    value = result;
                    document.getElementById("thisBoeValue").innerHTML = "BOE Value: " + value;
                });
                return;
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },
    stop: function (event) {
        event.preventDefault();
        var address = document.getElementById("emergencyContract").value;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance;
                return LetterOfCreditInstance.emergencyOperationsStop().then(function(){
                    document.getElementById("contractStop").innerHTML = address + " successfully frozen!";
                });
            }).catch(function (err) {
                console.log(err.message);
            });
        });
    },
    start: function (event) {
        event.preventDefault();
        var address = document.getElementById("emergencyContract").value;
        web3.eth.getAccounts(function (error, accounts) {
            if (error) {
                console.log(error);
            }

            App.contracts.LetterOfCredit.at(address).then(function (instance) {
                LetterOfCreditInstance = instance;
                return LetterOfCreditInstance.resumeOperations().then(function(){
                    document.getElementById("contractStart").innerHTML = address + " successfully restarted!";
                });
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
