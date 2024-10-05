/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-29-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class TaskTriggerMethods {
  public static final String OBJ_NAME = 'Task';
  public static final String CLS_NAME = 'TaskTriggerMethods';

  // used for afterInsert
  public String setTaskForStageCompletedToFalseOnParent(
    Map<Id, Task> newTaskMap
  ) {
    final String MTH_NAME = 'setTaskForStageCompletedToFalseToParent';
    List<Job_Application__c> jobAppsToUpd = new List<Job_Application__c>();
    Set<Id> jobAppIdSet = new Set<Id>();
    for (Id taskId : newTaskMap.keySet()) {
      Task newTask = newTaskMap.get(taskId);
      if (
        newTask.Subject.startsWith('To-Dos') &&
        newTask.Subject.contains('Status') &&
        newTask.Status.equals('Not Started')
      ) {
        jobAppIdSet.add(newTask.WhatId);
      }
    }
    jobAppsToUpd = [
      SELECT Id, Task_for_Stage_Completed__c
      FROM Job_Application__c
      WHERE Id IN :jobAppIdSet AND Application_Status__c != 'Closed'
      WITH USER_MODE
    ];
    for (Job_Application__c jobApp : jobAppsToUpd) {
      jobApp.Task_for_Stage_Completed__c = false;
    }
    return Util_Upsert.upsertList(
      'Job Application',
      jobAppsToUpd,
      MTH_NAME + ' of ' + CLS_NAME
    );
  }

  // used for afterUpdate
  public String setTaskForStageCompletedToTrueOnParent(
    Map<Id, Task> oldTaskMap,
    Map<Id, Task> newTaskMap
  ) {
    final String MTH_NAME = 'setTaskForStageCompletedToTrueOnParent';
    List<Job_Application__c> jobAppsToUpd = new List<Job_Application__c>();
    Set<Id> jobAppIdSet = new Set<Id>();
    for (Id taskId : newTaskMap.keySet()) {
      Task oldTask = oldTaskMap.get(taskId);
      Task newTask = newTaskMap.get(taskId);
      if (
        !oldTask.Status.equals(newTask.Status) &&
        newTask.Subject.startsWith('To-Dos') &&
        newTask.Subject.contains('Status') &&
        !oldTask.Status.equals('Completed') &&
        newTask.Status.equals('Completed')
      ) {
        jobAppIdSet.add(newTask.WhatId);
      }
    }
    jobAppsToUpd = [
      SELECT Id, Task_for_Stage_Completed__c
      FROM Job_Application__c
      WHERE Id IN :jobAppIdSet AND Application_Status__c != 'Closed'
      WITH USER_MODE
    ];
    for (Job_Application__c jobApp : jobAppsToUpd) {
      jobApp.Task_for_Stage_Completed__c = true;
    }
    return Util_Upsert.upsertList(
      'Job Application',
      jobAppsToUpd,
      MTH_NAME + ' of ' + CLS_NAME
    );
  }
}