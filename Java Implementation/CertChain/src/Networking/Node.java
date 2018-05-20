package Networking;


import certchain.Blockchain;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;
import java.net.Socket;

public class Node {

    private Thread peerThread;
    public static Socket socket;
    public static ObjectOutputStream out;
    public ObjectInputStream in;
    Blockchain toSend;
    Blockchain storage;

    public Node(Socket socket) {
        this.socket = socket;
        peerThread = new Thread(new Runnable() {
            public void run() {
                receive();
            }
        });
        peerThread.start();
    }

    public static boolean send(Blockchain blockchain) {
        System.out.println("Sending Blockchain" + blockchain);
        try {
            out = new ObjectOutputStream(socket.getOutputStream());
            System.out.println(out);
            out.writeObject(blockchain);
            out.flush();
            System.out.println("Succeeded sending Blockchain!");
            return true;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean receive() {
        try {
            ObjectInputStream in = new ObjectInputStream(socket.getInputStream());
            Blockchain blockchain =(Blockchain)in.readObject();
            System.out.println("Downloaded Blockchain Successfully!");
            storage = blockchain;
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public Blockchain getBlockchain(){
        return storage;
    }
}
