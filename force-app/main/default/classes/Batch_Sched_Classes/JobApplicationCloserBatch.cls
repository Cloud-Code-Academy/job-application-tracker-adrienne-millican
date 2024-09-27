/**
 * @description       : This batch class automatically closes job applications that meet certain conditions:
 *                      1. If the related Position__c has a status of 'Filled'.
 *                      2. If the Follow-up date is older than 30 days and the application status is not 'Accepted' or 'Closed'.
 *                      The class processes eligible Job_Application__c records, sets their status to 'Closed', and marks them
 *                      as closed by an automated process.
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JobApplicationCloserBatch implements Database.Batchable<sObject> {
  // Constants for object and class names used in logging
  public static final String OBJ_NAME = 'Job Application';
  public static final String CLS_NAME = 'JobApplicationCloserBatch';

  /**
   * @description       : The start method defines the query used for the batch job.
   *                      This method retrieves Job_Application__c records where the related Position__c
   *                      has a status of 'Filled' or the Follow-up date is more than 30 days old,
   *                      and the application status is not 'Accepted' or 'Closed'.
   * @param bc          : The batch context provided by the system.
   * @return            : A Database.QueryLocator object containing the query for the batch job.
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Position__r.Position_Status__c, Application_Status__c, Closed_by_Automated_Process__c, Follow_up_Date__c ' +
        'FROM Job_Application__c ' +
        'WHERE Position__r.Position_Status__c = \'Filled\' ' +
        'OR (Follow_up_Date__c < LAST_N_DAYS:30 ' +
        'AND ((NOT Application_Status__c = \'Accepted\') ' +
        'OR (NOT Application_Status__c = \'Closed\')))'
    );
  }

  /**
   * @description       : The execute method processes each batch of Job_Application__c records returned by the start method.
   *                      For each Job_Application__c, it sets the status to 'Closed' and marks the record as closed by the automated process.
   * @param bc          : The batch context provided by the system.
   * @param scope       : The list of Job_Application__c records to be processed in the current batch.
   */
  public void execute(
    Database.BatchableContext bc,
    List<Job_Application__c> scope
  ) {
    final String MTD_NAME = 'execute';

    // Loop through each Job_Application__c record in the batch
    for (Job_Application__c jobApp : scope) {
      // Update the application status to 'Closed' and mark it as closed by the automated process
      jobApp.Application_Status__c = 'Closed';
      jobApp.Closed_by_Automated_Process__c = true;
    }

    // Upsert the updated job applications and log the result
    System.debug(
      Util_Upsert.upsertList(OBJ_NAME, scope, MTD_NAME + ' of ' + CLS_NAME)
    );
  }

  public void finish(Database.BatchableContext bc) {
    // No post-batch processing required in this implementation
  }
}
