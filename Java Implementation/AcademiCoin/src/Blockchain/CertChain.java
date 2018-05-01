package Blockchain;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author Jorden
 */
public class CertChain {
    /*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author Jorden
 */

  private int difficulty;
  private HashMap<Integer, Certificate> certchain;

  public CertChain(int difficulty) {
    this.difficulty = difficulty;
    certchain = new HashMap<Integer,Certificate>();
    // create the first block
    Certificate genesis = new Certificate(0, System.currentTimeMillis(), null, new Student(null,null,new HashMap<String,String>()), new School(null,null));
    genesis.mineCert(difficulty);
    certchain.put(0,genesis);
  }

  public int getDifficulty() {
    return difficulty;
  }

  public Certificate latestCert() {
    return certchain.get(certchain.size() - 1);
  }
  
  public Certificate getCert(int index){
      if (certchain.get(index)!= null){
          return certchain.get(index);
      }
      else{
          return null;
      }
  }
  public Certificate newCert(Student s,School sch) {
    Certificate latestCertificate = latestCert();
    return new Certificate(latestCertificate.getIndex() + 1, System.currentTimeMillis(),latestCertificate.getHash(), s, sch);
  }

  public void addCert(Certificate cert) {
    if (cert != null) {
      cert.mineCert(difficulty);
      certchain.put(cert.getIndex(),cert);
    }
  }

  public boolean isFirstCertValid() {
    Certificate firstCertificate = certchain.get(0);

    if (firstCertificate.getIndex() != 0) {
      return false;
    }

    if (firstCertificate.getPreviousHash() != null) {
      return false;
    }

    if (firstCertificate.getHash() == null || !Certificate.produceHash(firstCertificate).equals(firstCertificate.getHash())) {
      return false;
    }

    return true;
  }

  public boolean isValidNewCert(Certificate newCertificate, Certificate previousCertificate) {
    if (newCertificate != null  &&  previousCertificate != null) {
      if (previousCertificate.getIndex() + 1 != newCertificate.getIndex()) {
        return false;
      }

      if (newCertificate.getPreviousHash() == null  ||  
	    !newCertificate.getPreviousHash().equals(previousCertificate.getHash())) {
        return false;
      }

      if (newCertificate.getHash() == null  ||  
	    !Certificate.produceHash(newCertificate).equals(newCertificate.getHash())) {
        return false;
      }

      return true;
    }

    return false;
  }

  public boolean isCertChainValid() {
    if (!isFirstCertValid()) {
      return false;
    }

    for (int i = 1; i < certchain.size(); i++) {
      Certificate currentCertificate = certchain.get(i);
      Certificate previousCertificate = certchain.get(i - 1);

      if (!isValidNewCert(currentCertificate, previousCertificate)) {
        return false;
      }
    }

    return true;
  }

  public String toString() {
    StringBuilder builder = new StringBuilder();

    for (Map.Entry<Integer,Certificate> pair : certchain.entrySet()) {
      builder.append(pair.getValue()).append("\n");
    }

    return builder.toString();
  }

}

