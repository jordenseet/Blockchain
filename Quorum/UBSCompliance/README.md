=========================================================================================================================================================================
Welcome to the UBS Compliance Decentralised Application Proof-of-Concept

The Proof-of-concept works in two angles:
1) As a Private Ethereum Blockchain network (PEB)
2) As a Quorum network
    --> Quorum has some bugs in their latest version, I will go through the expected observations later

The benefits of using this over existing measures is as such:
1) DDoS protection
2) Fraud proof data (Data cannot be tampered once inserted into the blockchain)
3) Reduction of bureaucracy in administration
4) Data Privacy
    --> Access control is implemented at the protocol layer for Quorum (Unauthorised users cannot read information even after hacking into the network)
    --> Access control is implemented at the Smart Control layer for PEB (Authorised users can read information if successfully hacked into the network)

The following assumptions are made:
1) Proper interface level access control measures are taken to prevent customers from reading information from the blockchain network. They can only interact with the website.
2) Nodes that has access to the blockchain network layer are privy to all data. Proper access control measures must be taken by UBS to restrict access.
3) Address generation for each customer is only made available after passing online KYC. This prevents malicious attackers from creating many accounts and flooding the network with requests, although the network is likely to be able to withstand it.
=========================================================================================================================================================================
1. Pre-requisites
You are expected to have the following software installed:
- Virtualbox
- Vagrant
- Git
- Truffle
=========================================================================================================================================================================
2. Setting up environment
==> First node
Open a new command prompt or bash in the directory you cloned my repository into.
Type the following commands:
cd UBSCompliance
cd quorum-examples
vagrant up (This will take a while)
vagrant ssh (This will take you inside the Vagrant virtual machine)
cd quorum-examples/7nodes/
sudo ./raft-init.sh
sudo ./raft-start.sh
geth attach qdata/dd1/geth.ipc

==> Fourth node (not privy to information in Quorum)
Open a new command prompt or bash in the directory you cloned my repository into.
Type the following commands:
cd UBSCompliance
cd quorum-examples
vagrant ssh (This will take you inside the Vagrant virtual machine)
cd quorum-examples/7nodes/
sudo ./raft-start.sh
geth attach qdata/dd4/geth.ipc

==> Seventh node (privy to information in Quorum)
Open a new command prompt or bash in the directory you cloned my repository into.
Type the following commands:
cd UBSCompliance
cd quorum-examples
vagrant ssh (This will take you inside the Vagrant virtual machine)
cd quorum-examples/7nodes/
sudo ./raft-start.sh
geth attach qdata/dd7/geth.ipc

==> Node 1 interface
Open a new command prompt or bash in the directory you cloned my repository into.
cd UBSCompliance
cd UBSComplianceApp
truffle compile
truffle migrate
truffle console

==> Node 4 interface
Open a new command prompt or bash in the directory you cloned my repository into.
cd UBSCompliance
cd UBSComplianceApp
truffle compile
truffle migrate
truffle console --network nodefour

==> Node 7 interface
Open a new command prompt or bash in the directory you cloned my repository into.
cd UBSCompliance
cd UBSComplianceApp
truffle compile
truffle migrate
truffle console --network nodeseven

=========================================================================================================================================================================
3. Proof-of-Concept (PEB)
==> Deploying contract in Node 1
Go to Node 1 interface
UBSComplianceApp.new()
- Remember the address seen in the second last row - That is your contract address. Referred to as <contractAddress>

==> Adding Node 7 as an authorised personnel
UBSComplianceApp.at("<contractAddress>").approvePersonnel("0xa9e871f88cbeb870d32d88e4221dcfbd36dd635a")

Go to Node 4 interface (Node 4 plays the role of a Customer)
==> Add a new customer
UBSComplianceApp.at("<contractAddress>").addCustomer("Andrew",23,4000)

==> Try view customer details
UBSComplianceApp.at("<contractAddress>").getCustomer("0x9186eb3d20cbd1f5f992a950d808c4495153abd5")
--> You will notice that you cannot view the customer details as Node 4 is not an authorised personnel

==> Try to DDoS network by creating multiple accounts rapidly
UBSComplianceApp.at("<contractAddress>").addCustomer("Alex",25,3500)
--> You will notice that due to restrictions on addresses, you can only create one account per address, increasing difficulty of a DDoS attack. 

Go to Node 7 interface (Node 7 plays the role of an authorised node)
UBSComplianceApp.at("<contractAddress>").getRiskStatus("0x9186eb3d20cbd1f5f992a950d808c4495153abd5")
--> You will see you can view the details.
=========================================================================================================================================================================
4. Proof-of-Concept (Quorum)
! Due to a bug in the latest version, the code will not work as intended. I will outline the expected results here !
Go to Fourth Node (The one with Geth)

==> Getting latest block height
web3.eth.blockNumber
--> Henceforth refer to the block height as blockNumber 
web3.getBlock(blockNumber)
--> You will notice that the transaction hash is obscured. Without the transaction hash, you cannot probe any details from the blockchain, such as contract addresses.

Go to Seventh Node
web3.getBlock(blockNumber)
--> You will notice that the transaction hash is not obscured. You can now derive further details via the transaction hash
web3.getTransactionReceipt("transactionhash")
--> Here, you will see that the contract address is available. This is because the node is authorised. Now, you can use the contract address and call functions such as getRiskStatus("<customerAddress>").
--> Without the transaction hash (if it is obscured) other data will also be obscured and you cannot get this end state
=========================================================================================================================================================================