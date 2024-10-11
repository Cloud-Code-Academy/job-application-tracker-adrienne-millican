/**
 * @description       :
 * @author            : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/
@IsTest
class Util_UpsertTest {
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
      List<Contact> testContacts = Util_TestDataFactory.createTestContacts(
        testAccts,
        4,
        true
      );
    }
  }
  @IsTest
  static void testUpsertListSuccessflly() {
    String methodName = 'testUpsertListSuccessfully of Util_UpsertTest class';
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
    insert testContacts[0];
    testContacts[0].FirstName = 'Wesley';
    Test.startTest();
    String resultMsg = Util_Upsert.upsertList(
      'Contact',
      testContacts,
      methodName
    );
    Assert.isTrue(
      resultMsg.contains('**Upserted 16 record(s) of Contact type'),
      'Result message after list upsert not as expected'
    );
    Test.stopTest();
  }

  @IsTest
  static void testUpsertSingleRecordSuccessflly() {
    String methodName = 'testUpsertSingleRecordSuccessfully of Util_UpsertTest class';
    List<Account> testAccts = [
      SELECT Id
      FROM Account
      WHERE Name LIKE 'Test %' AND CreatedDate = TODAY
      LIMIT 4
    ];
    List<Contact> testContacts = Util_TestDataFactory.createTestContacts(
      testAccts,
      4,
      false
    );

    insert testContacts[0];
    testContacts[0].FirstName = 'Wesley';
    Test.startTest();
    String resultMsg = Util_Upsert.upsertRecord(
      'Contact',
      testContacts[0],
      methodName
    );
    Assert.isTrue(
      resultMsg.contains('**Upserted 1 record(s) of Contact type'),
      'Result message after single record upsert not as expected'
    );
    Test.stopTest();
  }

  @IsTest
  static void testUpsertDeliberatelyThrowException() {
    String methodName = 'testUpsertDeliberatelyThrowException of Util_UpsertTest class';
    String message = '';
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
    testContacts[0].LastName = null;
    Test.startTest();
    try {
      Util_Upsert.upsertList('Contact', testContacts, methodName);
    } catch (Util_ExceptionUtil.CustomException cex) {
      message = cex.getMessage();
    }
    Assert.isTrue(
      message.startsWith('**ERROR:'),
      'Error message not as expected'
    );
  }
}