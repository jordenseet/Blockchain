package certchain;

import certchain.Block;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;

public class Blockchain {

    private Block head;
    private ArrayList<Certificate> pool;
    private int length;

    public Blockchain() {
        pool = new ArrayList<>();
        length = 0;
    }

    public synchronized Block getHead() {
        return head;
    }

    public synchronized void setHead(Block head) {
        this.head = head;
    }

    public synchronized int getLength() {
        return length;
    }

    public synchronized void setLength(int length) {
        this.length = length;
    }

    public synchronized ArrayList<Certificate> getPool() {
        return pool;
    }

    public synchronized void setPool(ArrayList<Certificate> pool) {
        this.pool = pool;
    }

    public synchronized void addCertificate(Certificate certificate) {
        pool.add(certificate);
    }

    public synchronized boolean mine(int difficulty) {
        if (pool.size() == 0) {
            return false;
        }

        Block newBlock = new Block();
        if (head == null) {
            newBlock.setPreviousHash(new byte[32]);
        } else {
            newBlock.setPreviousHash(head.produceHash());
        }
        newBlock.setCertificates(pool);
        if (newBlock.mine(difficulty)) {
            newBlock.setPreviousBlock(head);
            head = newBlock;
            pool = new ArrayList<>();
            length += 1;
            return true;
        }
        return false;
    }

    public synchronized String toString() {
        String cutOffRule = new String(new char[81]).replace("\0", "-") + "\n";
        String poolString = "";
        for (Certificate tx : pool) {
            poolString += tx.toString();
        }

        String blockString = "";
        Block bl = head;
        while (bl != null) {
            blockString += bl.toString();
            bl = bl.getPreviousBlock();
        }

        return "Pool:\n"
                + cutOffRule
                + poolString
                + cutOffRule
                + blockString;
    }
}
