/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-29-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JobApplicationTriggerMethods {
  public static final String OBJ_NAME = 'Job Application';
  public static final String CLS_NAME = 'JobApplicationTriggerMethods';
  public static final StaticResource TASKJ = [
    SELECT Id, Body
    FROM StaticResource
    WHERE Name = 'JobApplicationJson'
    WITH SYSTEM_MODE
    LIMIT 1
  ];
  public static final String TASK_STR = TASKJ.Body.toString();

  // used for afterInsert
  public static String copyInfoFromPosition(
    Map<Id, Job_Application__c> newJobAppMap
  ) {
    final String MTH_NAME = 'copyInfoFromPosition';
    Set<Id> positionIdSet = new Set<Id>();
    for (Job_Application__c newJobApp : newJobAppMap.values()) {
      positionIdSet.add(newJobApp.Position__c);
    }
    Map<Id, Position__c> posnMap = new Map<Id, Position__c>(
      [
        SELECT
          Id,
          How_Paid__c,
          Position_Description__c,
          Company__c,
          Reported_Last_Updated__c,
          Salary__c
        FROM Position__c
        WHERE Id IN :positionIdSet
        WITH USER_MODE
      ]
    );
    List<Job_Application__c> jobAppLst = [
      SELECT
        Id,
        Position__c,
        How_Paid__c,
        Job_Description__c,
        Company__c,
        Position_Reported_Last_Updated__c,
        Salary__c
      FROM Job_Application__c
      WHERE Id IN :newJobAppMap.keySet()
      WITH USER_MODE
    ];
    for (Job_Application__c newJobApp : jobAppLst) {
      if (posnMap.keySet().contains(newJobApp.Position__c)) {
        Position__c posn = posnMap.get(newJobApp.Position__c);
        newJobApp.How_Paid__c = posn.How_Paid__c;
        newJobApp.Job_Description__c = posn.Position_Description__c;
        newJobApp.Company__c = posn.Company__c;
        newJobApp.Position_Reported_Last_Updated__c = posn.Reported_Last_Updated__c;
        newJobApp.Salary__c = posn.Salary__c;
      }
    }
    return updateParentJobApplications(jobAppLst);
  }

  // Used for before update
  public static void changeApplicationStatus(
    Map<Id, Job_Application__c> oldJobAppMap,
    Map<Id, Job_Application__c> newJobAppMap
  ) {
    final String MTH_NAME = 'changeApplicationStatus';
    for (Id jobId : newJobAppMap.keySet()) {
      Job_Application__c oldJobApp = oldJobAppMap?.get(jobId);
      Job_Application__c newJobApp = newJobAppMap.get(jobId);
      if (
        (newJobApp.Task_for_Stage_Completed__c &&
        (oldJobApp.Task_for_Stage_Completed__c !=
        newJobApp.Task_for_Stage_Completed__c) &&
        !newJobApp.Application_Status__c.equals('Closed'))
      ) {
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(
          TASK_STR
        );
        Map<String, List<String>> statusTaskMap = createTaskMapFromJson(
          jsonMap
        );
        Set<String> statusSet = statusTaskMap.keySet();
        List<String> statusLst = new List<String>(statusSet);
        Integer index = statusLst.indexOf(newJobApp.Application_Status__c);
        newJobApp.Application_Status__c = statusLst.get(index + 1);
      }
    }
  }

  // Used for afterInsert and afterUpdate
  public static String createTasksForStatus(
    Map<Id, Job_Application__c> oldJobAppMap,
    Map<Id, Job_Application__c> newJobAppMap
  ) {
    List<Job_Application__c> jobAppsToUpd = new List<Job_Application__c>();
    final String MTH_NAME = 'createTasksForStatus';
    List<Task> tskLstToUpsert = new List<Task>();
    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(
      TASK_STR
    );
    Map<String, List<String>> statusTaskMap = createTaskMapFromJson(jsonMap);
    for (Id jobId : newJobAppMap.keySet()) {
      Job_Application__c oldJobApp = oldJobAppMap?.get(jobId);
      Job_Application__c newJobApp = newJobAppMap.get(jobId);
      if (
        oldJobApp == null ||
        oldJobApp.Application_Status__c != newJobApp.Application_Status__c
      ) {
        List<String> taskLst = statusTaskMap.get(
          newJobApp.Application_Status__c
        );
        tskLstToUpsert.add(
          createJobAppTaskFromJson(
            newJobApp.Application_Status__c,
            taskLst,
            jobId
          )
        );
      }
    }
    return Util_Upsert.upsertList(
      'Task',
      tskLstToUpsert,
      MTH_NAME + ' of ' + CLS_NAME
    );
  }

  // Used for afterInsert and afterUpdate
  public static String createJobApplicationContacts(
    Map<Id, Job_Application__c> oldJobAppMap,
    Map<Id, Job_Application__c> newJobAppMap
  ) {
    String msg = '';
    final String MTH_NAME = 'createJobApplicationContacts';
    List<Job_Application_Contact__c> jobAppConsLst = new List<Job_Application_Contact__c>();
    Map<Id, Id> jobApptoPrimContactMap = new Map<Id, Id>();
    Map<Id, Job_Application__c> jobAppWithConsMap = new Map<Id, Job_Application__c>(
      [
        SELECT Id, (SELECT Id FROM Job_Application_Contacts__r)
        FROM Job_Application__c
        WHERE Id IN :newJobAppMap.keySet()
        WITH USER_MODE
      ]
    );

    List<Contact> consToAddLst = new List<Contact>();
    for (Id jobId : newJobAppMap.keySet()) {
      Job_Application__c oldJobApp = oldJobAppMap?.get(jobId);
      Job_Application__c newJobApp = newJobAppMap.get(jobId);
      Job_Application__c jobAppMap = jobAppWithConsMap.get(jobId);
      if (
        newJobApp.Company__c != null &&
        jobAppMap.Job_Application_Contacts__r.size() == 0
      ) {
        consToAddLst = [
          SELECT Id
          FROM Contact
          WHERE
            AccountId = :newJobApp.Company__c
            AND (Title LIKE 'Hiring%'
            OR Title LIKE '%Recruiter%'
            OR Title LIKE '%Human Resources%')
          WITH USER_MODE
          ORDER BY CreatedDate ASC
        ];
        for (Integer i = 0; i < consToAddLst.size(); i++) {
          Job_Application_Contact__c conToAdd = new Job_Application_Contact__c(
            Job_Application__c = jobId,
            Contact__c = consToAddLst[i].Id
          );
          jobAppConsLst.add(conToAdd);
          if (i == 0) {
            jobAppConsLst[0].Primary_JA_Contact__c = true;
            jobApptoPrimContactMap.put(jobId, consToAddLst[i].Id);
          }
        }
      }
    }
    msg = Util_Insert.insertList(
      'Job Application Contact',
      jobAppConsLst,
      MTH_NAME + ' of ' + CLS_NAME
    );
    if (msg.startsWith('**Inserted')) {
      Map<Id, Job_Application__c> jobAppMap = new Map<Id, Job_Application__c>(
        [
          SELECT Id, Primary_Contact__c
          FROM Job_Application__c
          WHERE Id IN :jobApptoPrimContactMap.keySet()
          WITH USER_MODE
        ]
      );

      for (Id jobAppId : jobApptoPrimContactMap.keySet()) {
        if (jobAppMap.keySet().contains(jobAppId)) {
          jobAppMap.get(jobAppId)
            .Primary_Contact__c = jobApptoPrimContactMap.get(jobAppId);
        }
      }
      return updateParentJobApplications(jobAppMap.values());
    }
    return msg;
  }

  // Used for afterInsert and afterUpdate
  public static String createJobApplicationNotes(
    Map<Id, Job_Application__c> oldJobAppMap,
    Map<Id, Job_Application__c> newJobAppMap
  ) {
    String msg = '';
    final String MTH_NAME = 'createJobApplicationNotes';
    List<Job_Application_Note__c> notesLstToInsert = new List<Job_Application_Note__c>();
    List<Job_Application__c> jobAppsToUpd = new List<Job_Application__c>();
    for (Id jobId : newJobAppMap.keySet()) {
      Job_Application__c oldJobApp = oldJobAppMap?.get(jobId);
      Job_Application__c newJobApp = newJobAppMap.get(jobId);
      if (
        (oldJobApp == null || oldJobApp.Notes__c != newJobApp.Notes__c) &&
        !String.isBlank(newJobApp.Notes__c)
      ) {
        Job_Application_Note__c newNote = new Job_Application_Note__c(
          CreatedById = UserInfo.getUserId(),
          Entry__c = newJobApp.Notes__c,
          Entry_Date_Time__c = System.now(),
          Job_Application__c = jobId
        );
        notesLstToInsert.add(newNote);
        jobAppsToUpd.add(newJobApp);
      }
    }
    msg = Util_Insert.insertList(
      'Job Application Note',
      notesLstToInsert,
      MTH_NAME + ' of ' + CLS_NAME
    );
    if (msg.startsWith('**Inserted')) {
      jobAppsToUpd = [
        SELECT Id, Notes__c
        FROM Job_Application__c
        WHERE Id IN :jobAppsToUpd
        WITH USER_MODE
      ];
      for (Job_Application__c jobApp : jobAppsToUpd) {
        jobApp.Notes__c = '';
      }
      msg = updateParentJobApplications(jobAppsToUpd);
    }
    return msg;
  }

  //private helper method

  @testVisible
  private static String updateParentJobApplications(
    List<Job_Application__c> jobAppLst
  ) {
    final String MTH_NAME = 'updateParentJobApplications';
    String msg = Util_Upsert.upsertList(
      'Job Application',
      jobAppLst,
      MTH_NAME + ' of ' + CLS_NAME
    );
    return msg;
  }

  //private helper method
  @TestVisible
  private static Task createJobAppTaskFromJson(
    String statusVal,
    List<String> taskLst,
    Id jobAppId
  ) {
    Task tsk = new Task(
      Subject = 'To-Dos for ' + statusVal + ' Status',
      Type = 'Job Application To-Dos',
      Status = 'Not Started',
      Priority = 'High',
      ActivityDate = System.today() + 7,
      WhatId = jobAppId
    );
    for (String taskLine : taskLst) {
      if (tsk.Description == null) {
        tsk.Description = '* ' + taskLine + '\n';
      } else {
        tsk.Description += '* ' + taskLine + '\n';
      }
    }
    return tsk;
  }

  // private static helper method
  private static Map<String, List<String>> createTaskMapFromJson(
    Map<String, Object> jsonMap
  ) {
    List<Object> statusObjLst = (List<Object>) jsonMap.get('statuses');
    Map<String, List<String>> statusTaskMap = new Map<String, List<String>>();
    for (Integer i = 0; i < statusObjLst.size(); i++) {
      Map<String, Object> indivStatusObjLst = (Map<String, Object>) statusObjLst.get(
        i
      );
      String statusVal = (String) indivStatusObjLst.get('Status');
      List<Object> taskObjLst = (List<Object>) indivStatusObjLst.get('Tasks');
      List<String> taskStrLst = new List<String>();
      for (Object taskObj : taskObjLst) {
        Map<String, Object> taskMap = (Map<String, Object>) taskObj;
        String taskDesc = (String) taskMap.get('Task');
        taskStrLst.add(taskDesc);
      }
      statusTaskMap.put(statusVal, taskStrLst);
    }
    return statusTaskMap;
  }
}
