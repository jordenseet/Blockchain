/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package PeerToPeer;

/**
 *
 * @author Jorden
 */
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.SocketTimeoutException;


public class Node {

    private Thread peerThread;
    public Socket socket;
    public DataOutputStream out;
    public DataInputStream in;

    public Node(Socket socket) {
        this.socket = socket;
        peerThread = new Thread(new Runnable() {
            public void run() {
                try {
                    listen();
                    System.out.println("Closing connection to " + socket.getInetAddress() + ":" + socket.getPort());
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
        peerThread.start();
    }

    public void listen() throws IOException {
        try {
            DataInputStream in = new DataInputStream(this.socket.getInputStream());
            DataOutputStream out = new DataOutputStream(this.socket.getOutputStream());
        } catch (SocketTimeoutException e) {
            e.printStackTrace();
        }

    }

    public static void send(String data, DataOutputStream out) {
        System.out.println("Sending message: " + data);
        try {
            out.writeUTF(data);
            out.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public String receive(DataInputStream in) {
        String data = null;
        try {
            data = in.readUTF();
            System.out.println("Received message: " + data);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return data;
    }
}
