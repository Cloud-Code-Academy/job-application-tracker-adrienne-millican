/**
 * @description       :
 * @author            : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/
@IsTest
class Util_InsertTest {
  @TestSetup
  static void makeData() {
    User currUsr = [
      SELECT Id
      FROM User
      WHERE Id = :UserInfo.getUserId()
      WITH SYSTEM_MODE
    ];
    System.runAs(currUsr) {
      List<Account> testAccts = Util_TestDataFactory.createTestAccounts(
        4,
        true
      );
    }
  }
  @IsTest
  static void testInsertListSuccessflly() {
    String methodName = 'testInsertListSuccessfully of Util_InsertTest class';
    List<Account> testAccts = [
      SELECT Id, OwnerId
      FROM Account
      WHERE Name LIKE 'Test %' AND CreatedDate = TODAY
      LIMIT 4
    ];
    List<Contact> testContacts = Util_TestDataFactory.createTestContacts(
      testAccts,
      4,
      false
    );

    Test.startTest();
    String resultMsg = Util_Insert.insertList(
      'Contact',
      testContacts,
      methodName
    );
    Assert.isTrue(
      resultMsg.contains('**Inserted 16 record(s) of Contact type'),
      'Result message after list insert not as expected'
    );
    Test.stopTest();
  }

  @IsTest
  static void testInsertSingleRecordSuccessflly() {
    String methodName = 'testInsertSingleRecordSuccessfully of Util_InsertTest class';
    List<Account> testAccts = [
      SELECT Id
      FROM Account
      WHERE Name LIKE 'Test %' AND CreatedDate = TODAY
      LIMIT 1
    ];
    List<Contact> testContacts = Util_TestDataFactory.createTestContacts(
      testAccts,
      1,
      false
    );

    Test.startTest();
    String resultMsg = Util_Insert.insertRecord(
      'Contact',
      testContacts[0],
      methodName
    );
    Assert.isTrue(
      resultMsg.contains('**Inserted 1 record(s) of Contact type'),
      'Result message after single record insert not as expected'
    );
    Test.stopTest();
  }
  @IsTest
  static void testInsertDeliberatelyThrowException() {
    String message = '';
    String methodName = 'testInsertDeliberatelyThrowException of Util_InsertTest class';
    List<Account> testAccts = [
      SELECT Id, OwnerId
      FROM Account
      WHERE Name LIKE 'Test %' AND CreatedDate = TODAY
      LIMIT 1
    ];

    List<Contact> testContacts = Util_TestDataFactory.createTestContacts(
      testAccts,
      4,
      true
    );
    Test.startTest();
    try {
      Util_Insert.insertList('Contact', testContacts, methodName);
    } catch (Util_ExceptionUtil.CustomException cex) {
      message = cex.getMessage();
    }
    Assert.isTrue(
      message.startsWith('**ERROR:'),
      'Error message not as expected'
    );
  }
}
