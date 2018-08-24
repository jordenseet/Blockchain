1) Manager design
The manager is not a central point of control, rather it acts as a memory pool to receive information from other wallets. This is more efficient than updating, for example CommunityVotingMinNumber, as all wallets will have the same state of CommunityVotingMinNumber. If decentralised across nodes, this can be very computationally expensive.

unlockedAccounts is internal simply to make it harder for malicious actors in querying the information.
 