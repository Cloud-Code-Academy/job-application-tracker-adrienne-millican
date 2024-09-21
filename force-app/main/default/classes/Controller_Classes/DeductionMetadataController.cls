/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-20-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class DeductionMetadataController {
  public static Map<String, Standard_Deduction__mdt> deductionMap {
    get {
      if (deductionMap == null) {
        deductionMap = new Map<String, Standard_Deduction__mdt>();
        deductionMap = Standard_Deduction__mdt.getAll();
      }
      return deductionMap;
    }
    set;
  }

  @AuraEnabled(cacheable=true)
  public static Decimal getStandardDeduction(
    String filingStatusVal,
    Integer currYr
  ) {
    Decimal deductAmt = 0.00;
    List<Standard_Deduction__mdt> deductionVals = deductionMap.values();
    for (Standard_Deduction__mdt deduction : deductionVals) {
      if (
        filingStatusVal != null &&
        currYr != null &&
        deduction.Year_Valid__c == currYr
      ) {
        System.debug('**Deduction: ' + deduction.DeveloperName);
        String devNme = deduction.DeveloperName;
        if (devNme.equals(filingStatusVal)) {
          System.debug('**Matched on filingstatusVal');
          return (Decimal) (deduction.Amount__c);
        } else if (
          devNme.contains(filingStatusVal) &&
          devNme.contains('_SR') &&
          devNme.contains('BL') &&
          filingStatusVal.contains('_SR') &&
          filingStatusVal.contains('_BL')
        ) {
          System.debug('**Matched on filingstatusVal and BL and SR');
          return (Decimal) (deduction.Amount__c);
        } else if (
          devNme.contains(filingStatusVal) &&
          devNme.contains('_SR') &&
          filingStatusVal.contains('_SR')
        ) {
          System.debug('**Matched on filingstatusVal and SR');
          return (Decimal) (deduction.Amount__c);
        } else if (
          devNme.contains(filingStatusVal) &&
          devNme.contains('_BL') &&
          filingStatusVal.contains('_BL')
        ) {
          System.debug('**Matched on filingstatusVal and BL');
          return (Decimal) (deduction.Amount__c);
        }
      }
    }
    return deductAmt;
  }

   @AuraEnabled(cacheable=true)
  public static Decimal getStandardDeduction(
    String filingStatusVal,
    Integer currYr,
    Boolean isSenior,
    Boolean isBlind
  ) {
    Decimal deductAmt = 0.00;
    List<Standard_Deduction__mdt> deductionVals = deductionMap.values();
    for (Standard_Deduction__mdt deduction : deductionVals) {
      if (
        filingStatusVal != null &&
        currYr != null &&
        deduction.Year_Valid__c == currYr
      ) {
        System.debug('**Deduction: ' + deduction.DeveloperName);
        String devNme = deduction.DeveloperName;
        if (devNme.equals(filingStatusVal)) {
          System.debug('**Matched on filingstatusVal');
          return (Decimal) (deduction.Amount__c);
        } else if (
          devNme.contains(filingStatusVal) &&
          devNme.contains('_SR') &&
          devNme.contains('BL') &&
          filingStatusVal.contains('_SR') &&
          filingStatusVal.contains('_BL')
        ) {
          System.debug('**Matched on filingstatusVal and BL and SR');
          return (Decimal) (deduction.Amount__c);
        } else if (
          devNme.contains(filingStatusVal) &&
          devNme.contains('_SR') &&
          filingStatusVal.contains('_SR')
        ) {
          System.debug('**Matched on filingstatusVal and SR');
          return (Decimal) (deduction.Amount__c);
        } else if (
          devNme.contains(filingStatusVal) &&
          devNme.contains('_BL') &&
          filingStatusVal.contains('_BL')
        ) {
          System.debug('**Matched on filingstatusVal and BL');
          return (Decimal) (deduction.Amount__c);
        }
      }
    }
    return deductAmt;
  }

}
