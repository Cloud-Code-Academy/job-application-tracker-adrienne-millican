/**
 * @description       :
 * @author            : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 * @group             :
 * @last modified on  : 09-11-2024
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
    Id prmSetId = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Rule_Exempt_Permission'
      LIMIT 1
    ]
    .Id;
    Id currUsrId = UserInfo.getUserId();
    PermissionSetAssignment ruleExAssign = [
      SELECT Id
      FROM PermissionSetAssignment
      WHERE
        IsActive = TRUE
        AND AssigneeId = :currUsrId
        AND PermissionSetId = :prmSetId
      LIMIT 1
    ];
    if (ruleExAssign == null) {
      PermissionSetAssignment newPermSet = new PermissionSetAssignment(
        AssigneeId = currUsrId,
        PermissionSetId = prmSetId
      );
      insert newPermSet;
    }
    String methodName = 'testUpsertListSuccessfully of Util_UpsertTest class';
    List<Account> testAccts = [
      SELECT Id, OwnerId
      FROM Account
      WHERE Name LIKE 'Test Acct %'
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
    Id prmSetId = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Rule_Exempt_Permission'
      LIMIT 1
    ]
    .Id;
    Id currUsrId = UserInfo.getUserId();
    PermissionSetAssignment ruleExAssign = [
      SELECT Id
      FROM PermissionSetAssignment
      WHERE
        IsActive = TRUE
        AND AssigneeId = :currUsrId
        AND PermissionSetId = :prmSetId
      LIMIT 1
    ];
    if (ruleExAssign == null) {
      PermissionSetAssignment newPermSet = new PermissionSetAssignment(
        AssigneeId = currUsrId,
        PermissionSetId = prmSetId
      );
      insert newPermSet;
    }
    String methodName = 'testUpsertSingleRecordSuccessfully of Util_UpsertTest class';
    List<Account> testAccts = [
      SELECT Id
      FROM Account
      WHERE Name LIKE 'Test Acct %'
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
  static void testUpsertInvocableSuccessfully() {
    Id prmSetId = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Rule_Exempt_Permission'
      LIMIT 1
    ]
    .Id;
    Id currUsrId = UserInfo.getUserId();
    PermissionSetAssignment ruleExAssign = [
      SELECT Id
      FROM PermissionSetAssignment
      WHERE
        IsActive = TRUE
        AND AssigneeId = :currUsrId
        AND PermissionSetId = :prmSetId
      LIMIT 1
    ];
    if (ruleExAssign == null) {
      PermissionSetAssignment newPermSet = new PermissionSetAssignment(
        AssigneeId = currUsrId,
        PermissionSetId = prmSetId
      );
      insert newPermSet;
    }
    String methodName = 'testUpsertInvocableSuccessfully of Util_UpsertTest class';
    List<Account> testAccts = [
      SELECT Id
      FROM Account
      WHERE Name LIKE 'Test Acct %'
      LIMIT 4
    ];
    List<Contact> testContacts = Util_TestDataFactory.createTestContacts(
      testAccts,
      100,
      false
    );
    List<List<sObject>> listOfSObjLists = new List<List<sObject>>();
    listOfSObjLists.add(testContacts);
    Util_Upsert.upsertListInvocable(listOfSObjLists);
    Assert.IsTrue(
      Util_Upsert.messageStr.contains(
        '**Upserted 400 record(s) of Contact type'
      ),
      'Result message after invocable upsert not as expected.'
    );
  }

  @IsTest
  static void testUpsertDeliberatelyThrowException() {
    Id prmSetId = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Rule_Exempt_Permission'
      LIMIT 1
    ]
    .Id;
    Id currUsrId = UserInfo.getUserId();
    String message = '';
    PermissionSetAssignment ruleExAssign = [
      SELECT Id
      FROM PermissionSetAssignment
      WHERE
        IsActive = TRUE
        AND AssigneeId = :currUsrId
        AND PermissionSetId = :prmSetId
      LIMIT 1
    ];
    if (ruleExAssign == null) {
      PermissionSetAssignment newPermSet = new PermissionSetAssignment(
        AssigneeId = currUsrId,
        PermissionSetId = prmSetId
      );
      insert newPermSet;
    }
    String methodName = 'testUpsertDeliberatelyThrowException of Util_UpsertTest class';
    List<Account> testAccts = [
      SELECT Id, OwnerId
      FROM Account
      WHERE Name LIKE 'Test Acct %'
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
      message.startsWith('***ERROR:'),
      'Error message not as expected'
    );
  }
}