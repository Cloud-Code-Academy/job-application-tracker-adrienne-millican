/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-17-2024
 * @last modified by  : admillican08@gmail.com
 **/
@IsTest
public class TaxMetadataControllerTest {
  // Test method to cover the getTaxRatePercentage method for Single Filing
  @IsTest
  public static void testGetTaxRatePercentageSingle() {
    // Test for single filer with salary within the first bracket
    Decimal taxRate = TaxMetadataController.getTaxRatePercentage('S', 45000.00);
    Assert.equals(12.00, taxRate, 'The tax rate should be 12 for this salary.');

    // Test for single filer with salary within the second bracket
    taxRate = TaxMetadataController.getTaxRatePercentage('S', 175000.00);
    Assert.equals(24.00, taxRate, 'The tax rate should be 24 for this salary.');
  }

  // Test method to cover the getTaxRatePercentage method for Married Filing
  @IsTest
  public static void testGetTaxRatePercentageMFJ() {
    // Test for married filer with salary within the first bracket
    Decimal taxRate = TaxMetadataController.getTaxRatePercentage(
      'MFJ',
      60000.00
    );
    Assert.equals(
      15.00,
      taxRate,
      'The tax rate should be 15% for this salary.'
    );

    // Test for married filer with salary within the second bracket
    taxRate = TaxMetadataController.getTaxRatePercentage('MFJ', 120000.00);
    Assert.equals(
      25.00,
      taxRate,
      'The tax rate should be 25% for this salary.'
    );
  }

  // Test method to handle the scenario where no matching tax bracket is found
  @IsTest
  public static void testGetTaxRatePercentageNoMatch() {
    // Test with a salary that does not match any tax bracket
    Decimal taxRate = TaxMetadataController.getTaxRatePercentage(
      'Single_Filing',
      200000.00
    );
    Assert.equals(
      0.00,
      taxRate,
      'The tax rate should be 0% for a salary with no match.'
    );

    // Test with a filing status that does not exist
    taxRate = TaxMetadataController.getTaxRatePercentage(
      'Head_of_Household',
      50000.00
    );
    Assert.equals(
      0.00,
      taxRate,
      'The tax rate should be 0% for a non-existent filing status.'
    );
  }

  // Test method to cover the getter for taxBracketMap
  @IsTest
  public static void testTaxBracketMapGetter() {
    // Access the map directly to ensure it is being initialized correctly
    Map<String, Tax_Bracket__mdt> bracketMap = TaxMetadataController.taxBracketMap;
    Assert.notEquals(null, bracketMap, 'The taxBracketMap should not be null.');
    Assert.equals(
      4,
      bracketMap.size(),
      'The taxBracketMap should have 4 entries.'
    );
  }
}
