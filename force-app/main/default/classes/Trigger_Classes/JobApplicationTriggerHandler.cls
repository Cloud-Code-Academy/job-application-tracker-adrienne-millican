/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-29-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JobApplicationTriggerHandler extends TriggerHandler implements ItriggerHandler {
  public static final String OBJ = 'Job Application';

  public JobApplicationTriggerHandler(String objName) {
    super(objName);
  }

  public static void beforeInsert(List<sObject> newItemLst) {
    System.debug(
      '**No beforeInsert methods to run for JobApplicationTriggerHandler**'
    );
  }

  public static void afterInsert(Map<Id, SObject> newItems) {
    Set<String> afterInsMethods = new Set<String>{
      'createTasksForStatus',
      'createJobApplicationContacts',
      'copyInfoFromPosition',
      'createJobApplicationNotes'
    };
    if (
      !TriggerHandler.isDisabled &&
      !TriggerHandler.isExempt &&
      !RecursiveChecker.hasRun(OBJ, afterInsMethods)
    ) {
      // Cast the Trigger.NewMap Map of Id, sObjects to Map of Id, Job Application to pass to Business Logic classes
      System.debug(
        '***JobApplicationTriggerHandler is running afterInsert methods. ***'
      );
      Map<Id, Job_Application__c> newJobAppMap = (Map<Id, Job_Application__c>) newItems;
      JobApplicationTriggerMethods.copyInfoFromPosition(newJobAppMap);
      JobApplicationTriggerMethods.createJobApplicationContacts(
        null,
        newJobAppMap
      );
      JobApplicationTriggerMethods.createTasksForStatus(null, newJobAppMap);
      JobApplicationTriggerMethods.createJobApplicationNotes(
        null,
        newJobAppMap
      );
      RecursiveChecker.addMethodNames(OBJ, afterInsMethods);
    } else {
      System.debug(
        '*** JobApplicationTriggerHandler is disabled or afterInsert methods have already run ***'
      );
    }
  }

  public static void beforeUpdate(
    Map<Id, sObject> newItems,
    Map<Id, sObject> oldItems
  ) {
    Set<String> beforeUpdMethods = new Set<String>{ 'changeApplicationStatus' };
    if (
      !TriggerHandler.isDisabled &&
      !TriggerHandler.isExempt &&
      !RecursiveChecker.hasRun(OBJ, beforeUpdMethods)
    ) {
      System.debug(
        '*** JobApplicationTriggerHandler is running afterInsert methods. ***'
      );
      // Cast the Trigger.OldMap Map of Id, sObjects to Map of Id, Opportunities to pass to Business Logic classes
      Map<Id, Job_Application__c> oldJobAppMap = (Map<Id, Job_Application__c>) oldItems;
      // Cast the Trigger.NewMap Map of Id, sObjects to Map of Id, Job Application to pass to Business Logic classes
      Map<Id, Job_Application__c> newJobAppMap = (Map<Id, Job_Application__c>) newItems;
      JobApplicationTriggerMethods.changeApplicationStatus(
        oldJobAppMap,
        newJobAppMap
      );
      RecursiveChecker.addMethodNames(OBJ, beforeUpdMethods);
    } else {
      System.debug(
        '*** JobApplicationTriggerHandler is disabled or beforeUpdate methods have already run ***'
      );
    }
  }

  public static void afterUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    Set<String> afterUpdMethods = new Set<String>{
      'createTasksForStatus',
      'createJobApplicationNotes',
      'createJobApplicationContacts'
    };
    if (
      !TriggerHandler.isDisabled &&
      !TriggerHandler.isExempt &&
      !RecursiveChecker.hasRun(OBJ, afterUpdMethods)
    ) {
      // Cast the Trigger.NewMap Map of Id, sObjects to Map of Id, Opportunities to pass to Business Logic classes
      System.debug(
        '*** JobApplicationTriggerHandler is running afterUpdate methods. ***'
      );
      Map<Id, Job_Application__c> newJobAppMap = (Map<Id, Job_Application__c>) newItems;
      // Cast the Trigger.OldMap Map of Id, sObjects to Map of Id, Opportunities to pass to Business Logic classes
      Map<Id, Job_Application__c> oldJobAppMap = (Map<Id, Job_Application__c>) oldItems;
      JobApplicationTriggerMethods.createTasksForStatus(
        oldJobAppMap,
        newJobAppMap
      );
      JobApplicationTriggerMethods.createJobApplicationNotes(
        oldJobAppMap,
        newJobAppMap
      );
      JobApplicationTriggerMethods.createJobApplicationContacts(
        oldJobAppMap,
        newJobAppMap
      );
      RecursiveChecker.addMethodNames(OBJ, afterUpdMethods);
    } else {
      System.debug(
        '*** JobApplicationTriggerHandler is disabled or afterUpdate methods have already run ***'
      );
    }
  }

  public static void beforeDelete(Map<Id, sObject> oldItems) {
    System.debug(
      '**No beforeDelete methods to run for JobApplicationTriggerHandler**'
    );
  }

  public static void afterDelete(Map<Id, SObject> oldItems) {
    System.debug(
      '**No afterDelete methods to run for JobApplicationTriggerHandler**'
    );
  }

  public static void afterUndelete(Map<Id, SObject> newItems) {
    System.debug(
      '**No afterUndelete methods to run for JobApplicationTriggerHandler**'
    );
  }
}
