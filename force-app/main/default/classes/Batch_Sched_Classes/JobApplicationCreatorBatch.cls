/**
 * @description       : This batch class is responsible for creating or updating Job_Application__c records
 *                      based on the Position__c records created or updated on the current day. If a Position__c
 *                      record has no related Job_Application__c record, one is created. If a Job_Application__c
 *                      record exists, it is updated based on the latest Position__c data.
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-29-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JobApplicationCreatorBatch implements Database.Batchable<sObject> {
  // Constants for object and class names used in logging
  public static final String OBJ_NAME = 'Job Application';
  public static final String CLS_NAME = 'JobApplicationCreatorBatch';
  public List<Job_Application__c> jobAppLst { get; private set; }

  /**
   * @description       : The start method defines the scope of the batch by returning a QueryLocator.
   *                      This method fetches Position__c records that were created or had their
   *                      Reported_Last_Updated__c field modified today.
   * @param bc          : The batch context provided by the platform.
   * @return            : A QueryLocator containing Position__c records created or updated today.
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Company__c, Job_Location__c, How_Paid__c, Position_Description__c, Position_Link__c, Salary__c, ' +
        'Reported_Last_Updated__c, (SELECT Id, Position__c, Position_Reported_Last_Updated__c FROM Job_Applications__r) ' +
        'FROM Position__c WHERE (CreatedDate = TODAY OR Reported_Last_Updated__c = TODAY) WITH USER_MODE'
    );
  }

  /**
   * @description       : The execute method processes each batch of Position__c records.
   *                      For each record, it creates a new Job_Application__c if none exists,
   *                      or updates an existing Job_Application__c if the Position__c has been updated
   *                      more recently than the Job_Application__c.
   * @param bc          : The batch context provided by the platform.
   * @param scope       : The list of Position__c records in the current batch.
   */
  public void execute(Database.BatchableContext bc, List<Position__c> scope) {
    final String MTD_NAME = 'execute';

    // Iterate through each Position__c record in the batch
    for (Position__c posn : scope) {
      jobAppLst = new List<Job_Application__c>();

      // If no Job_Application__c records exist for the Position__c, create a new one
      if (posn.Job_Applications__r.size() == 0) {
        Job_Application__c jApp = new Job_Application__c();
        jApp.Position__c = posn.Id;
        jApp.Company__c = posn.Company__c;
        jApp.Salary__c = posn.Salary__c;
        jApp.How_Paid__c = posn.How_Paid__c;
        jApp.Job_Description__c = posn.Position_Description__c;
        jApp.Position_Reported_Last_Updated__c = posn.Reported_Last_Updated__c;
        jobAppLst.add(jApp);
      } else {
        // If Job_Application__c records exist, update them if the Position__c has been updated more recently
        for (Job_Application__c jobApp : posn.Job_Applications__r) {
          if (
            posn.Reported_Last_Updated__c >
            jobApp.Position_Reported_Last_Updated__c
          ) {
            jobApp.Company__c = posn.Company__c;
            jobApp.Salary__c = posn.Salary__c;
            jobApp.How_Paid__c = posn.How_Paid__c;
            jobApp.Job_Description__c = posn.Position_Description__c;
            jobApp.Position_Reported_Last_Updated__c = posn.Reported_Last_Updated__c;
            jobAppLst.add(jobApp);
          }
        }
      }

      // Use a utility method to upsert the Job_Application__c records and log the results
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