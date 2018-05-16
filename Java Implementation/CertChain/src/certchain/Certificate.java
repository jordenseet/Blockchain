/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package certchain;
import java.io.ByteArrayOutputStream;
import java.io.Serializable;
import java.security.MessageDigest;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

/**
 *
 * @author Jorden
 */
public class Certificate implements Serializable{
    private String timestamp;
    //for easier manipulation, would always cast to Date before toString
    private String id;
    private String schoolId;
    HashMap<String,String> grades = new HashMap<String,String>();

    public Certificate(String id, String schoolId, HashMap<String,String> grades) {
        Calendar calendar = Calendar.getInstance();
        this.timestamp = calendar.toString();
        this.id = id;
        this.schoolId = schoolId;
        this.grades = grades;
    }
    

    public String getTimestamp() {
        return timestamp;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSchoolId() {
        return schoolId;
    }

    public void setSchoolId(String schoolId) {
        this.schoolId = schoolId;
    }

    public HashMap<String, String> getGrades() {
        return grades;
    }

    public void setGrades(HashMap<String, String> grades) {
        this.grades = grades;
    }
    
    public String toString() {
        return "Block{" + ", timestamp=" + timestamp + ", student=" + id + ", school=" + schoolId + '}';
    }
    
    public byte[] produceHash() {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            ByteArrayOutputStream toSerialize = new ByteArrayOutputStream();
            byte[] bytes = toSerialize.toByteArray();
            return digest.digest(bytes);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
