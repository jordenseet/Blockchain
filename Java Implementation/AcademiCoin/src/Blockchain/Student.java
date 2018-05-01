package Blockchain;


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
public class Student {
    private String name;
    private String id;
    HashMap<String,String> grades = new HashMap<String,String>();
    public Student(String name,String id,HashMap<String,String> grades){
        this.name = name;
        this.id = id;
        this.grades = grades;
    }

    public String getName() {
        return name;
    }

    public String getId() {
        return id;
    }

    public HashMap<String, String> getGrades() {
        return grades;
    }
    
    public String getGrade(String subject){
        if(grades.get(subject) != null){
            return grades.get(subject);
        }
        else{
            return null;
        }
    }
}
