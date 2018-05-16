const Block = require('./block');
const Blockchian = require('./blockchain');
const Transaction = require('./transaction');
const BlockchianNode = require('./BlockchainNode');

const fetch = require('node-fetch');

const express = require('express');
const app = express();
const bodyparser = require("body-parser");

let transactions = [];
let nodes = [];
let genesisBlock = new Block();
let blockchain = new Blockchian(genesisBlock);

let port = 3000;

//access the arguments
process.argv.forEach(function(val, index, array){
    console.log(array);
    port= array[2];
});

if(port == undefined){
    port = 3000;
}



app.use(bodyparser.json());

app.get('/resolve', function(req, res){

    nodes.forEach(function(node){
        fetch(node.url + '/blockchain')
        .then(function(response){
            return response.json();
        })
        .then(function(otherNodeBlockchain){
            console.log(otherNodeBlockchain);
            if(blockchain.blocks.length < otherNodeBlockchain.blocks.length){
                blockchain = otherNodeBlockchain;
            }

            res.send(blockchain);
        })
    });
});

app.post('/nodes/register', function(req,  res){

    let nodesLists = req.body.urls;
    nodesLists.forEach(function(nodeDictionary){
        let node = new BlockchianNode(nodeDictionary["url"]);
        nodes.push(node);
    })

    res.json(nodes);
});

app.get('/nodes', function(req, res){
    res.json(nodes);
});

app.get("/", function(req, res){
    res.send("hello world");
});

app.get('/mine', function(req, res){

    let block = blockchain.getNextBlock(transactions);
    blockchain.addBlock(block);
    transactions = [];
    res.json(block);
});

app.post('/transactions', function(req, res){

    let to = req.body.to;
    let from = req.body.from;
    let amount = req.body.amount;

    let transaction = new Transaction(from, to, amount);
    console.log(JSON.stringify(req.body));
    console.log(req.body.to);
    console.log(req.body.from);
    console.log(req.body.amount);

    transactions.push(transaction);

    res.json(transaction);
});

app.get('/blockchain', function(req, res){


    console.log(blockchain);
    res.json(blockchain);
});

app.listen(port, function(){
    console.log("port : " + port);
    console.log("server has started");
});
