CoolWallet is supposed to be a decentralised wallet - Its not yet. I'm basically trying to implement all sorts of functionalities in this wallet.

WalletManager is needed to manage wallets of a group. Think of it like sharding, where each WalletManager is a sidechain. Each Wallet is a node.
While sharding is used to speed up transactions, this is to keep gas costs low.

You can make multiple WalletManagers, similar to how you can make multiple sidechains. I have not thought of how and why would I link different WalletManagers up though, so a "mainchain" is not done.

CoolWallets can do the following things:
1) Vote (To freeze or abandon all wallets)
2) Send transactions by the masses
3) Uses an Oracle to convert USD-ETH rates

Future edits will include:
1) Full decentralisation (Now its partial, any freeze or destroying of wallets require the Wallet manager to activate the function. Without a 50% consensus to freeze or abandon, the WalletManager cannot arbitrarily freeze or destroy wallets).
2) MultiSig wallets