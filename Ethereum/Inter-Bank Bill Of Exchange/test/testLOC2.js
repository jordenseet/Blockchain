var LetterOfCredit = artifacts.require('LetterOfCredit')


contract('LetterOfCredit', function(accounts) {

    const exporter = accounts[0]
    const importer = accounts[1]
    const shipper = accounts[2]

    it("It should start an Auction if the Bill of Exchange fails", async() => {
        const loc = await LetterOfCredit.deployed()
        await loc.createBOE(exporter,importer,shipper,50)
  
        var eventEmitted = false

        var event = loc.BOEFailed()
        await event.watch((err, res) => {
            eventEmitted = true
        })
        //this will cause BOE to fail as importer doesn't have enough coins
        //auction can now start
        await loc.exerciseBillOfExchange({from:importer, value:1})
        assert.equal(eventEmitted, true, 'The Auction did not start')
        console.log("Auction started as expected! Good job!")
      })

      it("It should reflect winning bidder correctly", async() => {
        var winning
        const loc = await LetterOfCredit.deployed()
        await loc.createBOE(exporter,importer,shipper,50)
  
        var eventEmitted = false

        var event = loc.WinningBid()
        await event.watch((err, res) => {
            winning = res.args.bidder
            eventEmitted = true
        })
        //this will cause BOE to fail as importer doesn't have enough coins
        await loc.exerciseBillOfExchange({from:importer, value:1})
        //auction can now start
        await loc.unclaimedAuction(59,{from:shipper})
        await loc.unclaimedAuction(57,{from:accounts[3]})
        await loc.unclaimedAuction(91,{from:accounts[4]})
        await loc.unclaimedAuction(78,{from:accounts[5]})
        await loc.endAuction({from:exporter})
        assert.equal(winning, accounts[4], 'The winning bidder is not reflected in the BOE')
        console.log("Winning bidder successfully reflected! Good job!")
      })
})
