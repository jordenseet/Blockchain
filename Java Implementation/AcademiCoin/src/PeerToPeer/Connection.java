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
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.util.ArrayList;

public class Connection {

    private int port;
    private ArrayList<Node> nodes;
    private DataOutputStream outputStream;
    public Thread serverThread;
    private boolean runningServer;
    private ServerSocket server;
    private Socket socket = null;

    public Connection(int port) {
        this.port = port;
        nodes = new ArrayList<>();
        serverThread = new Thread(new Runnable() {
            public void run() {
                try {
                    listen();
                    System.out.println("Connection Ended");
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    public void start() {
        if (serverThread.isAlive()) {
            System.out.println("Server is already running.");
            return;
        }
        runningServer = true;
        serverThread.start();
    }

    public void stop() throws IOException {
        runningServer = false;
        try {
            serverThread.interrupt();
            socket.close();
        } catch (NullPointerException n) {
            n.printStackTrace();
        }
        System.out.println("Server Stopped");
    }

    public void listen() throws IOException, SocketTimeoutException {
        System.out.println("Server starting...");
        server = new ServerSocket(this.port);
        System.out.println("Server started on port " + this.port);

        Node peer;
        server.setSoTimeout(10000);
        while (runningServer) {
            try {
                socket = server.accept();
                peer = new Node(socket);
                System.out.println("Connection received from: " + peer.toString());
                nodes.add(peer);
                System.out.println("New peer: " + peer.toString());
            } catch (SocketTimeoutException e) {
                //e.printStackTrace();
            }

        }
    }

    public void connect(Socket socket) {
        try {
            outputStream = new DataOutputStream(socket.getOutputStream());
            Node.send("ping", outputStream);
        } catch (IOException e) {
            //e.printStackTrace();
        }
    }
}
