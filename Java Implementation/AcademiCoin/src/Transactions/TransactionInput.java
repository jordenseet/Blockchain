/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Transactions;

/**
 *
 * @author Jorden
 */
public class TransactionInput {
	private String transactionOutputId; //Reference to TransactionOutputs -> transactionId
	private TransactionOutput UTXO; //Contains the Unspent transaction output
	
	public TransactionInput(String transactionOutputId) {
		this.transactionOutputId = transactionOutputId;
	}

    public String getTransactionOutputId() {
        return transactionOutputId;
    }

    public TransactionOutput getUTXO() {
        return UTXO;
    }
}
