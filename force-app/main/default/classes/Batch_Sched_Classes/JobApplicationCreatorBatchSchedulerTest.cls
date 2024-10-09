/**
 * @description       : 
 * @author            : admillican08@gmail.com
 * @group             : 
 * @last modified on  : 10-09-2024
 * @last modified by  : admillican08@gmail.com
**/
@isTest
public class JobApplicationCreatorBatchSchedulerTest {
  @TestSetup
  private static void makeData() {
        List<Account> acctLst = Util_TestDataFactory.createTestAccounts(1, TRUE); 
        Account acct = acctLst[0];
    Position__c newPos1 = new Position__c(
      Company__c = acct.Id,
      External_System_Id__c = '24420974192',
      Geographic_Job_Location__c = 'Richardson, TX',
      How_Paid__c = 'Salaried Annually',
      Position_Status__c = 'Open',
      Reported_Last_Updated__c = System.now(),
      Title__c = 'Salesforce Architect',
      Salary__c = 220000
    );
    insert newPos1;
    }
  

    @isTest
    static void testSchedulerExecution() {
      Test.startTest();
      Position__c posn = [SELECT Id FROM Position__c WHERE External_System_Id__c = '24420974192' LIMIT 1];
      Assert.IsNotNull(posn.Id, 'Matching position not found as expected');
      JobApplicationCreatorBatchScheduler scheduler = new JobApplicationCreatorBatchScheduler();
    
        String jobId = System.schedule('Test JobApplicationCreatorBatchScheduler', '0 0 0 15 10 ? 2024', scheduler);
      
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
      Test.stopTest();
        // Validate the job is scheduled correctly
        Assert.areEqual('0 0 0 15 10 ? 2024', ct.CronExpression, 'Cron expression not equal to supplied param as expected');
    }


}
