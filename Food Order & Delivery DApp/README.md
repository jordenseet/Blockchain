Food Order & Delivery DApp
The purpose of this DApp is to allow a buyers to purchase dishes from a restaurant.

This DApp will allow buyers to purchase an dish and for the restaurant owner to receive ether from the sale. It will also emit events so that the front-end JavaScript will be able to update the relevant status of the item. It is a simple Proof-of-Concept.

The events covered here are:
Preparing food (Order is called by Buyer)
Delivery (Order is indicated as sent out via Seller)
AwaitingPayment (Order is indicated as awaiting payment by Seller)
Paid (Order is indicated as paid by the Buyer) --> Assumption: Buyer has to click on pay in front of the Seller or he doesn't get his food, hence Buyer cannot claim that he had paid prior to delivery <--


## Test
To verify that, run `truffle test` to run the test suite.

This assumes you already have the truffle suite installed, if not run npm install -g truffle on your command prompt, set to the directory of this project. If you do not have npm installed, download it here: https://nodejs.org/en/
