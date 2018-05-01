package Blockchain;


import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author Jorden
 */
public class Certificate {
    private int index;
    private long timestamp;
    //for easier manipulation, would always cast to Date before toString
    private String hash;
    private String previousHash;
    private int nonce;
    private Student student;
    private School school;

    public Certificate(int index, long timestamp, String previousHash, Student student, School school) {
        this.index = index;
        this.hash = hash;
        this.previousHash = previousHash;
        this.student = student;
        this.school = school;
        hash = Certificate.produceHash(this);
    }

    public int getIndex() {
        return index;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public String getHash() {
        return hash;
    }

    public String getPreviousHash() {
        return previousHash;
    }

    public int getNonce() {
        return nonce;
    }

    public Student getStudent() {
        return student;
    }

    public School getSchool() {
        return school;
    }
    
    public String toString() {
        return "Block{" + "index=" + index + ", timestamp=" + new Date(timestamp) + ", hash=" + hash + ", previousHash=" + previousHash + ", student=" +student.getId() + ", school=" + school.getId() + ", nonce=" + nonce + '}';
    }
    
    public String prevCertInfo() {
        return index + timestamp + previousHash + student.getId() + school.getId() + nonce;
    }
    
        public static String produceHash(Certificate cert) {
        if (cert != null) {
            MessageDigest digester = null;

            try {
                digester = MessageDigest.getInstance("SHA-256");
            } catch (NoSuchAlgorithmException e) {
                return null;
            }

            String prevCert = cert.prevCertInfo();
            byte[] bytes = digester.digest(prevCert.getBytes());
            String hash = "";

            for (byte b : bytes) {
                String hex = Integer.toHexString(0xff & b);
                //"0xff &" is needed to mask out zeroes from conversion
                if (hex.length() == 1) {
                    hex += "0";
                }

                hash += hex;
            }

            return hash;
        }
        return null;
    }
        
    public void mineCert(int difficulty) {
        nonce = 0;
        String proof = "";
        for (int i = 0; i < difficulty;i++){
            proof += "0";
        }
        while (!getHash().substring(0, difficulty).equals(proof)) {
            nonce++;
            hash = Certificate.produceHash(this);
        }
    }
}
