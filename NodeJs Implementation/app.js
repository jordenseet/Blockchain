const Block = require('./block');
const Blockchain = require('./blockchain');
const Transaction = require('./transaction');
const BlockchainNode = require('./BlockchainNode');

const fetch = require('node-fetch');

const express = require('express');
const app = express();

const bodyparser = require("body-parser");
app.use(bodyparser.json());

let transactions = [];
let nodes = [];
let genesisBlock = new Block();
let blockchain = new Blockchain(genesisBlock);

let port = 3000;

//let user decide ports
process.argv.forEach(function(val, index, array){
    console.log(array);
    port= array[2]; //array[0] is process.execPath, array[1] is path to executing js file. array[2] is additional CLI args
});

if(port == undefined){
    port = 3000;
}

app.post('/nodes/register', function(req,  res){

    let nodesLists = req.body.urls;
    nodesLists.forEach(function(nodeDictionary){
        let node = new BlockchainNode(nodeDictionary["url"]);
        app.listen(nodeDictionary["url"], function () {
            console.log('now listening on port ' + nodeDictionary["url"] + '!');
          })
        nodes.push(node);
    })

    res.json(nodes);
});

app.get('/nodes', function(req, res){
    res.json(nodes);
});

app.get("/", function(req, res){
    res.send("Welcome to Jorden's NodeJS Blockchain project :) Enjoy your stay! Refer to the README for help");
});

app.get('/mine', function(req, res){

    let block = blockchain.getNextBlock(transactions);
    blockchain.addBlock(block);
    transactions = []; //reset
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
    console.log("server has started on port " + port);
});
