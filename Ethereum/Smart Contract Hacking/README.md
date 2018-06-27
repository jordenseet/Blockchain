This is meant to be my code submissions for the Ethernaut CTF.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CoinFlip
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CoinFlipAttack.sol is my code that intialises the target exploitable contract within my own malicious contract.
The idea is to generate 10 consecutive flips in the CoinFlip contract. To achieve this within the contract itself is nearly impossible.

What I did was to instantiate my own malicious contract that will initialise a CoinFlip contract with the target instance address (provided by Ethernaut CTF)
This ensures that the CoinFlip contract created here will point to that address.

My malicious contract has a predict() function that would derive the answer to the coin flip before hand, before passing that answer into the CoinFlip contract as my guess. This is possible as the answer to each coin flip is deterministic --> it is dependent on the latest block header hash. Hence, we can easily determine the answer in a seperate function before passing it into the CoinFlip contract's guess function automatically.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Telephone
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TelephoneAttack is about using contracts to pivot and "spoof" your txn.origin identity. You create a malicious contract class that instantiates the target vulnerable contract. By using the malicious contract class to call the vulnerable contract's functions, you create a divergence between txn.origin and msg.sender. This is useful for phishing attacks.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Force
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Force is pretty simple. It tests your knowledge on the selfdestruct low-level function of Solidity, as well as your alertedness in using payable modifiers.
You instantiate the malicious class with a payable constructor so that you can send funds to the victim contract immediately upon selfdestruct.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------