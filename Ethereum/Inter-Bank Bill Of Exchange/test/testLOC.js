var LetterOfCredit = artifacts.require('LetterOfCredit')


contract('LetterOfCredit', function(accounts) {

    const exporter = accounts[0]
    const importer = accounts[1]
    const shipper = accounts[2]

    // Test if bill can be set correctly
    it("It should set a Bill of Exchange correctly", async() => {
      var paymentAmount
      var holder
      const loc = await LetterOfCredit.deployed()
      var eventEmitted = false
      await loc.createBOE(exporter,importer,shipper,50)

      var event = loc.BOESet()
      await event.watch((err, res) => {
          paymentAmount = res.args.paymentAmt
          holder = res.args.exporter //Event emitted by Solidity should contain the exporter = holder as defined in line 16.
          eventEmitted = true
      })
      await loc.setBillOfExchangePrice(1 * Math.pow(10,18))
      assert.equal(holder, exporter, 'The Bill of Exchange holder is incorrectly set')
      assert.equal(paymentAmount, 1 * Math.pow(10,18), 'The Bill of Exchange payment amount is incorrectly set')//should equal to set amount in line 24
      console.log("Bill of Exchange set correctly! Good job!")
    })
    //Test if BOE can be exercised
    it("It should exercise a Bill of Exchange correctly", async() => {
        var holder
        const loc = await LetterOfCredit.deployed()
        await loc.createBOE(exporter,importer,shipper,50)
        var eventEmitted = false
        var event = loc.BOEExercised()
        await event.watch((err, res) => {
            holder = res.args.newHolder
            eventEmitted = true
        })

    await loc.exerciseBillOfExchange({from:importer, value:1 * Math.pow(10,18)}) // exercised by a new holder

    assert.equal(holder, importer, 'The new Bill of Exchange holder is incorrectly set')//test if new holder is updated correctly
    console.log("Bill of Exchange exercised correctly! Good job!")
    })

    it("It should produce a Certificate of Inspection upon arrival to dock", async() => {
      var certStatus
      var dateTime
      var shipStatus
      const loc = await LetterOfCredit.deployed()
      loc.createBOE(exporter,importer,shipper,50)
      var eventEmitted = false
      loc.completeShipment({from:shipper}) //indicate that shipment has arrived

      var event = loc.CertificationDone()
      await event.watch((err, res) => {
          certStatus = res.args.certified //will return true if certified
          dateTime = res.args.date // = now
          shipStatus = res.args.status // Should reflect as Collected rather than "In-Port"
          eventEmitted = true
      })
      await loc.certifyCertOfInspection({from:importer, value: 50}) //

      assert.equal(certStatus, true, 'The Certificate of Inspection has not been issued') //default certStatus is false, hence it is only = true if it really passes
      assert.equal(dateTime,(Math.floor(new Date().getTime()/1000)),"There is a discrepancy in the time recorded as certified") //used JavaScript to calculate time to ensure time is not hardcoded in
      assert.equal(shipStatus, "Collected", 'The item status indicates that it has not been collected yet')// default status is "In-Port" until collected

      console.log("Certification of Inspection done correctly! Good job!")
    })
});
