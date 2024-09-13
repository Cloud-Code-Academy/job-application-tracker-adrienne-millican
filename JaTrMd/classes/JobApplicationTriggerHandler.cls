/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-12-2024
 * @last modified by  : admillican08@gmail.com
 **/

public without sharing class JobApplicationTriggerHandler extends TriggerHandler implements ITriggerHandler {
  public static final String OBJ = 'Job_Application__c';
  public static boolean isDisabled { get; private set; }

  public static boolean isExempt { get; private set; }

  public JobApplicationTriggerHandler(String objName) {
    super(objName);
  }

  public void beforeInsert(List<sObject> newItemLst) {
  }

  public void afterInsert(Map<Id, SObject> newItems) {
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
    Set<String> afterUpdMethods = new Set<String>{};
    if (
      !isDisabled &&
      !isExempt &&
      !RecursiveChecker.hasRun(OBJ, afterUpdMethods)
    ) {
      // Cast the Trigger.NewMap Map of Id, sObjects to Map of Id, Opportunities to pass to Business Logic classes
      System.debug(
        '*** OpportunityTriggerHandler is running afterUpdate methods. ***'
      );
      Map<Id, Opportunity> newOppMap = (Map<Id, Opportunity>) newItems;
      // Cast the Trigger.OldMap Map of Id, sObjects to Map of Id, Opportunities to pass to Business Logic classes
      Map<Id, Opportunity> oldOppMap = (Map<Id, Opportunity>) oldItems;
      RecursiveChecker.addMethodNames(OBJ, afterUpdMethods);
    } else {
      System.debug(
        '*** OpportunityTriggerHandler is disabled or afterUpdate methods have already run ***'
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