/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Application;

import Networking.Network;
import certchain.Blockchain;
import certchain.Certificate;
import java.util.HashMap;
import java.util.Scanner;
import Networking.Node;
import java.net.InetAddress;
import java.net.Socket;
import java.util.Map;

/**
 *
 * @author Jorden
 */
public class Application {

    static int difficulty = 1;
    static int port = 4487;
    static Node node;

    public static void main(String[] args) {
        boolean exit = false;
        Scanner s = new Scanner(System.in);
        
        //start the network
        Network network = new Network(4487);
        network.start();
        //start node functionalities
        try {
            node = new Node(new Socket(InetAddress.getLocalHost(), port));
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        System.out.println("Welcome to the Inter-School Certificate Blockchain System");

        while (exit == false) {
            try {
               
                System.out.println("Please select an option to proceed");
                System.out.println("1. Add Certificates to the Blockchain");
                System.out.println("2. View a student's records");
                int choice = s.nextInt();

                switch (choice) {
                    case 1:
                        addCertificates();
                        break;
                    case 2:
                        viewRecord();
                        break;
                    default:
                        System.out.println("Invalid choice");
                }

                System.out.println("Would you like to continue using the system? Please answer in Y or N");
                String exitChoice = s.nextLine();
                if (exitChoice.equals("N")) {
                    exit = true;
                    System.out.println("Goodbye World!");
                }

            } catch (Exception e) {
                e.printStackTrace();
            }

        }
    }

    public static void addCertificates() {
        Scanner s = new Scanner(System.in);
        HashMap<String, String> grades = new HashMap<String, String>();
        //implement check here to eliminate conflicting sending of blockchain
        System.out.println("Add a new certificate into the Certchain");
        System.out.println("What's his student Id?");
        String id = s.nextLine();
        System.out.println("Whats his school Id?");
        String schoolId = s.nextLine();
        boolean done = false;
        while (!done) {
            System.out.println("Enter the subject name");
            String subject = s.nextLine();
            System.out.println("Enter the subject grade");
            String grade = s.nextLine();
            grades.put(subject, grade);
            System.out.println("Do you want to add more grades? Answer in Y or N");
            if (s.nextLine().equals("N")) {
                done = true;
            }
        }
        Certificate certificate = new Certificate(id, schoolId, grades);
        Blockchain blockchain = new Blockchain();
        blockchain.addCertificate(certificate);
        if (blockchain.mine(difficulty)) {
            if (!node.send(blockchain)) {
                System.out.println("Unable to connect to IP address");
            } else {
                System.out.println("Successfully wrote new Certificates into the chain!");
            }
        }
    }

    public static void viewRecord() {
        if (!node.receive()){
            System.out.println("Unable to connect to IP address");
        }
        else{
            System.out.println("Successfully downloaded new Certificates into the chain!");
        }
        Scanner s = new Scanner(System.in);
        System.out.println("Please enter the id of the student you would like to search for: ");
        String id = s.nextLine();
        Blockchain currentBlockchain = node.getBlockchain();
        System.out.println(node.getBlockchain());
        for (Certificate cert : currentBlockchain.getPool()) {
            if (cert.getId().equals(id)) {
                System.out.println("Student " + id + " comes from School " + cert.getSchoolId());
                System.out.println(id + "'s grades are as follows: ");
                for (Map.Entry<String, String> grades : cert.getGrades().entrySet()) {
                    String subject = grades.getKey();
                    String grade = grades.getValue();
                    System.out.println(subject + " : " + grade);
                }
            }
        }
    }
}
