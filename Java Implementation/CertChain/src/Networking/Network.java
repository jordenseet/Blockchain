/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Networking;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.util.ArrayList;

/**
 *
 * @author Jorden
 */
public class Network {

    private int port;
    private ArrayList<Node> nodes;
    public Thread serverThread;
    private boolean serverIsRunning;
    private ServerSocket server;
    private Socket socket = null;

    public Network(int port) {
        this.port = port;
        nodes = new ArrayList<>();
        serverThread = new Thread(new Runnable() {
            public void run() {
                try {
                    listen();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    public void start() {
        if (serverThread.isAlive()) {
            return;
        }
        serverIsRunning = true;
        serverThread.start();
    }

    public void stop() throws IOException {
        serverIsRunning = false;
        try {
            serverThread.interrupt();
            socket.close();
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }

    public void listen() throws IOException, SocketTimeoutException {
        server = new ServerSocket(this.port);
        Node node;
        server.setSoTimeout(10000);
        while (serverIsRunning) {
            try {
                socket = server.accept();
                node = new Node(socket);
                nodes.add(node);
            } catch (SocketTimeoutException e) {
                //e.printStackTrace();
            }

        }
    }
    
}
