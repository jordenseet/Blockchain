var CoolWalletManager = artifacts.require('./CoolWalletManager.sol')
var CoolWallet = artifacts.require("./CoolWallet.sol");

contract('CoolWalletManager', function(accounts) {

    const manager = accounts[0]
    const userOne = accounts[1]

    it("It should create a wallet successfully and correctly retrieve the wallet address", async() => {
        
        let instance = await CoolWalletManager.deployed()
        console.log("debug0 " + instance.address)
        assert.isNotNull(instance.address,"Address is null") //first test case
        walletManager = CoolWalletManager.at(instance.address)
        var eventEmitted = false

        var event  = walletManager.WalletCreated()
        //console.log(walletManager)
        createdWallet = await walletManager.createWallet();//.({value:100000000000000000})
        //console.log(createdWallet)

       /*await event.watch((err, res) => {
            walletGenerated = res.args.walletAddress
            console.log("debug 2 " + walletGenerated)
            eventEmitted = true
        })

        let createdWalletAddress = createdWallet.getAddress()
        console.log("debug3 " + createdWalletAddress)


        assert.equal(eventEmitted, true, 'Wallet is not created')
        assert.equal(walletGenerated, createdWalletAddress, 'Wallet created does not have correct address')*/
    })

    /*var walletManager;
    var createdWalletAddress;
    var eventEmitted = false
    CoolWalletManager.deployed().then(function(instance) {
        var walletManagerAddress = instance.address;  
        walletManager = CoolWalletManager.at(walletManagerAddress);
        console.log("creating wallet...")
        return walletManager.createWallet({from: userOne, value:100000});
      }).then(function(result) {
        console.log("past createWallet function")
        // result is an object with the following values:
        //
        // result.tx      => transaction hash, string
        // result.logs    => array of decoded events that were triggered within this transaction
        // result.receipt => transaction receipt object, which includes gas used
      
        // We can loop through result.logs to see if we triggered the Transfer event.
        for (var i = 0; i < result.logs.length; i++) {
          console.log("entered for loop")
          var log = result.logs[i];
          //console.log(log)
          if (log.event == "WalletCreated") {
            // We found the event!
            eventEmitted = true
            createdWalletAddress = logs.args.walletAddress
            break;
          }
        }
      }).then(function(){
        assert.equal(eventEmitted, true, 'Wallet is not created')
      })*/

      //assert.equal(walletGenerated, createdWalletAddress, 'Wallet created does not have correct address') 

    /*it("It should retrieve a valid exchange rate via the oracle", async() => {

        let walletManager = await CoolWalletManager.deployed()
        var eventEmitted = false
        createdWallet = walletManager.createWallet({value:100000000000000000})
        var event = createdWallet.updatedPrice()
        await event.watch((err,res) =>{
            exchangeRate = res.args.price
            eventEmitted = true
        })
        createdWallet.update()
        assert.equal(eventEmitted, true, 'Oracle failed to activate')
        assert.notEqual(exchangeRate,"",'Exchange rate returned is empty')
    })*/
});
