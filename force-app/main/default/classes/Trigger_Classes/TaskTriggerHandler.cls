/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-29-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class TaskTriggerHandler extends TriggerHandler implements ItriggerHandler {
  public static final String OBJ = 'Task';

  public TaskTriggerHandler(String objName) {
    super(objName);
  }

  public void beforeInsert(List<sObject> newItemLst) {
  }

  public void afterInsert(Map<Id, SObject> newItems) {
    Set<String> afterInsMethods = new Set<String>{
      'setTaskForStageCompletedToFalseToParent'
    };
    if (
      !TriggerHandler.isDisabled &&
      !TriggerHandler.isExempt &&
      !RecursiveChecker.hasRun(OBJ, afterInsMethods)
    ) {
      // Cast the Trigger.NewMap Map of Id, sObjects to Map of Id, Tasks to pass to Business Logic classes
      System.debug(
        '*** TaskTriggerHandler is running afterInsert methods. ***'
      );
      Map<Id, Task> newTaskMap = (Map<Id, Task>) newItems;
      TaskTriggerMethods taskMthds = new TaskTriggerMethods();
      taskMthds.setTaskForStageCompletedToFalseOnParent(newTaskMap);
    } else {
      System.debug(
        '*** TaskTriggerHandler is disabled or afterInsert methods have already run ***'
      );
    }
  }

  public void beforeUpdate(
    Map<Id, sObject> newItems,
    Map<Id, sObject> oldItems
  ) {
  }

  public void afterUpdate(
    Map<Id, SObject> newItems,
    Map<Id, SObject> oldItems
  ) {
    Set<String> afterUpdMethods = new Set<String>{
      'setTaskForStageCompletedToTrueOnParent'
    };
    if (
      !TriggerHandler.isDisabled &&
      !TriggerHandler.isExempt &&
      !RecursiveChecker.hasRun(OBJ, afterUpdMethods)
    ) {
      System.debug(
        '*** TaskTriggerHandler is running afterUpdate methods. ***'
      );
      // Cast the Trigger.NewMap Map of Id, sObjects to Map of Id, Tasks to pass to Business Logic classes
      Map<Id, Task> newTaskMap = (Map<Id, Task>) newItems;
      // Cast the Trigger.OldMap Map of Id, sObjects to Map of Id, Tasks to pass to Business Logic classes
      Map<Id, Task> oldTaskMap = (Map<Id, Task>) oldItems;

      TaskTriggerMethods taskMthds = new TaskTriggerMethods();
      taskMthds.setTaskForStageCompletedToTrueOnParent(oldTaskMap, newTaskMap);
    } else {
      System.debug(
        '*** TaskTriggerHandler is disabled or afterUpdate methods have already run ***'
      );
    }
  }

  public void beforeDelete(Map<Id, sObject> oldItems) {
  }

  public void afterDelete(Map<Id, SObject> oldItems) {
  }

  public void afterUndelete(Map<Id, SObject> newItems) {
  }
}
