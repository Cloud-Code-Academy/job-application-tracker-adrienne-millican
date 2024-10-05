/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-29-2024
 * @last modified by  : admillican08@gmail.com
 **/
@isTest
private class JobApplicationTriggerHandlerTest {
  @testSetup
  static void makeData() {
    // Create a Contact to use as the Primary Contact in Job Applications
    Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
    insert testContact;

    // Create Job Application records
    List<Job_Application__c> jobApps = new List<Job_Application__c>();
    for (Integer i = 0; i < 5; i++) {
      Job_Application__c jobApp = new Job_Application__c(
        Salary__c = 50000 + (i * 1000),
        Position_Reported_Last_Updated__c = DateTime.now(),
        Primary_Contact__c = testContact.Id
      );
      jobApps.add(jobApp);
    }
    insert jobApps;
  }

  @isTest
  static void testAfterInsert() {
    // Fetch the inserted Job Applications
    List<Job_Application__c> insertedJobApps = [
      SELECT
        Id,
        Salary__c,
        Position_Reported_Last_Updated__c,
        Primary_Contact__c
      FROM Job_Application__c
    ];

    // Test after insert trigger by simulating the afterInsert event
    Test.startTest();
    // Trigger the insert event
    insert insertedJobApps;

    // Verify the notes and tasks were created
    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :insertedJobApps];
    List<Job_Application_Note__c> notes = [
      SELECT Id, Job_Application__c, Entry__c, Entry_Date_Time__c
      FROM Job_Application_Note__c
      WHERE Job_Application__c IN :insertedJobApps
    ];

    Assert.areEqual(
      insertedJobApps.size(),
      tasks.size(),
      'Each Job Application should have a Task created.'
    );
    Assert.areEqual(
      insertedJobApps.size(),
      notes.size(),
      'Each Job Application should have a Job Application Note created.'
    );

    Test.stopTest();
  }

  @isTest
  static void testBeforeUpdate() {
    // Fetch the inserted Job Applications
    List<Job_Application__c> jobApps = [
      SELECT
        Id,
        Salary__c,
        Position_Reported_Last_Updated__c,
        Primary_Contact__c
      FROM Job_Application__c
    ];

    // Modify the Job Application records
    for (Job_Application__c jobApp : jobApps) {
      jobApp.Salary__c += 1000; // Update Salary
    }

    // Test before update trigger by simulating the beforeUpdate event
    Test.startTest();
    update jobApps;
    Test.stopTest();

    // Assertions for expected changes
    List<Job_Application__c> updatedJobApps = [
      SELECT Id, Salary__c
      FROM Job_Application__c
      WHERE Id IN :jobApps
    ];
    for (Integer i = 0; i < updatedJobApps.size(); i++) {
      Assert.areEqual(
        51000 + (i * 1000),
        updatedJobApps[i].Salary__c,
        'Salary should have been updated.'
      );
    }
  }

  @isTest
  static void testAfterUpdate() {
    // Fetch the inserted Job Applications
    List<Job_Application__c> jobApps = [
      SELECT
        Id,
        Salary__c,
        Position_Reported_Last_Updated__c,
        Primary_Contact__c
      FROM Job_Application__c
    ];

    // Modify the Job Application records
    for (Job_Application__c jobApp : jobApps) {
      jobApp.Salary__c += 2000; // Update Salary again
    }

    // Test after update trigger by simulating the afterUpdate event
    Test.startTest();
    update jobApps;
    Test.stopTest();

    // Verify tasks and notes were created after update
    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :jobApps];
    List<Job_Application_Note__c> notes = [
      SELECT Id, Job_Application__c, Entry__c, Entry_Date_Time__c
      FROM Job_Application_Note__c
      WHERE Job_Application__c IN :jobApps
    ];

    Assert.areEqual(
      jobApps.size(),
      tasks.size(),
      'Tasks should be created for each updated Job Application.'
    );
    Assert.areEqual(
      jobApps.size(),
      notes.size(),
      'Job Application Notes should be created for each updated Job Application.'
    );
  }

  @isTest
  static void testAfterDelete() {
    // Fetch the inserted Job Applications
    List<Job_Application__c> jobApps = [
      SELECT Id
      FROM Job_Application__c
      LIMIT 5
    ];

    // Test after delete trigger by simulating the afterDelete event
    Test.startTest();
    delete jobApps;
    Test.stopTest();

    // Assert that no notes or tasks remain for the deleted job applications
    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :jobApps];
    List<Job_Application_Note__c> notes = [
      SELECT Id
      FROM Job_Application_Note__c
      WHERE Job_Application__c IN :jobApps
    ];

    Assert.areEqual(
      0,
      tasks.size(),
      'No tasks should remain for deleted Job Applications.'
    );
    Assert.areEqual(
      0,
      notes.size(),
      'No notes should remain for deleted Job Applications.'
    );
  }
}