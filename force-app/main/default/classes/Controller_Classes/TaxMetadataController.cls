/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-19-2024
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

  @AuraEnabled(cacheable=true)
  public static Decimal getTaxRatePercentage(
    String filingStatusVal,
    Decimal salAmt,
    Integer currYr
  ) {
    Decimal taxBr = 0.00;
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();
    for (Tax_Bracket__mdt taxBracket : taxBracketVals) {
      if (
        filingStatusVal != null &&
        salAmt != null &&
        currYr != null &&
        taxBracket.DeveloperName.startsWith(filingStatusVal) &&
        (Decimal) (taxBracket.Starting_Salary__c) <= salAmt &&
        (taxBracket.Ending_Salary__c == 0 ||
        (Decimal) (taxBracket.Ending_Salary__c) >= salAmt) &&
        taxBracket.Year_Valid__c == currYr
      ) {
        System.debug('**Found match on ' + taxBracket.developername);
        return Decimal.valueOf(taxBracket.Tax_Rate__c);
      }
    }
    System.debug('**Returning 0.00 tax rate');
    return taxBr;
  }
}
