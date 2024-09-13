/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-11-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JobApplicationTriggerMethods {
  public static final String OBJ_NAME = 'Job_Application__c';
  public static String callingMethod = 'createJobApplicationNote';
  public Job_Application_Note__c createJobApplicationNote(
    String noteTxt,
    String jobAppId
  ) {
    Job_Application_Note__c newNote = new Job_Application_Note__c(
      Job_Application__c = jobAppId,
      Entry__c = noteTxt,
      Entry_Date_Time__c = System.now()
    );
    return newNote;
  }

  public String createJobApplicationNotes(
    Map<Id, Job_Application__c> oldJobAppLst,
    Map<Id, Job_Application__c> newJobAppLst
  ) {
    final String MTHD_NAME = 'createJobApplicationNotes';
    List<Job_Application_Note__c> jobAppNotesLst = new List<Job_Application_Note__c>();
    for (Job_Application__c newJobApp : newJobAppLst.values()) {
      Job_Application__c oldJobApp = oldJobAppLst.get(newJobApp.Id);
      if (
        newJobApp.Notes__c != oldJobApp.Notes__c &&
        !String.isBlank(newJobApp.Notes__c)
      ) {
        jobAppNotesLst.add(
          this.createJobApplicationNote(newJobApp.Notes__c, newJobApp.Id)
        );
      }
    }
    return Util_Insert.insertList(
      'Job_Application_Note__c',
      jobAppNotesLst,
      MTHD_NAME
    );
  }
}
