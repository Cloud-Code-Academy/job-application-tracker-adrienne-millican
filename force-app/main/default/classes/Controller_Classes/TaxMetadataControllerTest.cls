/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/
@isTest
public class TaxMetadataControllerTest {
  @isTest
  static void testGetTaxBracketName() {
    // Start test context
    Test.startTest();

    // Positive case: Valid filing status, income, and year
    String taxBracketName = TaxMetadataController.getTaxBracketName(
      'MFJ',
      50000,
      2024
    );
    Assert.areEqual(
      'MFJ 1',
      taxBracketName,
      'The tax bracket name should be MFJ 1'
    );

    // Negative case: Invalid year
    String invalidYearResult = TaxMetadataController.getTaxBracketName(
      'HOH',
      50000,
      2023
    );
    Assert.areEqual(
      '',
      invalidYearResult,
      'The tax bracket name should return empty for an invalid year.'
    );

    // Negative case: Null taxable income
    String nullIncomeResult = TaxMetadataController.getTaxBracketName(
      'Single',
      null,
      2024
    );
    Assert.areEqual(
      '',
      nullIncomeResult,
      'The tax bracket name should return empty for null income.'
    );

    // Negative case: Null filing status
    String nullFilingStatusResult = TaxMetadataController.getTaxBracketName(
      'Phony',
      50000,
      2024
    );
    Assert.areEqual(
      '',
      nullFilingStatusResult,
      'The tax bracket name should return empty for phony filing status.'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetStartingSalaryForTaxBracketName() {
    Test.startTest();

    // Positive case: Valid tax bracket name and year
    Decimal startingSalary = TaxMetadataController.getStartingSalaryForTaxBracketName(
      'SIN 3',
      2024
    );
    Assert.areEqual(
      100526,
      startingSalary,
      'The starting salary should be 100526 for SIN 3 for 2024.'
    );

    // Negative case: Invalid tax bracket name
    Decimal invalidBracketName = TaxMetadataController.getStartingSalaryForTaxBracketName(
      'SIN22',
      2024
    );
    Assert.areEqual(
      0.00,
      invalidBracketName,
      'The starting salary should return 0.00 for an invalid tax bracket name.'
    );

    // Negative case: Null tax bracket name
    Decimal nullBracketName = TaxMetadataController.getStartingSalaryForTaxBracketName(
      null,
      2024
    );
    Assert.areEqual(
      0.00,
      nullBracketName,
      'The starting salary should return 0.00 for null tax bracket name.'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetEndingSalaryForTaxBracketName() {
    Test.startTest();

    // Positive case: Valid tax bracket name and year
    Decimal endingSalary = TaxMetadataController.getEndingSalaryForTaxBracketName(
      'HOH 4',
      2024
    );
    Assert.areEqual(
      243700,
      endingSalary,
      'The ending salary should be 24370 for HOH 4 for 2024.'
    );

    // Negative case: Invalid tax bracket name
    Decimal invalidBracketEndingSalary = TaxMetadataController.getEndingSalaryForTaxBracketName(
      'Invalid Bracket',
      2024
    );
    Assert.areEqual(
      0.00,
      invalidBracketEndingSalary,
      'The ending salary should return 0.00 for an invalid tax bracket name.'
    );

    // Negative case: Null tax bracket name
    Decimal nullBracketEndingSalary = TaxMetadataController.getEndingSalaryForTaxBracketName(
      null,
      2024
    );
    Assert.areEqual(
      0.00,
      nullBracketEndingSalary,
      'The ending salary should return 0.00 for null tax bracket name.'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetTaxRateForTaxBracketName() {
    Test.startTest();

    // Positive case: Valid tax bracket name and year
    Decimal taxRate = TaxMetadataController.getTaxRateForTaxBracketName(
      'HOH 4',
      2024
    );
    Assert.areEqual(32.00, taxRate, 'The tax rate should be 32.00 for HOH 4.');

    // Negative case: Invalid tax bracket name
    Decimal invalidBracketTaxRate = TaxMetadataController.getTaxRateForTaxBracketName(
      'Invalid Bracket',
      2024
    );
    Assert.areEqual(
      0.00,
      invalidBracketTaxRate,
      'The tax rate should return 0.00 for an invalid tax bracket name.'
    );

    // Negative case: Null tax bracket name
    Decimal nullBracketTaxRate = TaxMetadataController.getTaxRateForTaxBracketName(
      null,
      2024
    );
    Assert.areEqual(
      0.00,
      nullBracketTaxRate,
      'The tax rate should return 0.00 for null tax bracket name.'
    );

    Test.stopTest();
  }
}
