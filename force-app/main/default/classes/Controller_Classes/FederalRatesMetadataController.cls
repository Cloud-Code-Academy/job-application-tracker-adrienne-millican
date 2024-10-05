/**
 * @description       : This class is used to retrieve federal rates for Social Security and Medicare from custom metadata.
 *                      The metadata includes rates and maximum applicable values based on the year.
 *                      It provides methods to fetch rates for a given year, handling cases where the year is not found or invalid.
 * @author            : admillican08@gmail.com
 * @last modified on  : 09-24-2024
 **/
public with sharing class FederalRatesMetadataController {
  // Constant for Social Security
  public static final String SOC_SEC = 'Social_Security';

  // Constant for Medicare
  public static final String MED = 'Medicare';

  // This map will store the custom metadata records for federal rates
  public static Map<String, Federal_Rates__mdt> federalRatesMap {
    get {
      // Lazy initialization: Only populate the map if it's not already loaded
      if (federalRatesMap == null) {
        federalRatesMap = new Map<String, Federal_Rates__mdt>();

        // Populate the map with all records from the Federal_Rates__mdt custom metadata
        federalRatesMap = Federal_Rates__mdt.getAll();
      }
      return federalRatesMap; // Return the populated map
    }
    set;
  }

  /**
   * @description       : Retrieves the Social Security rate for the given year.
   * @param currYr      : The year for which the rate is being requested (e.g., 2024).
   * @return            : The Social Security rate as a Decimal, or 0.00 if the year is not found or invalid.
   **/
  @AuraEnabled(cacheable=true)
  public static Decimal getSocialSecurityRate(Integer currYr) {
    Decimal socSecRate = 0.00; // Default rate is 0.00

    // Loop through the values of the federalRatesMap
    List<Federal_Rates__mdt> federalRatesVals = federalRatesMap.values();
    for (Federal_Rates__mdt fedRateVal : federalRatesVals) {
      // Check if the year and DeveloperName match the requested year and Social Security
      if (
        currYr != null &&
        fedRateVal.DeveloperName.equals(SOC_SEC) &&
        fedRateVal.Year_Valid__c == currYr
      ) {
        return fedRateVal.Rate__c; // Return the Social Security rate if found
      }
    }

    // If no valid record is found, return the default rate (0.00)
    return socSecRate;
  }

  /**
   * @description       : Retrieves the Social Security maximum value (cap on taxable income) for the given year.
   * @param currYr      : The year for which the maximum value is being requested.
   * @return            : The Social Security max value as a Decimal, or 0.00 if the year is not found or invalid.
   **/
  @AuraEnabled(cacheable=true)
  public static Decimal getSocialSecurityMaxVal(Integer currYr) {
    Decimal socSecMaxVal = 0.00; // Default maximum value is 0.00

    // Loop through the values of the federalRatesMap
    List<Federal_Rates__mdt> federalRatesVals = federalRatesMap.values();
    for (Federal_Rates__mdt fedRateVal : federalRatesVals) {
      // Check if the year and DeveloperName match the requested year and Social Security
      if (
        currYr != null &&
        fedRateVal.DeveloperName.equals(SOC_SEC) &&
        fedRateVal.Year_Valid__c == currYr
      ) {
        return fedRateVal.Max_Value__c; // Return the Social Security max value if found
      }
    }

    // If no valid record is found, return the default max value (0.00)
    return socSecMaxVal;
  }

  /**
   * @description       : Retrieves the Medicare rate for the given year.
   * @param currYr      : The year for which the rate is being requested (e.g., 2024).
   * @return            : The Medicare rate as a Decimal, or 0.00 if the year is not found or invalid.
   **/
  @AuraEnabled(cacheable=true)
  public static Decimal getMedicareRate(Integer currYr) {
    Decimal medicareRate = 0.00; // Default rate is 0.00

    // Loop through the values of the federalRatesMap
    List<Federal_Rates__mdt> federalRatesVals = federalRatesMap.values();
    for (Federal_Rates__mdt fedRateVal : federalRatesVals) {
      // Check if the year and DeveloperName match the requested year and Medicare
      if (
        currYr != null &&
        fedRateVal.DeveloperName.equals(MED) &&
        fedRateVal.Year_Valid__c == currYr
      ) {
        return fedRateVal.Rate__c; // Return the Medicare rate if found
      }
    }

    // If no valid record is found, return the default rate (0.00)
    return medicareRate;
  }
}