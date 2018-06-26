var Dish = artifacts.require('Dish')

contract('Dish', function(accounts) {

    const owner = accounts[0]
    const alice = accounts[1] //alice is the buyer
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    var dishNumber
    const price = web3.toWei(1, "ether")

    it("should add an order with the provided name and price", async() => {
        const dish = await Dish.deployed()

        var eventEmitted = false

        var event = dish.Preparing()
        await event.watch((err, res) => {
            dishNumber = res.args.dishNumber.toString(10)
            eventEmitted = true
        })

        const name = "Chicken Rice"

        await dish.addDish(name, price, {from: alice})

        const result = await dish.fetchDish.call(dishNumber)

        assert.equal(result[0], name, 'the name of the last added item does not match the expected value')
        assert.equal(result[2].toString(10), price, 'the price of the last added item does not match the expected value')
        assert.equal(result[3].toString(10), 0, 'the state of the item should be "Preparing", which should be declared first in the State Enum')
        assert.equal(result[4], owner, 'the address adding the item should be listed as the restaurant owner')
        assert.equal(result[5], alice, 'the buyer address should be set to the buyer when an item is added')
        assert.equal(eventEmitted, true, 'adding an item should emit a For Sale event')
    })

    it("should allow the seller to mark the item as Delivering", async() => {
        const dish = await Dish.deployed()

        var eventEmitted = false

        var event = dish.Delivering()
        await event.watch((err, res) => {
            dishNumber = res.args.dishNumber.toString(10)
            eventEmitted = true
        })

        await dish.preparedDish(dishNumber, {from: owner})

        const result = await dish.fetchDish.call(dishNumber)

        assert.equal(eventEmitted, true, 'adding an item should emit a Shipped event')
        assert.equal(result[3].toString(10), 1, 'the state of the item should be "Delivering", which should be declared third in the State Enum')
    })

    it("should allow the seller to mark the item as AwaitingPayment", async() => {
        const dish = await Dish.deployed()

        var eventEmitted = false

        var event = dish.AwaitingPayment()
        await event.watch((err, res) => {
            dishNumber = res.args.dishNumber.toString(10)
            eventEmitted = true
        })

        await dish.reachedDestination(dishNumber, {from: owner})

        const result = await dish.fetchDish.call(dishNumber)

        assert.equal(eventEmitted, true, 'adding an item should emit an AwaitingPayment event')
        assert.equal(result[3].toString(10), 2, 'the state of the item should be "AwaitingPayment", which should be declared 3rd in the State Enum')
    })

    it("should allow someone to purchase a dish", async() => {
        const dish = await Dish.deployed()

        var eventEmitted = false

        var event = dish.Paid()
        await event.watch((err, res) => {
            dishNumber = res.args.dishNumber.toString(10)
            eventEmitted = true
        })

        const amount = web3.toWei(2, "ether") //pay extra

        var ownerBalanceBefore = await web3.eth.getBalance(owner).toNumber()
        var buyerBalanceBefore = await web3.eth.getBalance(alice).toNumber()

        await dish.pay(dishNumber, {from: alice, value: amount})

        var ownerBalanceAfter = await web3.eth.getBalance(owner).toNumber()
        var buyerBalanceAfter = await web3.eth.getBalance(alice).toNumber()

        const result = await dish.fetchDish.call(dishNumber)

        assert.equal(result[3].toString(10), 3, 'the state of the item should be "Paid", which should be declared 4th in the State Enum')
        assert.equal(result[5], alice, 'the buyer address should be set when he/she purchases an item')
        assert.equal(eventEmitted, true, 'adding an item should emit a Paid event')
        assert.equal(ownerBalanceAfter, ownerBalanceBefore + parseInt(price, 10), "buyer's balance should be increased by the price of the item")
        assert.isBelow(buyerBalanceAfter, buyerBalanceBefore - price, "buyer's balance should be reduced by more than the price of the item (including gas costs)")
    })
});
