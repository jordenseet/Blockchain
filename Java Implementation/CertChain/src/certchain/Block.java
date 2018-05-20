package certchain;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Base64;

public class Block implements Serializable {

    private transient Block previousBlock;
    private byte[] previousHash;
    private byte[] currentHash;
    private ArrayList<Certificate> certificates;

    public Block() {
        certificates = new ArrayList<>();
        if (currentHash == null){
            try{
                MessageDigest digest = MessageDigest.getInstance("SHA-256");
                ByteArrayOutputStream toSerialize = new ByteArrayOutputStream();
                byte[] bytes = toSerialize.toByteArray();
                currentHash = digest.digest(bytes); //genesis block
            }
           catch(Exception e){
               System.out.println("Block failed to create");
               e.printStackTrace();
           }
        }
    }

    public byte[] getPreviousHash() {
        return previousHash;
    }

    public void setPreviousHash(byte[] prevHash) {
        this.previousHash = prevHash;
    }

    public byte[] getCurrentHash() {
        return currentHash;
    }

    public void setCurrentHash(byte[] _currentHash) {
        currentHash = _currentHash;
    }

    public Block getPreviousBlock() {
        return previousBlock;
    }

    public void setPreviousBlock(Block _previousBlock) {
        previousBlock = _previousBlock;
    }

    public ArrayList<Certificate> getCertificates() {
        return certificates;
    }

    public void setCertificates(ArrayList<Certificate> _certificates) {
        certificates = _certificates;
    }

    public void addCertificate(Certificate _certificate) {
        certificates.add(_certificate);
        currentHash = produceHash();
    }

    public byte[] produceHash() {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            ByteArrayOutputStream toSerialize = new ByteArrayOutputStream();
            byte[] bytes = toSerialize.toByteArray();
            return digest.digest(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean mine(int difficulty) {
        String proof = "";
        for (int i = 0; i < difficulty;i++){
            proof += "0";
        }
        try{
            String currHash = new String(getCurrentHash(),"UTF-8");
            System.out.println("Mining the block... please wait");
            return true;
            /*while (!currHash.substring(0, difficulty).equals(proof)) {
                MessageDigest digest = MessageDigest.getInstance("SHA-256");
                byte[] hash = digest.digest(currHash.getBytes(StandardCharsets.UTF_8));
                currentHash = hash;
                System.out.println("Still mining...");
            }
        return true;*/
        }
        catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }
}