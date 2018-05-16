/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Networking;

import certchain.Blockchain;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.net.URL;
import java.util.ArrayList;

/**
 *
 * @author Jorden
 */
public class Node {

    private Socket socket = null;
    private ObjectInputStream inputStream = null;
    private ObjectOutputStream outputStream = null;
    private boolean isConnected = false;
    ArrayList<String> ipAddresses = new ArrayList<>();
    int count = 0;
    public Node() {

    }

    public void send(Blockchain blockchain) {

        while (!isConnected) {
            try {
                URL ipAddress = new URL("http://checkip.amazonaws.com");
                BufferedReader reader = new BufferedReader(new InputStreamReader(ipAddress.openStream()));
                String ip = reader.readLine();
                InetAddress inet = InetAddress.getByName(ip);
                socket = new Socket(inet, 4847);
                if (!ipAddresses.contains(ip)){
                    ipAddresses.add(ip);
                }
                System.out.println("Connected");
                isConnected = true;
                outputStream = new ObjectOutputStream(socket.getOutputStream());
                System.out.println("Object to be written = " + blockchain);
                outputStream.writeObject(blockchain);
            } catch (SocketException se) {
                se.printStackTrace();
// System.exit(0);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    
    public void receive(){
        try {
            String ip = ipAddresses.get(count);
            InetAddress inet = InetAddress.getByName(ip);
            ServerSocket serverSocket = new ServerSocket(4847,50,inet);
            Socket socket = serverSocket.accept();
            System.out.println("Connected");
            ObjectInputStream inStream = new ObjectInputStream(socket.getInputStream());
            Blockchain blockchain = (Blockchain) inStream.readObject();
            System.out.println("Object received = " + blockchain);
            socket.close();

        }
         catch (SocketException se) {
             if (count < ipAddresses.size()-1){
                count++;
                receive();
             }
             else{
                 count = 0;
                 receive();//try again until got connection
             }
        }
          catch (Exception e) {
            e.printStackTrace();
        }
    }
}
