var LetterOfCredit = artifacts.require('LetterOfCredit')


contract('LetterOfCredit', function(accounts) {

    const exporter = accounts[0]
    const importer = accounts[1]
    const shipper = accounts[2]

    it("It should set a Bill of Exchange correctly", async() => {
      var paymentAmount
      var holder
      const loc = await LetterOfCredit.deployed()
      var eventEmitted = false

      var event = loc.BOESet()
      await event.watch((err, res) => {
          paymentAmount = res.args.paymentAmt
          holder = res.args.exporter
          eventEmitted = true
      })

      await loc.setBillOfExchangePrice(1 * Math.pow(10,18))
      assert.equal(paymentAmount, 1 * Math.pow(10,18), 'The Bill of Exchange payment amount is incorrectly set')
      assert.equal(holder, exporter, 'The Bill of Exchange holder is incorrectly set')
      console.log("Bill of Exchange set correctly! Good job!")
    })

    it("It should exercise a Bill of Exchange correctly", async() => {
        var holder
        const loc = await LetterOfCredit.deployed()
        loc.setBillOfExchangePrice(1 * Math.pow(10,18))
        var eventEmitted = false
        var event = loc.BOEExercised()
        await event.watch((err, res) => {
            holder = res.args.newHolder
            eventEmitted = true
        })

    await loc.exerciseBillOfExchange({from:importer, value:1 * Math.pow(10,18)})

    assert.equal(holder, importer, 'The new Bill of Exchange holder is incorrectly set')
    console.log("Bill of Exchange exercised correctly! Good job!")
    })

    it("It should produce a Certificate of Inspection upon arrival to dock", async() => {
      var certStatus
      var dateTime
      var shipStatus
      const loc = await LetterOfCredit.deployed()

      var eventEmitted = false
      loc.completeShipment({from:shipper})

      var event = loc.CertificationDone()
      await event.watch((err, res) => {
          certStatus = res.args.certified
          dateTime = res.args.date
          shipStatus = res.args.status
          eventEmitted = true
      })
      await loc.certifyCertOfInspection({from:importer, value: 50})

      assert.equal(certStatus, true, 'The Certificate of Inspection has not been issued')
      assert.equal(dateTime,(Math.floor(new Date().getTime()/1000)),"There is a discrepancy in the time recorded as certified")
      assert.equal(shipStatus, "Collected", 'The item status indicates that it has not been collected yet')

      console.log("Certification of Inspection done correctly! Good job!")
    })


      /*it("It should allow winning auction bidder to exercise BOE after winning auction", async() => {
        /*var trigger
        const loc = await LetterOfCredit.deployed()
        loc.setIBCUsed(ibc.address)
  
        var eventEmitted = false
        loc.setBillOfExchangePrice(10000)
  
        var event = loc.BOEFailed()
        await event.watch((err, res) => {
            trigger = res.args.message
            eventEmitted = true
        })
  
        await loc.exerciseBillOfExchange({from:importer})
        //this will cause BOE to fail as importer doesn't have enough coins
        //auction can now start

        var event2 = loc.BOEExercised()
        await event2.watch((err, res) => {
            holder = res.args.newHolder
            eventEmitted = true
        })

        await loc.unclaimedAuction(50,{from:shipper})
        setTimeout(loc.unclaimedAuction(50,{from:shipper}),61000)
        await loc.exerciseBillOfExchange({from:shipper})

        assert.equal(holder, shipper, 'The winning bidder is not reflected in the BOE')
        console.log("Auction started as expected! Good job!")
      })*/
});
