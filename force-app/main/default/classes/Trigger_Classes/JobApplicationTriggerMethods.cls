/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-27-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JobApplicationTriggerMethods {
  public static final String OBJ_NAME = 'Job Application';
  public static final String CLS_NAME = 'JobApplicationTriggerMethods';

  public String createTasksForStatus(
    Map<Id, Job_Application__c> oldJobAppMap,
    Map<Id, Job_Application__c> newJobAppMap
  ) {
    String msg = '';
    final String MTH_NAME = 'createTasksForStatus';
    List<Task> tskLstToUpsert = new List<Task>();
    StaticResource taskJ = [
      SELECT Id, Body
      FROM StaticResource
      WHERE Name = 'JobApplicationJson'
      LIMIT 1
    ];
    String taskJStr = taskJ.Body.toString();
    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(
      taskJStr
    );
    Map<String, List<String>> statusTasksMap = createTaskMapFromJson(jsonMap);
    for (Id jobId : newJobAppMap.keySet()) {
      Job_Application__c oldJobApp = oldJobAppMap?.get(jobId);
      Job_Application__c newJobApp = newJobAppMap.get(jobId);
      if (
        oldJobApp == null ||
        oldJobApp.Application_Status__c != newJobApp.Application_Status__c
      ) {
        List<String> taskLst = statusTasksMap.get(
          newJobApp.Application_Status__c
        );
        tskLstToUpsert.add(createJobAppTaskFromJson(taskLst, jobId));
      }
    }
    msg = Util_Upsert.upsertList(
      'Task',
      tskLstToUpsert,
      MTH_NAME + ' of ' + CLS_NAME
    );
    return msg;
  }

  public String copyInfoFromPosition(Map<Id, Job_Application__c> newJobAppMap) {
    String msg = '';
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
    msg = Util_Upsert.upsertList(
      'Task',
      jobAppLst,
      MTH_NAME + ' of ' + CLS_NAME
    );
    return msg;
  }

  @TestVisible
  private Task createJobAppTaskFromJson(List<String> taskLst, Id jobAppId) {
    Task tsk = new Task(
      Subject = 'Job Application To-Dos',
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

  @testVisible
  private Map<String, List<String>> createTaskMapFromJson(
    Map<String, Object> jsonMap
  ) {
    List<Object> statuses = (List<Object>) jsonMap.get('statuses');
    Map<String, List<String>> statusTasksMap = new Map<String, List<String>>();
    for (Integer i = 0; i < statuses.size(); i++) {
      Map<String, Object> indivStatus = (Map<String, Object>) statuses.get(i);
      String statusVal = (String) indivStatus.get('Status');
      System.debug('**statusVal: ' + statusVal);
      List<Object> taskObjLst = (List<Object>) indivStatus.get('Tasks');
      List<String> taskStrLst = new List<String>();
      for (Object taskObj : taskObjLst) {
        Map<String, Object> taskMap = (Map<String, Object>) taskObj;
        String taskDesc = (String) taskMap.get('Task');
        System.debug('**taskDesc ' + taskDesc);
        taskStrLst.add(taskDesc);
      }

      statusTasksMap.put(statusVal, taskStrLst);
    }
    return statusTasksMap;
  }
}
