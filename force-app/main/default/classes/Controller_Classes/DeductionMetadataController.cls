/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-21-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class DeductionMetadataController {
  public static final String BL = '_BL';
  public static final String SR = '_SR';
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
    List<Standard_Deduction__mdt> deductionVals = deductionMap.values();
    Decimal deductAmt = 0.00;
    Decimal extraAmt = 0.00;
    for (Standard_Deduction__mdt deduction : deductionVals) {
      if (
        filingStatusVal != null &&
        currYr != null &&
        deduction.Year_Valid__c == currYr
      ) {
        System.debug('**Current filing status val: ' + filingStatusVal);
        System.debug('**Current Deduction: ' + deduction.DeveloperName);

        List<String> filingStatusValLst = filingStatusVal.split('_');
        String devName = deduction.DeveloperName;
        System.debug('**devname: ' + devName);
        String filingVal = filingStatusval.substring(0, 3);
        for (String str : filingStatusValLst) {
          if (filingStatusValLst.size() == 1) {
            if (filingStatusValLst[0].equals(devName)) {
              System.debug('**Matched base deduction value');
              deductAmt = getDeductionAmount(deduction);
              break;
            }
          } else if (filingStatusValLst.size() == 2) {
            if (filingStatusValLst[0].equals(devName)) {
              deductAmt = getDeductionAmount(deduction);
            } else if (
              devName.contains(filingStatusValLst[1]) &&
              devName.contains(filingStatusValLst[0]) &&
              !(devName.contains(BL) && devName.contains(SR))
            ) {
              System.debug('**Matched BL or SR value');
              extraAmt = getDeductionAmount(deduction);
            }
          } else if (filingStatusValLst.size() == 3) {
            if (filingStatusValLst[0].equals(devName)) {
              deductAmt = getDeductionAmount(deduction);
            } else if (
              devName.contains(BL) &&
              devName.contains(SR) &&
              devName.contains(filingStatusValLst[0])
            ) {
              System.debug('**Matched BL AND SR value');
              extraAmt = getDeductionAmount(deduction);
            }
          }
        }
      }
    }
    System.debug(
      '**DeductionMetadataController returning ' + (deductAmt + extraAmt)
    );
    return (deductAmt + extraAmt);
  }

  @testVisible
  private static Decimal getDeductionAmount(Standard_Deduction__mdt deduction) {
    Decimal deductAmt = (Decimal) deduction.Amount__c;
    return deductAmt;
  }
}