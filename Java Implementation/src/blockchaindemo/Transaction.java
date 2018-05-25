/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package blockchaindemo;

import java.nio.charset.StandardCharsets;
import java.security.*;
import java.util.ArrayList;
import java.util.Base64;

/**
 *
 * @author Jorden
 */
public class Transaction {

    public String transactionId; // this is also the hash of the transaction.
    public PublicKey sender;
    public PublicKey recipient;
    public float value;
    public byte[] signature;

    public ArrayList<TransactionInput> inputs = new ArrayList<>();
    public ArrayList<TransactionOutput> outputs = new ArrayList<>();
    //essential due to UTXO model implemeted

    private static int sequence = 0; // count of how many transactions have been generated. 

    public Transaction(PublicKey from, PublicKey to, float value, ArrayList<TransactionInput> inputs) {
        this.sender = from;
        this.recipient = to;
        this.value = value;
        this.inputs = inputs;
    }

    // This Calculates the transaction hash (which will be used as its Id)
    private String calulateHash() {
        sequence++; //increase the sequence to avoid 2 identical transactions having the same hash
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String calculatedHash
                    = Base64.getEncoder().encodeToString(sender.getEncoded())
                    + Base64.getEncoder().encodeToString(recipient.getEncoded())
                    + Float.toString(value) + sequence;
            byte[] hash = digest.digest(calculatedHash.getBytes(StandardCharsets.UTF_8));
            String toReturn = hash.toString();
            return toReturn;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    //Signs all the data we dont wish to be tampered with.
    public void generateSignature(PrivateKey privateKey) {
        String data = Base64.getEncoder().encodeToString(sender.getEncoded()) + Base64.getEncoder().encodeToString(recipient.getEncoded())
                + Float.toString(value);
        Signature dsa;
        try {
            dsa = Signature.getInstance("ECDSA", "BC");
            dsa.initSign(privateKey);
            byte[] strByte = data.getBytes();
            dsa.update(strByte);
            byte[] realSig = dsa.sign();
            signature = realSig;

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    //Verifies the data we signed hasnt been tampered with

    public boolean verifiySignature() {
        String data = Base64.getEncoder().encodeToString(sender.getEncoded()) + Base64.getEncoder().encodeToString(recipient.getEncoded()) + Float.toString(value);
        try {
            Signature ecdsaVerify = Signature.getInstance("ECDSA", "BC");
            ecdsaVerify.initVerify(sender);
            ecdsaVerify.update(data.getBytes());
            return ecdsaVerify.verify(signature);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public boolean processTransaction() {

        if (verifiySignature() == false) {
            System.out.println("Transaction Signature failed to verify");
            return false;
        }

        //gather transaction inputs (Make sure they are unspent):
        for (TransactionInput i : inputs) {
            i.UTXO = Blockchain.UTXOs.get(i.transactionOutputId);
        }

        //check if transaction is valid:
        if (getInputsValue() < Blockchain.minimumTransaction) {
            System.out.println("Transaction Inputs to small: " + getInputsValue());
            return false;
        }

        //generate transaction outputs:
        float leftOver = getInputsValue() - value; //get value of inputs then the left over change:
        transactionId = calulateHash();
        outputs.add(new TransactionOutput(this.recipient, value, transactionId)); //send value to recipient
        outputs.add(new TransactionOutput(this.sender, leftOver, transactionId)); //send the left over 'change' back to sender		

        //add outputs to Unspent list
        for (TransactionOutput o : outputs) {
            Blockchain.UTXOs.put(o.id, o);
        }

        //remove transaction inputs from UTXO lists as spent:
        for (TransactionInput i : inputs) {
            if (i.UTXO == null) {
                continue;
            } //if Transaction can't be found skip it 
            Blockchain.UTXOs.remove(i.UTXO.id);
        }

        return true;
    }

    public float getInputsValue() {
        float total = 0;
        for (TransactionInput i : inputs) {
            if (i.UTXO == null) {
                continue; //if Transaction can't be found skip it 
            }
            total += i.UTXO.value;
        }
        return total;
    }

    public float getOutputsValue() {
        float total = 0;
        for (TransactionOutput o : outputs) {
            total += o.value;
        }
        return total;
    }
}
