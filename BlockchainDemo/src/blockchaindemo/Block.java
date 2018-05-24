/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package blockchaindemo;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 * @author Jorden
 */
public class Block {

    public String hash;
    public String previousHash;//record previous hash
    public ArrayList<Transaction> transactions = new ArrayList<>(); //our data will be a simple message.
    private final long timeStamp; //in milliseconds
    private int nonce;
    public String merkleRoot;

    public Block(String previousHash) {
        this.previousHash = previousHash;
        this.timeStamp = new Date().getTime();

        this.hash = calculateHash(); //Making sure we do this after we set the other values.
    }

    //Calculate new hash based on blocks contents
    public String calculateHash() {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String toHash = previousHash + Long.toString(timeStamp) + Integer.toString(nonce) + merkleRoot;
            byte[] hash = digest.digest(toHash.getBytes("UTF-8"));

            StringBuffer hexString = new StringBuffer(); // This will contain hash as hexidecimal
            for (int i = 0; i < hash.length; i++) {
                String hex = Integer.toHexString(0xff & hash[i]);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            System.out.println("Block with hash: " + hash + " created");
            return hexString.toString();

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public void mineBlock(int difficulty) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            int count = transactions.size();

            List<String> previousTreeLayer = new ArrayList<String>();
            for (Transaction transaction : transactions) {
                previousTreeLayer.add(transaction.transactionId);
            }
            List<String> treeLayer = previousTreeLayer;

            while (count > 1) {
                treeLayer = new ArrayList<String>();
                for (int i = 1; i < previousTreeLayer.size(); i += 2) {
                    String combinedHash = (previousTreeLayer.get(i - 1) + previousTreeLayer.get(i));
                    byte[] hash = digest.digest(combinedHash.getBytes("UTF-8"));

                    StringBuffer hexString = new StringBuffer(); // This will contain hash as hexidecimal
                    for (int j = 0; j < hash.length; j++) {
                        String hex = Integer.toHexString(0xff & hash[j]);
                        if (hex.length() == 1) {
                            hexString.append('0');
                        }
                        hexString.append(hex);
                    }

                    treeLayer.add(hexString.toString());
                }
                count = treeLayer.size();
                previousTreeLayer = treeLayer;
            }

            String merkleRoot = (treeLayer.size() == 1) ? treeLayer.get(0) : "";

            String target = new String(new char[difficulty]).replace('\0', '0');
            while (!hash.substring(0, difficulty).equals(target)) {
                nonce++;
                hash = calculateHash();
            }
            System.out.println("Block Mined!!! : " + hash);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean addTransaction(Transaction transaction) {
        //process transaction and check if valid, unless block is genesis block then ignore.
        if (transaction == null) {
            return false;
        }
        if ((!previousHash.equals("0"))) {
            if ((transaction.processTransaction() != true)) {
                System.out.println("Transaction failed to process. Discarded.");
                return false;
            }
        }
        transactions.add(transaction);
        System.out.println("Transaction Successfully added to Block");
        return true;
    }
}
