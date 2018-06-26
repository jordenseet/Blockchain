This personal project involves the use of Smart Contracts in replacing paper contracts for the Sports world.
Here, each token is representative of an Agent or Player. For brevity's sake, we shall assume a Player has no bonding relation to an Agent.

Agency.sol contains the Agencies and their Agents. They are used mostly as middlemen to negotiate terms between a Club and their players.

Club.sol contains the Clubs and their Players.

AthleteTransaction.sol contains the movements between Clubs and Players. It also contains the ability to mint/burn new tokens.

SportsCoin.sol contains the coin architecture, including supply and naming.

ModifiedERC721.sol is a modified ERC721 standard to fit in SportsCoin requirements.

ERC721Control.sol contains additional ERC721 standard functions.

SafeMath.sol contains libraries used to prevent overflow and underflow exploits.