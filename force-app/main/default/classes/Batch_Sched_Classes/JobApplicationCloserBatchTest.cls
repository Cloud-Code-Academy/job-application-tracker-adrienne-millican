/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 10-17-2024
 * @last modified by  : admillican08@gmail.com
 **/
@isTest
private class JobApplicationCloserBatchTest {
  @testSetup
  static void makeData() {
    // Create test accounts using the Util_TestDataFactory
    List<Account> testAccounts = Util_TestDataFactory.createTestAccounts(
      2,
      true
    );
    Account test1 = testAccounts[0];
    Account test2 = testAccounts[1];

    // Create test positions for Job Applications
    Position__c testPos1 = new Position__c(
      Title__c = 'Salesforce Developer',
      Position_Status__c = 'Filled',
      Company__c = test1.Id,
      How_Paid__c = 'Hourly'
    );
    insert testPos1;

    Position__c testPos2 = new Position__c(
      Title__c = 'Salesforce Analyst',
      Position_Status__c = 'Open',
      Company__c = test2.Id,
      How_Paid__c = 'Salaried'
    );
    insert testPos2;

    // Create Job Applications that should be closed by the batch
    Job_Application__c jobApp1 = new Job_Application__c(
      Position__c = testPos1.Id,
      Application_Status__c = 'Saved',
      Company__c = test1.Id,
      How_Paid__c = 'Hourly',
      Follow_up_Date__c = System.today().addDays(-31), // Older than 30 days
      Closed_by_Automated_Process__c = false
    );
    insert jobApp1;

    Job_Application__c jobApp2 = new Job_Application__c(
      Position__c = testPos2.Id,
      Company__c = test2.Id,
      How_Paid__c = 'Salaried',
      Application_Status__c = 'Closed',
      Follow_up_Date__c = System.today().addDays(-10),
      Closed_by_Automated_Process__c = false
    );
    insert jobApp2;

    // Job Applications that should not be closed by the batch
    Job_Application__c jobApp3 = new Job_Application__c(
      Position__c = testPos1.Id,
      Company__c = test1.Id,
      How_Paid__c = 'Hourly',
      Application_Status__c = 'Interviewing',
      Follow_up_Date__c = System.today(),
      Closed_by_Automated_Process__c = false
    );
    insert jobApp3;
  }

  @isTest
  static void testJobApplicationCloserBatchSuccessful() {
    // Start the test batch execution
    Test.startTest();

    // Instantiate and execute the batch
    JobApplicationCloserBatch batch = new JobApplicationCloserBatch();
    Database.executeBatch(batch);

    Test.stopTest();

    // Verify that the Job Applications were closed as expected
    List<Job_Application__c> jobApps = [
      SELECT
        Id,
        Application_Status__c,
        Closed_by_Automated_Process__c,
        Position_Title__c
      FROM Job_Application__c
      WHERE Application_Status__c = 'Closed'
      ORDER BY Position_Title__c ASC
    ];

    // Assert that the correct number of applications were closed
    Assert.areEqual(3, jobApps.size(), 'Expected number of three not found');

    // Verify specific job applications were updated
    for (Integer i = 1; i < jobApps.size(); i++) {
      Assert.areEqual(
        true,
        jobApps[i].Closed_by_Automated_Process__c,
        'Job Application should be marked as closed by automated process.'
      );
    }

    // Verify that the application in 'Closed' status was not updated
    Job_Application__c notUpdatedJobApp = [
      SELECT Id, Application_Status__c, Closed_by_Automated_Process__c
      FROM Job_Application__c
      WHERE
        Application_Status__c = 'Closed'
        AND Closed_by_Automated_Process__c = FALSE
      LIMIT 1
    ];
    Assert.isNotNull(
      notUpdatedJobApp,
      'Job Application in "Closed" status should not be updated.'
    );
  }
}