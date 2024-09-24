/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-10-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class Utils_RandomStringGenerator {
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
}