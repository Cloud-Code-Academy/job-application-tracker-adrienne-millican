/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-16-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class FederalRatesMetadataController {
  public static Map<String, Federal_Rates__mdt> federalRatesMap {
    get {
      if (federalRatesMap == null) {
        federalRatesMap = new Map<String, Federal_Rates__mdt>();
        federalRatesMap = Federal_Rates__mdt.getAll();
      }
      return federalRatesMap;
    }
    set;
  }

  @AuraEnabled(cacheable=true)
  public static Decimal getFederalRate(String rateType, Integer currYr) {
    Decimal fedRate = 0.00;
    List<Federal_Rates__mdt> federalRatesVals = federalRatesMap.values();
    for (Federal_Rates__mdt fedRateVal : federalRatesVals) {
      if (
        fedRateVal.DeveloperName.startsWith(rateType) &&
        fedRateVal.Year_Valid__c == currYr
      ) {
        return fedRateVal.Rate__c;
      }
    }
    System.debug('**Returning 0.00 rate for ' + rateType);
    return fedRate;
  }
}
