/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Application;

import Networking.Node;
import certchain.Block;
import certchain.Blockchain;
import certchain.Certificate;
import java.util.HashMap;
import java.util.Scanner;

/**
 *
 * @author Jorden
 */
public class Application {
    public static void main(String[]args){
        int difficulty = 2;
        Scanner s = new Scanner(System.in);
        HashMap<String, String> grades = new HashMap<String,String>();
        Node node = new Node();
        node.receive();//resembles git pull
        //implement check here to eliminate conflicting sending of blockchain
        System.out.println("Add a new certificate into the Certchain");
        System.out.println("What's his student Id?");
        String id = s.nextLine();
        System.out.println("Whats his school Id?");
        String schoolId = s.nextLine();
        boolean done = false;
        while (!done){
            System.out.println("Enter the subject name");
            String subject = s.nextLine();
            System.out.println("Enter the subject grade");
            String grade = s.nextLine();
            grades.put(subject, grade);
            System.out.println("Do you want to add more grades? Answer in Y or N");
            if (s.nextLine().equals("N")){
                done = true;
            }
        }

        Certificate certificate = new Certificate(id, schoolId,grades);
        Blockchain blockchain = new Blockchain();
        blockchain.addCertificate(certificate);
        if(blockchain.mine(difficulty)){
            node.send(blockchain);
        }
    }
    
}
