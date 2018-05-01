/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Transactions;
import Blockchain.Main;
import java.security.*;
import java.util.ArrayList;
/**
 *
 * @author Jorden
 */
public class Transaction {
    public String transactionId; // this is the hash of the transaction.
    public PublicKey sender;
    public PublicKey reciepient;
    public float value;
    public byte[] signature; 

    public ArrayList<TransactionInput> inputs = new ArrayList<TransactionInput>();
    public ArrayList<TransactionOutput> outputs = new ArrayList<TransactionOutput>();

    private int count = 0; // a rough count of how many transactions have been generated. 

    public Transaction(PublicKey from, PublicKey to, float value,  ArrayList<TransactionInput> inputs) {
            this.sender = from;
            this.reciepient = to;
            this.value = value;
            this.inputs = inputs;
    }

    // This Calculates the transaction hash (which will be used as its Id)
    private String calulateHash() {
            count++; //increase count to avoid 2 identical transactions having the same hash
            return StringUtil.applySha256(
                            StringUtil.getStringFromKey(sender) +
                            StringUtil.getStringFromKey(reciepient) +
                            Float.toString(value) + count);
    }
    public void generateSignature(PrivateKey privateKey) {
    String data = StringUtil.getStringFromKey(sender) + StringUtil.getStringFromKey(reciepient) + Float.toString(value)	;
    signature = StringUtil.applyECDSASig(privateKey,data);		
}

    public boolean verifiySignature() {
            String data = StringUtil.getStringFromKey(sender) + StringUtil.getStringFromKey(reciepient) + Float.toString(value)	;
            return StringUtil.verifyECDSASig(sender, data, signature);
    }
    
    public boolean processTransaction() {		
        if(verifiySignature() == false) {
                System.out.println("Transaction Signature failed to verify");
                return false;
        }

        for(TransactionInput i : inputs) {
            TransactionOutput utxo = i.getUTXO();
        }


        float leftOver = getInputsValue() - value; //get value of inputs then the left over change:
        transactionId = calulateHash();
        outputs.add(new TransactionOutput( this.reciepient, value,transactionId)); //send value to recipient
        outputs.add(new TransactionOutput( this.sender, leftOver,transactionId)); //send the left over 'change' back to sender		

        for(TransactionOutput o : outputs) {
                Main.UTXOs.put(o.id , o);
        }

        for(TransactionInput i : inputs) {
                if(i.getUTXO() == null){
                    Main.UTXOs.remove(i.getUTXO().id);
                }   
        }
        return true;
    }

    public float getInputsValue() {
            float total = 0;
            for(TransactionInput i : inputs) {
                    if(i.getUTXO() == null) continue; //if Transaction can't be found skip it 
                    total += i.getUTXO().value;
            }
            return total;
    }

    public float getOutputsValue() {
            float total = 0;
            for(TransactionOutput o : outputs) {
                    total += o.value;
            }
            return total;
    }
}