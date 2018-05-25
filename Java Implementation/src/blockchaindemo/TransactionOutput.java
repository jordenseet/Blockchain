/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package blockchaindemo;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.PublicKey;
import java.util.Base64;

/**
 *
 * @author Jorden
 */

public class TransactionOutput {

    public String id;
    public PublicKey recipient;
    public float value; //the amount of coins they own
    public String parentTransactionId; //the id of the transaction this output was created in

    //Constructor
    public TransactionOutput(PublicKey recipient, float value, String parentTransactionId) {
        this.recipient = recipient;
        this.value = value;
        this.parentTransactionId = parentTransactionId;
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String calculatedHash
                    = Base64.getEncoder().encodeToString(recipient.getEncoded())
                    + Float.toString(value)
                    + parentTransactionId;
            byte[] hash = digest.digest(calculatedHash.getBytes(StandardCharsets.UTF_8));
            this.id = hash.toString();
        } catch (Exception e) {
            e.printStackTrace();
            ;
        }
    }

    //Check if coin belongs to you
    public boolean isMine(PublicKey publicKey) {
        return (publicKey == recipient);
    }

}
