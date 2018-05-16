# blockchain_programming_using_javascript
how to implement the core engine of the Blockchain in Javascript using Node.
# Function 
## transactions
It is used to transfer amount from A to B 

Action: POST

		{
			"from" : "Jack",
			"to":"Harry",
			"amount":150
		}
## mine 
It is used to put transaction into a block. 

Action : GET

result :

            {
                "index": 2,
                "previousHash": "000b5023e7d4ee80e44cddf3306612d21ee57b682ae29b8256e02af9e77b449e",
                "hash": "000643132bb3e9706d4354a45292a984b0ea97c1767bc7f4afac0d6f3a816a05",
                "nonce": 6280,
                "transactions": [
                    {
                        "from": "Jack",
                        "to": "Harry",
                        "amount": 150
                    }
                ]
            }
## blockchain
	
It is used to get all nodes of blockchain.

Action : GET

Result:

		{
			"blocks": [
				{
					"index": 0,
					"previousHash": "00000000000000000",
					"hash": "000d0b2c8e69ed062e59fa2a404af03424613fda5044395d3b1e7f5ea9ea97b2",
					"nonce": 2684,
					"transactions": []
				},
				{
					"index": 1,
					"previousHash": "000d0b2c8e69ed062e59fa2a404af03424613fda5044395d3b1e7f5ea9ea97b2",
					"hash": "000b5023e7d4ee80e44cddf3306612d21ee57b682ae29b8256e02af9e77b449e",
					"nonce": 4352,
					"transactions": []
				},
				{
					"index": 2,
					"previousHash": "000b5023e7d4ee80e44cddf3306612d21ee57b682ae29b8256e02af9e77b449e",
					"hash": "000643132bb3e9706d4354a45292a984b0ea97c1767bc7f4afac0d6f3a816a05",
					"nonce": 6280,
					"transactions": [
						{
							"from": "Jack",
							"to": "Harry",
							"amount": 150
						}
					]
				}
			]
		}
## resolve
It is used to sync Blockchian with other Blockchian

Action : POST
  	
## /nodes/register
It is used register other blockahin. 

For example:
 Current blockchain is localhost:3000. 
 localhost:3001 and localhost:3002 registered with localhost:3000.  
 Action : POST

        {
        	"urls" : [
        		{ "url" : "localhost:3001"},
        		{ "url" : "localhost:3002"}
        		]
        }
	
## Contributor

Kenneth Hu 	
	