/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/
@isTest
public class DeductionMetadataControllerTest {
  @isTest
  static void testGetStandardDeduction() {
    // Start test context
    Test.startTest();

    // Valid test case with correct year (2024)
    Integer currentYear = 2024;

    // Head of Household (HOH) for the current year
    Decimal hohDeduction = DeductionMetadataController.getStandardDeduction(
      'HOH',
      currentYear
    );
    Assert.areEqual(
      21900,
      hohDeduction,
      'HOH standard deduction for 2024 should be $21,900.'
    );

    // Married Filing Jointly (MFJ) for the current year
    Decimal mfjDeduction = DeductionMetadataController.getStandardDeduction(
      'MFJ',
      currentYear
    );
    Assert.areEqual(
      29200,
      mfjDeduction,
      'MFJ standard deduction for 2024 should be $29,200.'
    );

    // Married Filing Separately (MFS) for the current year
    Decimal mfsDeduction = DeductionMetadataController.getStandardDeduction(
      'MFS',
      currentYear
    );
    Assert.areEqual(
      14600,
      mfsDeduction,
      'MFS standard deduction for 2024 should be $14,600.'
    );

    // Test Blind (BL) status for Married Filing Jointly (MFJ)
    Decimal mfjBlindDeduction = DeductionMetadataController.getStandardDeduction(
      'MFJ_BL',
      currentYear
    );
    Assert.areEqual(
      30750,
      mfjBlindDeduction,
      'MFJ Blind deduction for 2024 should be $30,750.'
    );

    // Test Senior (SR) status for Married Filing Jointly (MFJ)
    Decimal mfjSeniorDeduction = DeductionMetadataController.getStandardDeduction(
      'MFJ_SR',
      currentYear
    );
    Assert.areEqual(
      30750,
      mfjSeniorDeduction,
      'MFJ Senior deduction for 2024 should be $30750.'
    );

    // Test Blind and Senior (BL_SR) status for Married Filing Jointly (MFJ)
    Decimal mfjBlindSeniorDeduction = DeductionMetadataController.getStandardDeduction(
      'MFJ_BL_SR',
      currentYear
    );
    Assert.areEqual(
      32300,
      mfjBlindSeniorDeduction,
      'MFJ Blind and Senior deduction for 2024 should be $32,300.'
    );

    // Invalid year test case
    Integer invalidYear = 2023;
    Decimal invalidYearDeduction = DeductionMetadataController.getStandardDeduction(
      'HOH',
      invalidYear
    );
    Assert.areEqual(
      0,
      invalidYearDeduction,
      'HOH standard deduction for an invalid year (2023) should return 0.'
    );

    // Invalid filing status (should return 0)
    Decimal invalidStatusDeduction = DeductionMetadataController.getStandardDeduction(
      'INVALID',
      currentYear
    );
    Assert.areEqual(
      0,
      invalidStatusDeduction,
      'Invalid filing status should return 0 for 2024.'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetDeductionAmount() {
    // Start test context
    Test.startTest();

    // Fetch the standard deduction metadata for a valid case (MFJ for Married Filing Jointly)
    Standard_Deduction__mdt mfjDeductionMetadata = [
      SELECT Amount__c
      FROM Standard_Deduction__mdt
      WHERE DeveloperName = 'MFJ'
      LIMIT 1
    ];
    Decimal mfjDeductionAmount = DeductionMetadataController.getDeductionAmount(
      mfjDeductionMetadata
    );
    Assert.areEqual(
      29200,
      mfjDeductionAmount,
      'MFJ deduction amount should be $29,200.'
    );

    // Fetch the standard deduction for MFJ with Blind status
    Standard_Deduction__mdt mfjBlindDeductionMetadata = [
      SELECT Amount__c
      FROM Standard_Deduction__mdt
      WHERE DeveloperName = 'MFS_MFJ_BL'
      LIMIT 1
    ];
    Decimal mfjBlindDeductionAmount = DeductionMetadataController.getDeductionAmount(
      mfjBlindDeductionMetadata
    );
    Assert.areEqual(
      1550,
      mfjBlindDeductionAmount,
      'MFJ Blind deduction amount should be $1,550.'
    );

    // Fetch the standard deduction for MFJ with Senior status
    Standard_Deduction__mdt mfjSeniorDeductionMetadata = [
      SELECT Amount__c
      FROM Standard_Deduction__mdt
      WHERE DeveloperName = 'MFS_MFJ_BL_SR'
      LIMIT 1
    ];
    Decimal mfjSeniorDeductionAmount = DeductionMetadataController.getDeductionAmount(
      mfjSeniorDeductionMetadata
    );
    Assert.areEqual(
      3100,
      mfjSeniorDeductionAmount,
      'MFJ Blind and Senior deduction amount should be $3,100.'
    );

    // Test HOH deduction
    Standard_Deduction__mdt hohDeductionMetadata = [
      SELECT Amount__c
      FROM Standard_Deduction__mdt
      WHERE DeveloperName = 'HOH'
      LIMIT 1
    ];
    Decimal hohDeductionAmount = DeductionMetadataController.getDeductionAmount(
      hohDeductionMetadata
    );
    Assert.areEqual(
      21900,
      hohDeductionAmount,
      'HOH deduction amount should be $21,900.'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetDeductionAmountForBLAndSR() {
    Test.startTest();

    // Fetch the standard deduction metadata for a valid case (MFJ with Blind and Senior status)
    Standard_Deduction__mdt mfjBlindSeniorDeductionMetadata = [
      SELECT Amount__c
      FROM Standard_Deduction__mdt
      WHERE DeveloperName = 'MFS_MFJ_BL_SR'
      LIMIT 1
    ];

    // Test getDeductionAmount with Blind and Senior status
    Decimal mfjBlindSeniorDeductionAmount = DeductionMetadataController.getDeductionAmount(
      mfjBlindSeniorDeductionMetadata
    );
    Assert.areEqual(
      3100,
      mfjBlindSeniorDeductionAmount,
      'MFJ deduction amount for Blind and Senior should be $3,100.'
    );

    // Test for Married Filing Jointly (MFJ) Blind only
    Standard_Deduction__mdt mfjBlindDeductionMetadata = [
      SELECT Amount__c
      FROM Standard_Deduction__mdt
      WHERE DeveloperName = 'MFS_MFJ_BL'
      LIMIT 1
    ];
    Decimal mfjBlindDeductionAmount = DeductionMetadataController.getDeductionAmount(
      mfjBlindDeductionMetadata
    );
    Assert.areEqual(
      1550,
      mfjBlindDeductionAmount,
      'MFJ deduction amount for Blind only should be $1,550.'
    );

    Test.stopTest();
  }
}
