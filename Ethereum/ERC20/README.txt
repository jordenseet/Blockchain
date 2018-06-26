The current implementation has been modified to utilise Truffle Framework and Ganache in simulating "Token" transactions.

If you are unfamiliar with Truffle Framework, try their Pet Shop Tutorial here: http://truffleframework.com/tutorials/pet-shop

Otherwise, you need Truffle, Ganache and MetaMask installed.

After cloning the repo (or downloading),

1) Start Ganache
2) open cmd (Command prompt)
3) type "truffle compile"
4) type "truffle migrate"
5) Create custom RPC on metamask listening on port 7545 
	--> Click on the top left hand corner of MetaMask and look for "Custom RPC"
6) type "npm run dev" on your command prompt
7) Have fun playing around
	--> Ganache provides 10 addresses, each corresponding to a wallet. Use these addresses to transfer Tokens to different addresses.
	--> To switch accounts, use Metamask and Create new account. The next account "Account 2" will correspond to the second address on Ganache, so on so forth.
	--> You have a default of 20000 tokens to play with!