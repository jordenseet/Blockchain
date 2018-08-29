This project runs on the truffle framework. To get it, please run this command: npm install -g truffle
For testing on private environment, please use Ganache. You can download it here: https://truffleframework.com/ganache
Please ensure that you set Ganache to listen on port 8545.

Library used: OpenZeppelin. To install, run this command: npm install -E openzeppelin-solidity

This project runs on lite-server, please install lite-server on your directory.
Run this command on your directory: npm install lite-server --save-dev
After lite-server has been installed, type this command: npm run dev

After the browser is launched, ensure that you are signed on to Metamask and import your accounts from Ganache accordingly.

After which, we can set up our testing environment. 
To start, run:
1) truffle console --network=development
2) truffle compile
3) truffle migrate (Or run truffle migrate --reset if this is not your first time)
4) truffle test

Test rationale and description are commented on the test cases itself

To create a new Letter Of Credit, simply run: truffle migrate --reset
New migrations deploy new contracts, each of which will represent a new Letter of Credit.
All Letter of Credits will still exist within the blockchain network, and are accessible as long as u have the contract address.

Emergency stop is implemented in line 69 of LetterOfCredit.sol

User Story:
This DApp is used by a Bank that issues the Letter of Credit on the behalf of all parties in a trade finance transaction (Importer, Exporter, Shipper). Every time you start the app, it generates a new Letter of Credit. All Letter of Credits are identifiable by their contract address, and is stored on the blockchain.

As an Exporter, you can refinance the Letter of Credit through a distributed Bill of Exchange, which is also included in the Letter of Credit contract. After setting the price of the distributed Bill of Exchange, the Bill can be sold on the open market as an option.

Investors can then exercise the Bill of Exchange through this dApp. If they have enough funds, they could finance the Letter of Credit, to become the new holder of the Bill. If they do not, then Bill of Exchange will then go into an Auction.

As Shippers fufill their duties of carriage, they could also update status of the good's statements on the blockchain, allowing all parties of the trade fiannce process to be kept updated on the shipment progress. 

Once the goods have arrived in port, Importers can then be updated, for the collection of goods. Through the dApp, importers can then verify and digatally approve the Certificate of Inspection. Upon approval, the smart contract will then attempt a transfer of funds from the importer to the current holder of the bill of exchange. If the transfer of funds is successful, the contract will then approve the release of goods to the importer, end on the trade finance process. 

