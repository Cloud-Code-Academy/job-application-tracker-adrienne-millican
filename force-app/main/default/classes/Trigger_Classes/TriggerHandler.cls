/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-12-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing virtual class TriggerHandler {
  public static boolean isDisabled { get; private set; }
  public static boolean isExempt { get; private set; }

  public TriggerHandler(String sObjName) {
    List<Trigger_Setting__mdt> trigSet = [
      SELECT Id, sObject__c, Trigger_Disabled__c
      FROM Trigger_Setting__mdt
      WHERE sObject__c = :sObjName
      WITH SYSTEM_MODE
    ];
    isDisabled = trigSet.isEmpty() ? false : trigSet[0].Trigger_Disabled__c;
    isExempt = FeatureManagement.checkPermission('Trigger_Exempt');
  }

  public static Boolean setIsDisabled(Boolean isDsbld) {
    isDisabled = isDsbld;
    return isDisabled;
  }
}
