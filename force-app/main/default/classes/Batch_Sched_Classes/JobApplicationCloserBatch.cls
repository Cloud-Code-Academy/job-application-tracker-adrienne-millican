/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : admillican08@gmail.com
 **/

public with sharing class JobApplicationCloserBatch implements Database.Batchable<sObject> {
  public static final String OBJ_NAME = 'Job Application';
  public static final String CLS_NAME = 'JobApplicationCloserBatch';

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Position__r.Position_Status__c, Application_Status__c, Closed_by_Automated_Process__c, Follow_up_Date__c FROM Job_Application__c WHERE Follow-up_Date__c < LAST_N_DAYS:30 OR Position__r.Position_Status__c = \'Filled\' OR NOT(Application_Status__c = \'Accepted\' OR Application_Status__c = \'Closed\')'
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<Job_Application__c> scope
  ) {
    final String MTD_NAME = 'execute';
    for (Job_Application__c jobApp : scope) {
      jobApp.Application_Status__c = 'Closed';
      jobApp.Closed_by_Automated_Process__c = true;
    }

    System.debug(
      Util_Upsert.upsertList(OBJ_NAME, scope, MTD_NAME + ' of ' + CLS_NAME)
    );
  }

  public void finish(Database.BatchableContext bc) {
  }
}
