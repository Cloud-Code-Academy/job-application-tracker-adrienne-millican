/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-18-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class FederalRatesMetadataController {
  public static final String SOC_SEC = 'Social_Security';
  public static final String MED = 'Medicare';

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
  public static Decimal getSocialSecurityRate(Integer currYr) {
    Decimal socSecRate = 0.00;
    List<Federal_Rates__mdt> federalRatesVals = federalRatesMap.values();
    for (Federal_Rates__mdt fedRateVal : federalRatesVals) {
      System.debug('**Current federalRateValue: ' + fedRateVal);
      if (
        fedRateVal.DeveloperName.equals(SOC_SEC) &&
        fedRateVal.Year_Valid__c == currYr
      ) {
        return fedRateVal.Rate__c;
      }
    }
    System.debug('**Returning 0.00 rate for ' + SOC_SEC);
    return socSecRate;
  }

  @AuraEnabled(cacheable=true)
  public static Decimal getMedicareRate(Integer currYr) {
    Decimal medicareRate = 0.00;
    List<Federal_Rates__mdt> federalRatesVals = federalRatesMap.values();
    for (Federal_Rates__mdt fedRateVal : federalRatesVals) {
      if (
        currYr != null &&
        fedRateVal.DeveloperName.equals(MED) &&
        fedRateVal.Year_Valid__c == currYr
      ) {
        return fedRateVal.Rate__c;
      }
    }
    System.debug('**Returning 0.00 rate for ' + MED);
    return medicareRate;
  }
}
