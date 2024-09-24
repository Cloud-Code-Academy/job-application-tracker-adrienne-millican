/**
 * @description       : This class is used to retrieve tax bracket information from custom metadata.
 *                      It provides methods to fetch tax bracket names, starting/ending salary values,
 *                      and tax rates based on the filing status, taxable income, and the year.
 *                      The custom metadata (Tax_Bracket__mdt) is used to store these values.
 * @author            : admillican08@gmail.com
 * @last modified on  : 09-24-2024
 */
public with sharing class TaxMetadataController {
  // A map to store the tax bracket metadata records for quick access
  public static Map<String, Tax_Bracket__mdt> taxBracketMap {
    get {
      // Lazy initialization: Only populate the map if it is not already initialized
      if (taxBracketMap == null) {
        taxBracketMap = new Map<String, Tax_Bracket__mdt>();

        // Retrieve all tax bracket records from the custom metadata and store them in the map
        taxBracketMap = Tax_Bracket__mdt.getAll();
      }
      return taxBracketMap;
    }
    set;
  }

  /**
   * @description       : Retrieves the tax bracket name based on filing status, taxable income, and year.
   * @param filingStatusVal : The filing status (e.g., Single, Married, etc.).
   * @param taxableInc    : The taxable income for which the tax bracket is being looked up.
   * @param currYr        : The current year for which the tax bracket is applicable.
   * @return              : The tax bracket name, or an empty string if no matching record is found.
   */
  @AuraEnabled
  public static String getTaxBracketName(
    String filingStatusVal,
    Decimal taxableInc,
    Integer currYr
  ) {
    String taxBrName = ''; // Initialize with an empty string to return in case of no match

    // Extract the first 3 characters from the filing status for comparison (e.g., "Sin" for "Single")
    String subStr = filingStatusVal.subString(0, 3);

    // Retrieve all tax bracket values from the map
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();

    // Loop through each tax bracket and check if it matches the input criteria
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
        // If a match is found, return the tax bracket name (MasterLabel)
        taxBrName = taxBracket.masterLabel;
        return taxBrName;
      }
    }

    // Return the tax bracket name (empty string if no match was found)
    return taxBrName;
  }

  /**
   * @description       : Retrieves the starting salary for a given tax bracket name and year.
   * @param taxBrName    : The name of the tax bracket.
   * @param currYr       : The current year for which the starting salary is applicable.
   * @return             : The starting salary for the tax bracket, or 0.00 if no matching record is found.
   */
  @AuraEnabled
  public static Decimal getStartingSalaryForTaxBracketName(
    String taxBrName,
    Integer currYr
  ) {
    Decimal startingSal = 0.00; // Default value in case no match is found

    // Retrieve all tax bracket values from the map
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();

    // Loop through each tax bracket and check if it matches the input tax bracket name and year
    for (Tax_Bracket__mdt taxBracket : taxBracketVals) {
      if (
        taxBrName != null &&
        currYr != null &&
        taxBracket.MasterLabel.equals(taxBrName) &&
        taxBracket.Year_Valid__c == currYr
      ) {
        // If a match is found, return the starting salary
        startingSal = (Decimal) taxBracket.Starting_Salary__c;
        return startingSal;
      }
    }

    // Return the starting salary (0.00 if no match was found)
    return startingSal;
  }

  /**
   * @description       : Retrieves the ending salary for a given tax bracket name and year.
   * @param taxBrName    : The name of the tax bracket.
   * @param currYr       : The current year for which the ending salary is applicable.
   * @return             : The ending salary for the tax bracket, or 0.00 if no matching record is found.
   */
  @AuraEnabled
  public static Decimal getEndingSalaryForTaxBracketName(
    String taxBrName,
    Integer currYr
  ) {
    Decimal endingSal = 0.00; // Default value in case no match is found

    // Retrieve all tax bracket values from the map
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();

    // Loop through each tax bracket and check if it matches the input tax bracket name and year
    for (Tax_Bracket__mdt taxBracket : taxBracketVals) {
      if (
        taxBrName != null &&
        currYr != null &&
        taxBracket.MasterLabel.equals(taxBrName) &&
        taxBracket.Year_Valid__c == currYr
      ) {
        // If a match is found, return the ending salary
        endingSal = (Decimal) taxBracket.Ending_Salary__c;
        return endingSal;
      }
    }

    // Return the ending salary (0.00 if no match was found)
    return endingSal;
  }

  /**
   * @description       : Retrieves the tax rate for a given tax bracket name and year.
   * @param taxBrName    : The name of the tax bracket.
   * @param currYr       : The current year for which the tax rate is applicable.
   * @return             : The tax rate for the tax bracket, or 0.00 if no matching record is found.
   */
  @AuraEnabled
  public static Decimal getTaxRateForTaxBracketName(
    String taxBrName,
    Integer currYr
  ) {
    Decimal taxRate = 0.00; // Default value in case no match is found

    // Retrieve all tax bracket values from the map
    List<Tax_Bracket__mdt> taxBracketVals = taxBracketMap.values();

    // Loop through each tax bracket and check if it matches the input tax bracket name and year
    for (Tax_Bracket__mdt taxBracket : taxBracketVals) {
      if (
        taxBrName != null &&
        currYr != null &&
        taxBracket.MasterLabel.equals(taxBrName) &&
        taxBracket.Year_Valid__c == currYr
      ) {
        // If a match is found, return the tax rate
        taxRate = Decimal.valueOf(taxBracket.Tax_Rate__c);
        return taxRate;
      }
    }

    // Return the tax rate (0.00 if no match was found)
    return taxRate;
  }
}
