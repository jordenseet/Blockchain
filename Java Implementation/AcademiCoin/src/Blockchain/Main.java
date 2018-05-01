package Blockchain;


import Transactions.StringUtil;
import Transactions.Transaction;
import Transactions.TransactionOutput;
import Transactions.Wallet;
import java.security.Security;
import java.util.ArrayList;
import java.util.HashMap;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author Jorden
 */
public class Main {
    public static ArrayList<Certificate> certchain = new ArrayList<Certificate>();
    public static int difficulty = 5;
    public static Wallet walletA;
    public static Wallet walletB;
    public static HashMap<String,TransactionOutput> UTXOs = new HashMap<String,TransactionOutput>();
    
    public static void main(String[] args){
        
        System.out.println("Welcome to AcademiCoin");
        CertChain cc = new CertChain(2);
        HashMap<String,String> testGrades1 = new HashMap<String,String>();
        testGrades1.put("OBHR101", "A+");
        testGrades1.put("IS200", "B");
        testGrades1.put("STAT151", "C-");
        HashMap<String,String> testGrades2 = new HashMap<String,String>();
        testGrades2.put("OBHR101", "A");
        testGrades2.put("IS200", "B-");
        testGrades2.put("STAT151", "C+");
        HashMap<String,String> testGrades3 = new HashMap<String,String>();
        testGrades3.put("OBHR101", "A-");
        testGrades3.put("IS200", "B+");
        testGrades3.put("STAT151", "C");
        Student s1 = new Student("Wew","S9787878K",testGrades1);
        Student s2 = new Student("Waw","S9767676L",testGrades2);
        Student s3 = new Student("Wow","S9777777M",testGrades3);
        School sch = new School("SMU","S09090");
        School sch2 = new School("SIS","S11111");
        cc.addCert(cc.newCert(s1,sch));
        cc.addCert(cc.newCert(s2,sch2));
        cc.addCert(cc.newCert(s3,sch));
        
        System.out.println("Certchain valid? " + cc.isCertChainValid());
        System.out.println(cc);
        
        //Test Validity after corruption
        cc.addCert(new Certificate(15,System.currentTimeMillis(),"aaaa",s1,sch));
        System.out.println("After adding invalid cert, is certchain valid? " + cc.isCertChainValid());
        
        System.out.println("Querying for student number 2");
        System.out.println(cc.getCert(2).getStudent().getGrades());
        System.out.println("Querying for student number 3's IS200 grade");
        System.out.println(cc.getCert(3).getStudent().getGrade("IS200"));
        
        System.out.println("Test Transations");
        Security.addProvider(new org.bouncycastle.jce.provider.BouncyCastleProvider()); 
        //Create the new wallets
        walletA = new Wallet();
        walletB = new Wallet();
        //Test public and private keys
        System.out.println("Private and public keys:");
        System.out.println(StringUtil.getStringFromKey(walletA.privateKey));
        System.out.println(StringUtil.getStringFromKey(walletA.publicKey));
        //Create a test transaction from WalletA to walletB 
        Transaction transaction = new Transaction(walletA.publicKey, walletB.publicKey, 5, null);
        transaction.generateSignature(walletA.privateKey);
        //Verify the signature works and verify it from the public key
        System.out.println("Is signature verified");
        System.out.println(transaction.verifiySignature());
}
}
