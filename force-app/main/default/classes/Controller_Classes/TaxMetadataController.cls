/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-23-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class TaxMetadataController {
  public static Map<String, Tax_Bracket__mdt> taxBracketMap {
    get {
      if (taxBracketMap == null) {
        taxBracketMap = new Map<String, Tax_Bracket__mdt>();
        taxBracketMap = Tax_Bracket__mdt.getAll();
      }
      return taxBracketMap;
    }
    set;
  }

  @AuraEnabled
  public static String getTaxBracketName(
    String filingStatusVal,
    Decimal taxableInc,
    Integer currYr
  ) {
    String taxBrName = '';
    String subStr = filingStatusVal.subString(0, 3);
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();
    for (Tax_Bracket__mdt taxBracket : taxBracketVals) {
      if (
        filingStatusVal != null &&
        taxableInc != null &&
        currYr != null &&
        taxBracket.DeveloperName.startsWith(subStr) &&
        (Decimal) (taxBracket.Starting_Salary__c) <= taxableInc &&
        (taxBracket.Ending_Salary__c == 0 ||
        (Decimal) (taxBracket.Ending_Salary__c) >= taxableInc) &&
        taxBracket.Year_Valid__c == currYr
      ) {
        System.debug('**Found match on ' + taxBracket.developername);
        taxBrName = taxBracket.masterLabel;
        System.debug('**Returning taxBracketName of ' + taxBrName);
        return taxBrName;
      }
    }

    return taxBrName;
  }

  @AuraEnabled
  public static Decimal getStartingSalaryForTaxBracketName(
    String taxBrName,
    Integer currYr
  ) {
    Decimal startingSal = 0.00;
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();
    for (Tax_Bracket__mdt taxBracket : taxBracketVals) {
      if (
        taxBrName != null &&
        currYr != null &&
        taxBracket.MasterLabel.equals(taxBrName) &&
        taxBracket.Year_Valid__c == currYr
      ) {
        System.debug(
          '**Found starting sal match on ' + taxBracket.developername
        );
        startingSal = (Decimal) taxBracket.Starting_Salary__c;
        System.debug('**Returning starting salary match of ' + startingSal);
        return startingSal;
      }
    }

    return startingSal;
  }

  @AuraEnabled
  public static Decimal getEndingSalaryForTaxBracketName(
    String taxBrName,
    Integer currYr
  ) {
    Decimal endingSal = 0.00;
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();
    for (Tax_Bracket__mdt taxBracket : taxBracketVals) {
      if (
        taxBrName != null &&
        currYr != null &&
        taxBracket.MasterLabel.equals(taxBrName) &&
        taxBracket.Year_Valid__c == currYr
      ) {
        System.debug('**Found ending sal match on ' + taxBracket.developername);
        endingSal = (Decimal) taxBracket.Ending_Salary__c;
        System.debug('**Returning ending salary match of ' + endingSal);
        return endingSal;
      }
    }

    return endingSal;
  }

  @AuraEnabled
  public static Decimal getTaxRateForTaxBracketName(
    String taxBrName,
    Integer currYr
  ) {
    Decimal taxRate = 0.00;
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();
    for (Tax_Bracket__mdt taxBracket : taxBracketVals) {
      if (
        taxBrName != null &&
        currYr != null &&
        taxBracket.MasterLabel.equals(taxBrName) &&
        taxBracket.Year_Valid__c == currYr
      ) {
        System.debug('**Found tax Rate match on ' + taxBracket.developername);
        taxRate = Decimal.valueOf(taxBracket.Tax_Rate__c);
        System.debug('**Returning rate of ' + taxRate);
        return taxRate;
      }
    }

    return taxRate;
  }
}