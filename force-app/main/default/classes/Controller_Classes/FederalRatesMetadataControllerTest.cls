/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/
@isTest
public class FederalRatesMetadataControllerTest {
  @isTest
  static void testGetSocialSecurityRate() {
    // Start test context
    Test.startTest();

    // Positive case: Get the Social Security rate for a valid year (2024)
    Decimal ssRate2024 = FederalRatesMetadataController.getSocialSecurityRate(
      2024
    );
    Assert.areEqual(
      6.20,
      ssRate2024,
      'The Social Security rate for 2024 should be 6.2'
    );

    // Negative case: Get the Social Security rate for an invalid year (2023)
    Decimal ssRate2023 = FederalRatesMetadataController.getSocialSecurityRate(
      2023
    );
    Assert.areEqual(
      0.00,
      ssRate2023,
      'The Social Security rate for 2023 should return 0.00'
    );

    // Negative case: Passing a null year should return 0.00
    Decimal ssRateNull = FederalRatesMetadataController.getSocialSecurityRate(
      null
    );
    Assert.areEqual(
      0.00,
      ssRateNull,
      'The Social Security rate for null year should return 0.00'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetSocialSecurityMaxVal() {
    // Start test context
    Test.startTest();

    // Positive case: Get the Social Security max value for a valid year (2024)
    Decimal ssMaxVal2024 = FederalRatesMetadataController.getSocialSecurityMaxVal(
      2024
    );
    Assert.areEqual(
      168600.00,
      ssMaxVal2024,
      'The Social Security max value for 2024 should be 168600'
    );

    // Negative case: Get the Social Security max value for an invalid year (2023)
    Decimal ssMaxVal2023 = FederalRatesMetadataController.getSocialSecurityMaxVal(
      2023
    );
    Assert.areEqual(
      0.00,
      ssMaxVal2023,
      'SS max value for 2023 should return 0.00'
    );

    // Negative case: Passing a null year should return 0.00
    Decimal ssMaxValNull = FederalRatesMetadataController.getSocialSecurityMaxVal(
      null
    );
    Assert.areEqual(
      0.00,
      ssMaxValNull,
      'SS max value for null year should return 0.00'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetMedicareRate() {
    // Start test context
    Test.startTest();

    // Positive case: Get the Medicare rate for a valid year (2024)
    Decimal medicareRate2024 = FederalRatesMetadataController.getMedicareRate(
      2024
    );
    Assert.areEqual(
      1.45,
      medicareRate2024,
      'Medicare rate for 2024 should be 1.45'
    );

    // Negative case: Get the Medicare rate for an invalid year (2023)
    Decimal medicareRate2023 = FederalRatesMetadataController.getMedicareRate(
      2023
    );
    Assert.areEqual(
      0.00,
      medicareRate2023,
      'Medicare rate for 2023 should return 0.00'
    );

    // Negative case: Passing a null year should return 0.00
    Decimal medicareRateNull = FederalRatesMetadataController.getMedicareRate(
      null
    );
    Assert.areEqual(
      0.00,
      medicareRateNull,
      'Medicare rate for null year should return 0.00'
    );

    Test.stopTest();
  }
}
