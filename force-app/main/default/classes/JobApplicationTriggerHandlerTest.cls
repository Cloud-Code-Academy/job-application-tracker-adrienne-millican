/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 10-17-2024
 * @last modified by  : admillican08@gmail.com
 **/
@isTest
private class JobApplicationTriggerHandlerTest {
  @testSetup
  static void makeData() {
    // Create a Contact to use as the Primary Contact in Job Applications
    List<Account> testAccts = Util_TestDataFactory.createTestAccounts(1, true);

    List<Contact> testContacts = Util_TestDataFactory.createTestContacts(
      testAccts,
      6,
      false
    );
    for (Integer i = 0; i < testContacts.size(); i += 3) {
      testContacts[i].Title = 'Lead Recruiter';
      testContacts[i + 1].Title = 'Human Resources Director';
      testContacts[i + 2].Title = 'Hiring Manager';
    }

    insert testContacts;
    Position__c newPos = new Position__c(
      Company__c = testAccts[0].Id,
      External_System_Id__c = Util_TestDataFactory.generateRandomNumberString(
        12
      ),
      Geographic_Job_Location__c = 'Fairfax, VA',
      How_Paid__c = 'Salaried',
      Position_Status__c = 'Open',
      Reported_Last_Updated__c = System.now(),
      Title__c = 'Salesforce Consultant',
      Salary__c = 120000
    );
    insert newPos;
    List<Job_Application__c> jobApps = new List<Job_Application__c>();
    for (Integer i = 0; i < 5; i++) {
      Job_Application__c jobApp = new Job_Application__c(
        Position__c = newPos.Id,
        Position_Reported_Last_Updated__c = newPos.Reported_Last_Updated__c,
        Salary__c = newPos.Salary__c,
        Notes__c = 'Some note text'
      );
      jobApps.add(jobApp);
    }
    insert jobApps;
  }

  @isTest
  static void testAfterInsert() {
    Account acct = [
      SELECT Id
      FROM Account
      WHERE Name LIKE 'Test %' AND CreatedDate = TODAY
      LIMIT 1
    ];
    Contact con = Util_TestDataFactory.createSingleTestContact(
      acct.Id,
      'Test',
      'Contact',
      false
    );
    con.Title = 'Hiring Manager';
    insert con;
    Position__c secondPos = new Position__c(
      Company__c = acct.Id,
      External_System_Id__c = Util_TestDataFactory.generateRandomNumberString(
        12
      ),
      Geographic_Job_Location__c = 'Billings, MT',
      How_Paid__c = 'Salaried',
      Position_Status__c = 'Open',
      Reported_Last_Updated__c = System.now(),
      Title__c = 'Salesforce Administrator',
      Salary__c = 70000
    );
    insert secondPos;
    // Create Job Application records

    List<Job_Application__c> jobApps2 = new List<Job_Application__c>();
    for (Integer i = 0; i < 5; i++) {
      Job_Application__c jobApp = new Job_Application__c(
        Position__c = secondPos.Id,
        Position_Reported_Last_Updated__c = secondPos.Reported_Last_Updated__c,
        Salary__c = secondPos.Salary__c,
        Notes__c = 'Some note text'
      );
      jobApps2.add(jobApp);
    }

    Test.startTest();
    insert jobApps2;

    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :jobApps2];
    List<Job_Application_Note__C> notes = [
      SELECT Id
      FROM Job_Application_Note__c
      WHERE Job_Application__c IN :jobApps2
    ];
    List<Job_Application_Contact__c> jaCons = [
      SELECT Id, Contact__c
      FROM Job_Application_Contact__c
      WHERE Job_Application__c IN :jobApps2
    ];

    Assert.areEqual(
      jobApps2.size(),
      tasks.size(),
      'Expected tasks not created on insert'
    );

    Assert.areEqual(
      jobApps2.size(),
      notes.size(),
      'Expected job application notes not created on insert'
    );

    Assert.areEqual(
      jobApps2.size(),
      jaCons.size(),
      'Expected job application contacts not created on insert'
    );

    Assert.areEqual(
      jaCons[0].Contact__c,
      con.Id,
      'Contact Id for JA contact not as expected'
    );

    Test.stopTest();
  }

  @isTest
  static void testBeforeUpdate() {
    // Fetch the inserted Job Applications
    List<Job_Application__c> jobApps = [
      SELECT Id, Salary__c
      FROM Job_Application__c
    ];

    Decimal origSalary = jobApps[0].Salary__c;
    // Modify the Job Application records
    for (Job_Application__c jobApp : jobApps) {
      jobApp.Salary__c += 1000; // Update Salary
    }

    Test.startTest();
    update jobApps;
    Test.stopTest();

    List<Job_Application__c> updatedJobApps = [
      SELECT Id, Salary__c
      FROM Job_Application__c
      WHERE Id IN :jobApps
    ];
    for (Integer i = 0; i < updatedJobApps.size(); i++) {
      Assert.areEqual(
        origSalary + 1000,
        updatedJobApps[i].Salary__c,
        'Salary not updated as expected before update'
      );
    }
  }

  @isTest
  static void testAfterUpdate() {
    List<Job_Application__c> jobApps = [
      SELECT Id, Salary__c
      FROM Job_Application__c
    ];

    for (Job_Application__c jobApp : jobApps) {
      jobApp.Salary__c += 2000;
    }

    Test.startTest();
    update jobApps;
    Test.stopTest();

    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :jobApps];
    List<Job_Application_Note__c> notes = [
      SELECT Id, Job_Application__c, Entry__c, Entry_Date_Time__c
      FROM Job_Application_Note__c
      WHERE Job_Application__c IN :jobApps
    ];

    Assert.areEqual(
      jobApps.size(),
      tasks.size(),
      'Expected tasks not created after update'
    );
    Assert.areEqual(
      jobApps.size(),
      notes.size(),
      'Job application note not created after update as expected'
    );
  }
  /*
  @isTest
  static void testAfterDelete() {
    List<Job_Application__c> jobApps = [
      SELECT Id
      FROM Job_Application__c
      LIMIT 5
    ];

    Test.startTest();
    delete jobApps;
    Test.stopTest();

    List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :jobApps];
    List<Job_Application_Note__c> notes = [
      SELECT Id
      FROM Job_Application_Note__c
      WHERE Job_Application__c IN :jobApps
    ];

    Assert.areEqual(
      0,
      tasks.size(),
      'Tasks list not size of zero as expected after delete'
    );
    Assert.areEqual(
      0,
      notes.size(),
      'Job App notes list not size of zero as expected after delete'
    );
  }
    */
}