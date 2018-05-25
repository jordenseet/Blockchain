Hi all!
This is an implementation of networking protocols in NodeJS.
Here, we are connecting to different ports of the same localhost as a Proof of Concept.

To start off, please ensure you have installed nodejs on your computer.
After git clone (or zip download and extract),
Go to your command line, cd to the directory with all these files.

Please install "js-sha256" in your computer first. 
Run "npm install js-sha256"

-------------------------------------------------------------
Now the fun begins
-------------------------------------------------------------
Run "node app.js " and key in your port number of choice.
So if I wanted to use port 4444, it will be "node app.js 4444"
If you do not choose any, we will use a default port 3000.

You should see 
"server has started on port " and your port number.

The first step is to register new nodes. To do this, open your console and key in this code:

fetch("/nodes/register",
{
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    method: "POST",
    body: JSON.stringify( {
        	"urls" : [
        		{ "url" : "3001"},
        		{ "url" : "3002"}
        		]
        })
})
.then(function(res){ console.log(res) })
.catch(function(res){ console.log(res) })

The "url"'s value (3001,3002) can be changed to your desired port values. You can also add more "urls" if you want.

After that, open up localhost:xxxx, xxx being your port numbers that you chose. In this context, open up localhost:3001 and localhost:3002

The second step is to add new transactions into the nodes. Type this code:

fetch("/transactions",
{
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    method: "POST",
    body: JSON.stringify( {
			"from" : "Jack",
			"to":"Harry",
			"amount":150
		})
})
.then(function(res){ console.log(res) })
.catch(function(res){ console.log(res) })

Of course, you can chance "Jack" and "Harry" to whatever name you like, "amount" to whatever amount you want.
You can make multiple transactions across different nodes, at different times.

After this, you mine. 
To do this, append a /mine to the host that you want to do the mining. 
So if I want localhost:3002 to do the mining, I type localhost:3002/mine
NOTE THAT WE DID NOT IMPLEMENT ANY PoW or PoS or whatever. My laptop will take too long to mine.

After you have mined, you want to see if the blockchain recorded the transaction.
Append a /blockchain in any localhost to see the transaction.
localhost:3001/blockchain

You will see that all the blocks are in sync!!!

Thanks for playing my little demo :)

