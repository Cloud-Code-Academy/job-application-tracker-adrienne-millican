/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 10-17-2024
 * @last modified by  : admillican08@gmail.com
 **/
@isTest
private class JobApplicationCreatorBatchTest {
  @testSetup
  static void makeData() {
    // Create a test account using Util_TestDataFactory
    List<Account> newAcctLst = Util_TestDataFactory.createTestAccounts(1, true);
    Account testAccount = newAcctLst[0];

    // Create sample Position records and associate with the account
    Position__c pos1 = new Position__c(
      Company__c = testAccount.Id, // Reference to the account
      Geographic_Job_Location__c = 'Hilo, HI',
      How_Paid__c = 'Hourly',
      Title__c = 'Salesforce Developer',
      Position_Description__c = 'Really exciting developer job in paradise.',
      Position_Link__c = 'https://companyA.com/jobs/1',
      Salary__c = 100000,
      Reported_Last_Updated__c = System.now()
    );
    insert pos1;

    Position__c pos2 = new Position__c(
      Company__c = testAccount.Id, // Reference to the account
      Geographic_Job_Location__c = 'Ames, IA',
      How_Paid__c = 'Salaried',
      Title__c = 'Salesforce Manager',
      Position_Description__c = 'Manage a great Salesforce team remotely!',
      Position_Link__c = 'https://companyB.com/jobs/2',
      Salary__c = 150000,
      Reported_Last_Updated__c = System.now()
    );
    insert pos2;

    // Create related Job_Application__c record for pos2
    Job_Application__c jobApp = new Job_Application__c(
      Position__c = pos2.Id,
      Company__c = testAccount.Id, // Reference to the account
      Salary__c = pos2.Salary__c,
      How_Paid__c = pos2.How_Paid__c,
      Job_Description__c = pos2.Position_Description__c,
      Position_Reported_Last_Updated__c = System.now().addDays(-2)
    );
    insert jobApp;
  }

  @isTest
  static void testJobApplicationCreatorBatchIsSuccessful() {
    // Start the test by executing the batch
    Test.startTest();

    // Initialize the batch
    JobApplicationCreatorBatch batch = new JobApplicationCreatorBatch();
    Database.executeBatch(batch);

    Test.stopTest();

    // Verify job apps created
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name LIKE 'Test %' AND CreatedDate = TODAY
      LIMIT 1
    ];
    List<Job_Application__c> jobApps = [
      SELECT Id, Position__c, Position_Reported_Last_Updated__c, Company__c
      FROM Job_Application__c
      WHERE Company__c = :acct.Id
    ];
    Assert.areEqual(
      2,
      jobApps.size(),
      'Number of jobApps created or updated not as expected'
    );

    // Verify Job_Application__c for pos2
    Job_Application__c updatedJobApp = [
      SELECT
        Id,
        Position__c,
        Company__c,
        Position__r.Reported_Last_Updated__c,
        Position_Reported_Last_Updated__c
      FROM Job_Application__c
      WHERE Position_Title__c LIKE '% Manager'
      LIMIT 1
    ];
    Assert.areEqual(
      updatedJobApp.Position__r.Reported_Last_Updated__c,
      updatedJobApp.Position_Reported_Last_Updated__c,
      'Reported update dates not equal as expected'
    );
  }
  @isTest
  static void testBatchJobNoUpdate() {
    // Test when no Job_Application__c records need updating
    List<Account> newAcctLst = Util_TestDataFactory.createTestAccounts(1, true);
    Account testAccount = newAcctLst[0];

    Position__c pos3 = new Position__c(
      Company__c = testAccount.Id, // Reference to the account
      Geographic_Job_Location__c = 'Boston, MA',
      How_Paid__c = 'Salaried',
      Title__c = 'Salesforce Analyst',
      Position_Link__c = 'https://companyC.com/jobs/3',
      Salary__c = 120000,
      Reported_Last_Updated__c = System.now().addDays(-1)
    );
    insert pos3;
    Test.setCreatedDate(pos3.Id, System.now().addDays(-2));
    Test.startTest();

    JobApplicationCreatorBatch batch = new JobApplicationCreatorBatch();
    Database.executeBatch(batch);

    Test.stopTest();

    List<Job_Application__c> jobApps = [
      SELECT Id, Position__c
      FROM Job_Application__c
      WHERE Position__c = :pos3.Id
    ];
    System.assertEquals(
      0,
      jobApps.size(),
      'Expected result of no update did not occur'
    );
  }
}