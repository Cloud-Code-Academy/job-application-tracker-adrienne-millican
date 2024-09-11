/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-10-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class Utils_RandomGenerator {
  public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
      Integer idx = Math.mod(
        Math.abs(Crypto.getRandomInteger()),
        chars.length()
      );
      randStr += chars.substring(idx, idx + 1);
    }
    return randStr;
  }

  public static String generateRandomNumberString(Integer len) {
    final String chars = '0123456789';
    String randStr = '';
    while (randStr.length() < len) {
      Integer idx = Math.mod(
        Math.abs(Crypto.getRandomInteger()),
        chars.length()
      );
      randStr += chars.substring(idx, idx + 1);
    }
    return randStr;
  }

  public static Integer genRandIntLessThan(Integer supplInt) {
    Integer returnVal = 0;
    if (supplInt == 0) {
      System.debug('Cannot generate a random integer from 0');
    } else {
      returnVal = Integer.valueOf(Math.floor(Math.random() * supplInt));
    }
    return returnVal;
  }

  public static String generateCompanyName() {
    String cmpName = '';
    Integer randomNum = Utils_RandomGenerator.genRandIntLessThan(10);
    Integer useThird = Utils_RandomGenerator.genRandIntLessThan(2);
    List<String> cmpOneNamesLst = new List<String>{
      'American',
      'Computer',
      'Information',
      'Health',
      'Industrial',
      'Preferred',
      'New',
      'International',
      'Information',
      'Business'
    };
    List<String> cmpTwoNamesLst = new List<String>{
      'Solutions',
      'Technology',
      'Systems',
      'Consultants',
      'Corporation',
      'Technology',
      'Services',
      'Group',
      'Development',
      'Associates'
    };
    cmpName = cmpOneNamesLst[randomNum] + ' ' + cmpTwoNamesLst[randomNum];
    if (useThird == 1) {
      cmpName = cmpName + ' ' + cmpTwoNamesLst[randomNum + 1];
    }
    return cmpName;
  }

  public static String generatePersonName(String firstOrLast) {
    String persName = '';
    Integer randomNum = Utils_RandomGenerator.genRandIntLessThan(25);
    List<String> firstNamesLst = new List<String>{
      'Alexa',
      'Fern',
      'Constance',
      'Daniella',
      'Hannah',
      'Seth',
      'Jasper',
      'Caleb',
      'Adil',
      'Harold',
      'Jaydon',
      'Marvin',
      'Zeeshan',
      'Rocco',
      'Adam',
      'Naima',
      'Cynthia',
      'Lola',
      'Mae',
      'Ffion',
      'Rory',
      'Dakota',
      'Teddie',
      'Finley',
      'Kasey'
    };
    List<String> LastNamesLst = new List<String>{
      'Hargrave',
      'Sitz',
      'Alfarsi',
      'Larsen',
      'Cuana',
      'Giraud',
      'Cuypers',
      'Kulkarni',
      'Abbes',
      'Hafner',
      'Cox',
      'Sogg',
      'Hammond',
      'Patterson',
      'Salazar',
      'Lam',
      'Shah',
      'Blackburn',
      'Hickman',
      'Soelberg',
      'Fortescue',
      'Nunnaly',
      'Novak',
      'Gigliotti',
      'Selin'
    };
    if (firstOrLast.startsWithIgnoreCase('f')) {
      persName = firstNamesLst[randomNum];
    } else if (firstOrLast.startsWithIgnoreCase('l')) {
      persName = lastNamesLst[randomNum];
    }
    return persName;
  }
}
