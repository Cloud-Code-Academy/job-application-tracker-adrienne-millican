/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-25-2024
 * @last modified by  : admillican08@gmail.com
 **/
@isTest
public class JoobleCalloutTest {
  // Use @testSetup to create reusable test data for all test methods
  @testSetup
  static void makeData() {
    // Create test accounts using the Util_TestDataFactory class
    List<Account> testAccounts = Util_TestDataFactory.createTestAccounts(
      5,
      true
    );

    Util_TestDataFactory.createSingleTestContact(
      testAccounts[0].Id,
      'John',
      'Doe',
      true
    );
  }

  // Mock HTTP Callout for Jooble API - Success Response
  private class MockJoobleHttpResponseSuccess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(200); // Simulate a successful response
      res.setBody(
        '{"jobs":[{"title":"Salesforce Developer","location":"San Francisco, CA","salary":"150000","company":"Stark Industries","updated":"2024-09-15T12:00:00Z","id":"123456789"}]}'
      );
      return res;
    }
  }

  // Mock HTTP Callout for Jooble API - Error Response (500 Internal Server Error)
  private class MockHttpResponseError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(500); // Simulate an error response
      res.setBody('{"error": "Internal Server Error"}');
      return res;
    }
  }

  // Test for successful position creation from Jooble API
  @isTest
  static void testCreateNewPositionsFromJooble_Success() {
    // Set the mock for successful HTTP callout
    Test.setMock(HttpCalloutMock.class, new MockJoobleHttpResponseSuccess());

    // Call the future method
    Test.startTest();
    JoobleCallout.createNewPositionsFromJooble();
    Test.stopTest();

    // Verify positions were created
    List<Position__c> newPositions = [
      SELECT Id, Title__c, Company_Name__c
      FROM Position__c
    ];
    Assert.areEqual(
      1,
      newPositions.size(),
      'Number of positions from JSON not as expected'
    );
    Assert.areEqual(
      'Salesforce Developer',
      newPositions[0].Title__c,
      'Position title from JSON not as expected.'
    );
  }

  // Test for error handling in case of a failed API call
  @isTest
  static void testCreateNewPositionsFromJooble_ErrorHandling() {
    // Set the mock for an error HTTP callout
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());

    // Call the future method
    Test.startTest();
    JoobleCallout.createNewPositionsFromJooble();
    Test.stopTest();

    // Verify that no positions were created due to the error
    List<Position__c> newPositions = [SELECT Id FROM Position__c];
    Assert.areEqual(0, newPositions.size(), 'Failure response not as expected');
  }

  // Test for the parseJson method
  @isTest
  static void testParseJson() {
    // Mock JSON response string
    String mockJson = '{"jobs":[{"title":"Salesforce Developer","location":"San Francisco, CA","salary":"150000","company":"Stark Industries","updated":"2024-09-15T12:00:00Z","id":"123456789"}]}';
    // Parse the JSON string using JoobleCallout's parseJson method
    JSONParser parser = JSON.createParser(mockJson);
    List<JoobleCallout.JPosition> parsedPositions = JoobleCallout.parseJson(
      mockJson,
      parser
    );

    // Verify the parsing logic
    Assert.areEqual(
      1,
      parsedPositions.size(),
      'Position from parsing not as expected'
    );
    Assert.areEqual(
      'Salesforce Developer',
      parsedPositions[0].title,
      'Parsed position title not as expected'
    );
  }

  // Test for createPositions method (with valid data)
  @isTest
  static void testCreatePositions() {
    // Create mock JPosition list
    List<JoobleCallout.JPosition> jPositionList = new List<JoobleCallout.JPosition>();
    JoobleCallout.JPosition mockPosition = new JoobleCallout.JPosition();
    mockPosition.title = 'Salesforce Instructor';
    mockPosition.location = 'Los Angeles';
    mockPosition.company = 'Cloud Code Academy';
    mockPosition.id = Util_TestDataFactory.generateRandomNumberString(9);
    jPositionList.add(mockPosition);

    // Call createPositions and verify
    List<Position__c> newPositions = new List<Position__c>();
    newPositions = JoobleCallout.createPositions(jPositionList, newPositions);

    Assert.areEqual(
      1,
      newPositions.size(),
      'Number of created sObject positions not as expected.'
    );
    Assert.areEqual(
      'Salesforce Instructor',
      newPositions[0].Title__c,
      'Created sObject position title not as expected'
    );
  }

  // Test for createNewAcctsForCompanies method
  @isTest
  static void testCreateNewAcctsForCompanies() {
    // Create mock Position__c list
    List<Position__c> posnList = new List<Position__c>();
    Position__c mockPosition = new Position__c();
    mockPosition.Company_Name__c = 'United Containers';
    posnList.add(mockPosition);

    // Call createNewAcctsForCompanies and verify the result
    List<Account> newAccounts = JoobleCallout.createNewAcctsForCompanies(
      posnList
    );
    Assert.areEqual(
      1,
      newAccounts.size(),
      'Number of new accoutns created not as expected'
    );
    Assert.areEqual(
      'United Containers',
      newAccounts[0].Name,
      'Company name from account not as expected'
    );
  }

  // Test for removeExtraneous method
  @isTest
  static void testRemoveExtraneous() {
    String inputString = '{"jobs": [{"title":"Salesforce~ Developer", "location":"New York", "salary":"", "id":-"54321"}]}';
    String cleanedString = JoobleCallout.removeExtraneous(inputString);

    // Verify the cleaning logic
    Assert.areEqual(
      '{"jobs": [{"title":"Salesforce Developer", "location":"New York", "salary":"0.00", "id":"54321"}]}',
      cleanedString,
      'String not cleaned as expected'
    );
  }

  @isTest
  static void testRemoveUpdateExistingPositions_UpdateLogic() {
    // Create a mock existing position in the database with External_System_Id__c and Reported_Last_Updated__c
    Position__c existingPosn = new Position__c(
      External_System_Id__c = '987654321',
      Reported_Last_Updated__c = DateTime.newInstance(2024, 9, 15, 12, 0, 0),
      Title__c = 'Important Position',
      Position_Status__c = 'Open',
      Salary__c = 140000,
      Company_Name__c = 'Big Company'
    );
    System.debug('**Inserting existing position');
    insert existingPosn;

    // Create a list of new positions that include one with a matching External_System_Id__c
    List<Position__c> posnLst = new List<Position__c>();
    Position__c newPosn = new Position__c(
      External_System_Id__c = '987654321', //matching ID
      Reported_Last_Updated__c = DateTime.newInstance(2024, 9, 14, 12, 0, 0), //older date
      Position_Status__c = 'Open',
      Salary__c = 140000,
      Title__c = 'Important Position',
      Company_Name__c = 'Big Company'
    );
    posnLst.add(newPosn);

    // Call the method to remove/update positions
    Test.startTest();
    List<Position__c> updatedPosnLst = JoobleCallout.removeUpdateExistingPositions(
      posnLst
    );

    // Assertions to verify the behavior
    Assert.areEqual(
      1,
      updatedPosnLst.size(),
      'Size of updated position not as expected.'
    );
    Assert.areEqual(
      existingPosn.Id,
      updatedPosnLst[0].Id,
      'Existing and updated position ids not equal as expected'
    );

    // Create another position with the same External_System_Id__c but with the same last updated date
    Position__c newPosnSameDate = new Position__c(
      External_System_Id__c = '987654321',
      Reported_Last_Updated__c = DateTime.newInstance(2024, 9, 15, 12, 0, 0), // Same date and time
      Title__c = 'Important Position',
      Company_Name__c = 'Big Company'
    );
    posnLst = new List<Position__c>{ newPosnSameDate };

    // Call the method again
    updatedPosnLst = JoobleCallout.removeUpdateExistingPositions(posnLst);
    Test.stopTest();

    // Verify that the position was removed because the Reported_Last_Updated__c date was the same
    Assert.areEqual(
      0,
      updatedPosnLst.size(),
      'The position should be removed because the last updated dates are the same.'
    );
  }
}
