/**
 * @description       : Controller that handles the retrieval of standard deduction values from custom metadata (`Standard_Deduction__mdt`).
 *                      Provides methods to fetch deduction amounts based on filing status, year, and special conditions like blindness and senior status.
 * @author            : admillican08@gmail.com
 * @last modified on  : 09-24-2024
 **/
public with sharing class DeductionMetadataController {
  // Constant for Blind status suffix
  public static final String BL = '_BL';

  // Constant for Senior status suffix
  public static final String SR = '_SR';

  // A map to store standard deduction metadata records for quick access
  public static Map<String, Standard_Deduction__mdt> deductionMap {
    get {
      // Lazy initialization: Only populate the map if it is not already initialized
      if (deductionMap == null) {
        deductionMap = new Map<String, Standard_Deduction__mdt>();

        // Retrieve all deduction records from custom metadata and store them in the map
        deductionMap = Standard_Deduction__mdt.getAll();
      }
      return deductionMap;
    }
    set;
  }

  /**
   * @description       : Retrieves the standard deduction amount based on filing status and year, including extra deductions for special conditions like blindness and senior status.
   * @param filingStatusVal : The filing status (e.g., MFJ, HOH, etc.) for which the deduction is to be retrieved.
   * @param currYr       : The year for which the deduction is applicable.
   * @return             : The total standard deduction amount, including any extra deductions, for the given filing status and year.
   */
  @AuraEnabled(cacheable=true)
  public static Decimal getStandardDeduction(
    String filingStatusVal,
    Integer currYr
  ) {
    // Get all standard deduction metadata values from the map
    List<Standard_Deduction__mdt> deductionVals = deductionMap.values();
    Decimal deductAmt = 0.00; // Initialize the base deduction amount
    Decimal extraAmt = 0.00; // Initialize the extra deduction amount for special conditions

    // Iterate through all standard deduction records
    for (Standard_Deduction__mdt deduction : deductionVals) {
      // Check if the filing status and year match
      if (
        filingStatusVal != null &&
        currYr != null &&
        deduction.Year_Valid__c == currYr
      ) {
        // Split the filing status (e.g., MFJ_BL for Married Filing Jointly + Blind)
        List<String> filingStatusValLst = filingStatusVal.split('_');
        String devName = deduction.DeveloperName; // DeveloperName from metadata
        String filingVal = filingStatusval.substring(0, 3); // Extract base filing status (first 3 letters)

        // Loop through the filing status parts and check for matches
        for (String str : filingStatusValLst) {
          // Case: No special conditions (just the filing status)
          if (filingStatusValLst.size() == 1) {
            if (filingStatusValLst[0].equals(devName)) {
              deductAmt = getDeductionAmount(deduction); // Get base deduction
              break;
            }
          }
          // Case: One special condition (either blind or senior)
          else if (filingStatusValLst.size() == 2) {
            if (filingStatusValLst[0].equals(devName)) {
              deductAmt = getDeductionAmount(deduction); // Get base deduction
            } else if (
              devName.contains(filingStatusValLst[1]) &&
              devName.contains(filingStatusValLst[0]) &&
              !(devName.contains(BL) && devName.contains(SR))
            ) {
              extraAmt = getDeductionAmount(deduction); // Get extra deduction for the condition
            }
          }
          // Case: Both Blind and Senior conditions (BL + SR)
          else if (filingStatusValLst.size() == 3) {
            if (filingStatusValLst[0].equals(devName)) {
              deductAmt = getDeductionAmount(deduction); // Get base deduction
            } else if (
              devName.contains(BL) &&
              devName.contains(SR) &&
              devName.contains(filingStatusValLst[0])
            ) {
              extraAmt = getDeductionAmount(deduction); // Get extra deduction for both conditions
            }
          }
        }
      }
    }
    // Return the total deduction amount (base deduction + any extra deductions)
    return (deductAmt + extraAmt);
  }

  /**
   * @description       : Retrieves the deduction amount from the given standard deduction metadata record.
   * @param deduction   : The standard deduction metadata record from which the deduction amount is retrieved.
   * @return            : The deduction amount from the metadata record.
   */
  @testVisible
  private static Decimal getDeductionAmount(Standard_Deduction__mdt deduction) {
    // Get and return the deduction amount from the metadata record
    Decimal deductAmt = (Decimal) deduction.Amount__c;
    return deductAmt;
  }
}