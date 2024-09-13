/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-10-2024
 * @last modified by  : admillican08@gmail.com
 **/

@isTest
private with sharing class Util_ExceptionUtilTest {
  @isTest
  public static void validatePublishExceptionDml() {
    String exMsg;
    Test.startTest();
    try {
      String methodName = 'validatePublishExceptionDml method';
      String opName = 'Util_ExceptionUtilTest class';
      String exDetails = 'Cause: Phony Cause; Line Number: 1; Message: Phony Message; Stack Trace: Line 1; Type Name: Phony Type';
      Util_ExceptionUtil.publishException(
        'Account',
        methodName,
        opName,
        'test',
        exDetails
      );
      throw new Util_ExceptionUtil.CustomException(exDetails);
    } catch (Util_ExceptionUtil.CustomException ce) {
      exMsg = ce.getMessage();
    }
    Test.stopTest();
    System.assertNotEquals(null, exMsg);
    System.debug(exMsg);
    System.assert(
      exMsg.contains('Cause: Phony'),
      'Exception message does not contain expected word.'
    );
  }

  @isTest
  public static void validatePublishExceptionDb() {
    String exStr;
    List<User> usrLst = [
      SELECT Id, FirstName, LastName
      FROM User
      WHERE IsActive = TRUE AND UserRole.Name LIKE '%Inside Sale%'
    ];
    for (User usr : usrLst) {
      usr.LastName = null;
    }
    Test.startTest();
    List<Database.SaveResult> saveResUsrLst = Database.update(usrLst, false);
    try {
      String methodName = 'validatePublishExceptionDb method';
      String opName = 'Util_ExceptionUtilTest class';
      exStr = 'Exception details';
      Util_ExceptionUtil.publishException(
        'User',
        methodName,
        opName,
        saveResUsrLst
      );
      throw new Util_ExceptionUtil.CustomException(exStr);
    } catch (Util_ExceptionUtil.CustomException ce) {
      exStr = ce.getMessage();
    }
    Test.stopTest();
    System.debug('Message caught: ' + exStr);
    System.assertNotEquals(null, exStr);
    System.assert(
      exStr.contains('REQUIRED_FIELD'),
      'Exception message does not contain expected word.'
    );
  }

  @isTest
  public static void validateThrowCustomException() {
    String exMsg;
    Test.startTest();
    try {
      String[] strLst = new List<String>{ 'First string', 'Second string' };
      Util_ExceptionUtil.throwCustomException(strLst);
    } catch (Util_ExceptionUtil.CustomException ce) {
      exMsg = ce.getMessage();
    }
    Test.stopTest();
    System.assertNotEquals(null, exMsg);
    System.debug(exMsg);
    System.assert(
      exMsg.contains('**ERROR: First string'),
      'Exception message does not contain expected word.'
    );
    System.assert(
      !exMsg.contains('Second string'),
      'Exception message contains word it should not.'
    );
  }
}