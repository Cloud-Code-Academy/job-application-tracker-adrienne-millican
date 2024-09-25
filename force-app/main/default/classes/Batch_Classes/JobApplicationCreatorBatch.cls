/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-25-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JobApplicationCreatorBatch implements Database.Batchable<sObject> {
  public static final String OBJ_NAME = 'Job Application';
  public static final String CLS_NAME = 'JobApplicationCreatorBatch';

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Company__c, Job_Location__c, Position_Description__c, Position_Link__c, Salary__c, Reported_Last_Updated__c, (SELECT Id, Position__c, Position_Reported_Last_Updated__c FROM Job_Applications__r) FROM Position__c WHERE (CreatedDate = TODAY OR LastModifiedDate = TODAY) WITH USER_MODE'
    );
  }

  public void execute(Database.BatchableContext bc, List<Position__c> scope) {
    final String MTD_NAME = 'execute';
    for (Position__c posn : scope) {
      List<Job_Application__c> jobAppLst = new List<Job_Application__c>();
      if (posn.Job_Applications__r.size() == 0) {
        Job_Application__c jApp = new Job_Application__c();
        jApp.Position__c = posn.Id;
        jApp.Company__c = posn.Company__c;
        jApp.Job_Description__c = posn.Position_Description__c.replace(
          '\\.\\.\\.',
          ''
        );
        jApp.Salary__c = posn.Salary__c;
        jApp.Position_Reported_Last_Updated__c = posn.Reported_Last_Updated__c;
        jobAppLst.add(jApp);
      } else {
        for (Job_Application__c jobApp : posn.Job_Applications__r) {
          if (
            posn.Reported_Last_Updated__c <
            jobApp.Position_Reported_Last_Updated__c
          ) {
            jobApp.Company__c = posn.Company__c;
            jobApp.Job_Description__c = posn.Position_Description__c.replace(
              '\\.\\.\\.',
              ''
            );
            jobApp.Salary__c = posn.Salary__c;
            jobApp.Position_Reported_Last_Updated__c = posn.Reported_Last_Updated__c;
            jobAppLst.add(jobApp);
          }
        }
      }
      System.debug(
        Util_Upsert.upsertList(
          OBJ_NAME,
          jobAppLst,
          MTD_NAME + ' of ' + CLS_NAME
        )
      );
    }
  }

  public void finish(Database.BatchableContext bc) {
  }
}
