/**
 * @description       : This class handles the integration with the Jooble API.
 *                      It fetches job positions from Jooble, processes the response, and inserts positions into Salesforce.
 * @author            : admillican08@gmail.com
 * @last modified on  : 10-03-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JoobleCallout {
  // Constants for object name and class name used in logging or exception handling
  public static final String OBJ_NAME = 'Position';
  public static final string CLS_NAME = 'JoobleCallout';

  /**
   * @description       : This future method sends a callout to the Jooble API to fetch new positions
   *                      and insert/update positions in Salesforce.
   * @future(callout=true)
   */
  @future(callout=true)
  public static void createNewPositionsFromJooble() {
    final String MTD_NAME = 'createNewPositionsFromJooble'; // Method name used for logging or exceptions
    List<Position__c> newPosnLst = new List<Position__c>(); // List to hold new positions from the API

    // Fetch API Key from custom metadata for Jooble integration
    String apiKey = [
      SELECT MasterLabel, Value__c
      FROM Api_Key__mdt
      WHERE MasterLabel = 'Jooble'
      WITH USER_MODE
      LIMIT 1
    ]
    .Value__c;

    // Prepare the keyword string for the API request body
    String keywordStr = '{ keywords: \'Salesforce\', location: \'United States\'}';

    // Create and configure the HTTP request for the API call
    HttpRequest request = new HttpRequest();
    request.setEndpoint('callout:Jooble' + '/' + apiKey); // Use Named Credential for the endpoint
    request.setHeader('Content-type', 'application/json'); // Set request header to JSON
    request.setMethod('POST'); // Set HTTP method to POST
    request.setBody(keywordStr); // Set the body with keywords and location

    // Send the HTTP request and get the response
    Http http = new Http();
    HttpResponse response = http.send(request);

    // Check if the response is successful (HTTP 200)
    if (response.getStatusCode() == 200) {
      String jsonStr = response.getBody(); // Get the response body
      jsonStr = removeExtraneous(jsonStr); // Clean up any extraneous characters from the response

      // Parse the JSON response to extract job positions
      JSONParser parser = JSON.createParser(jsonStr);
      List<JPosition> jPosLst = parseJson(jsonStr, parser); // Parse the response into a list of JPosition objects

      // Convert parsed positions into Salesforce Position__c objects
      newPosnLst = createPositions(jPosLst, newPosnLst);

      // Remove or update existing positions with the same External_System_Id__c
      newPosnLst = removeUpdateExistingPositions(newPosnLst);

      // Match positions to companies in the system
      newPosnLst = matchAcctsToCompanies(newPosnLst);

      // Create new accounts for any companies that don’t already exist
      List<Account> newAccts = createNewAcctsForCompanies(newPosnLst);

      // Re-match positions to the new accounts created
      newPosnLst = matchAcctsToCompanies(newPosnLst);

      // Upsert the final list of positions into Salesforce
      System.debug(
        Util_Upsert.upsertList(
          OBJ_NAME,
          newPosnLst,
          MTD_NAME + ' of ' + CLS_NAME
        )
      );
    }
  }

  /**
   * @description       : A class representing a Jooble job position as returned from the API.
   */
  public class JPosition {
    public String title;
    public String location;
    public String snippet;
    public Decimal salary;
    public String source;
    public String type;
    public String link;
    public String company;
    public DateTime updated;
    public String id;
  }

  /**
   * @description       : Parses the JSON response from Jooble and converts it into a list of JPosition objects.
   * @param jsonStr     : The raw JSON string response from the API.
   * @param parser      : JSONParser instance to parse the response.
   * @return            : A list of JPosition objects representing the job positions in the response.
   */
  public static List<JPosition> parseJson(String jsonStr, JSONParser parser) {
    List<JPosition> jPosLst = new List<JPosition>(); // Initialize an empty list of JPosition

    // Traverse the JSON response and extract job position details
    while (parser.nextToken() != null) {
      // Check for the start of the array of jobs
      if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        while (parser.nextToken() != null) {
          // Check for the start of a job object
          if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
            // Read each job object and add it to the list
            JPosition jooblePos = (JPosition) parser.readValueAs(
              JPosition.class
            );
            jPosLst.add(jooblePos);
          }
        }
      }
    }
    return jPosLst; // Return the list of parsed positions
  }

  /**
   * @description       : Converts a list of JPosition objects into Salesforce Position__c objects.
   * @param jPosnLst    : List of JPosition objects parsed from the API response.
   * @param newPosnLst  : List to hold new Salesforce Position__c objects.
   * @return            : List of Position__c objects ready to be upserted into Salesforce.
   */
  @testVisible
  private static List<Position__c> createPositions(
    List<JPosition> jPosnLst,
    List<Position__c> newPosnLst
  ) {
    for (JPosition jooblePos : jPosnLst) {
      Position__c posn = new Position__c(); // Create a new Position__c record
      final String MTH_NAME = 'createPosition'; // Method name for logging or exceptions

      try {
        // Map the JPosition fields to the Position__c fields
        posn.Title__c = jooblePos?.title ?? 'No Title Provided';
        posn.Geographic_Job_Location__c = jooblePos?.location ??
          'United States';
        posn.Position_Description__c = jooblePos?.snippet ??
          'No Description Provided';
        posn.Salary__c = jooblePos?.salary;
        posn.Source__c = jooblePos?.source;
        posn.Time_Type__c = jooblePos?.type;
        posn.Position_Link__c = jooblePos?.link;
        posn.Company_Name__c = jooblePos?.company;
        posn.Reported_Last_Updated__c = jooblePos?.updated;
        posn.External_System_Id__c = jooblePos?.id;
        posn.Position_Status__c = 'Open';
        posn.Created_by_Jooble__c = true;

        newPosnLst.add(posn); // Add the new position to the list
      } catch (Exception ex) {
        // Handle any exceptions that occur during the mapping process
        String insDetails =
          'Method: ' +
          MTH_NAME +
          ', ' +
          CLS_NAME +
          '; Cause: ' +
          ex.getCause() +
          '; Line Number: ' +
          ex.getLineNumber() +
          '; MessageStr: ' +
          ex.getMessage() +
          '; Stack Trace: ' +
          ex.getStackTraceString() +
          '; Type Name: ' +
          ex.getTypeName();

        // Publish the exception using a utility method
        Util_ExceptionUtil.publishException(
          OBJ_NAME,
          MTH_NAME,
          CLS_NAME,
          null,
          insDetails
        );
      }
    }
    return newPosnLst; // Return the list of Position__c records
  }

  /**
   * @description       : Matches the job positions to existing accounts in Salesforce based on the company name.
   * @param posnLst     : List of Position__c objects to be matched.
   * @return            : List of Position__c objects with matched account references.
   */
  @testVisible
  private static List<Position__c> matchAcctsToCompanies(
    List<Position__c> posnLst
  ) {
    // Query for existing accounts with matching company names

    List<Account> acctsMatchingNames = queryForAcctsMatchingCompanyNames(
      posnLst
    );

    // If matching accounts are found, assign them to the corresponding positions
    if (!acctsMatchingNames.isEmpty()) {
      for (Position__c postn : posnLst) {
        for (Account acct : acctsMatchingNames) {
          if (
            acct.Name.equals(postn.Company_Name__c) && postn.Company__c == null
          ) {
            postn.Company__c = acct.Id; // Assign the account to the position
            break;
          }
        }
      }
    }

    return posnLst; // Return the updated list of positions
  }

  /**
   * @description       : Queries Salesforce for Accounts that match the company names from the list of job positions.
   *                      This method constructs a dynamic SOQL query based on company names in the Position__c records
   *                      and returns a list of matching Account records.
   * @param posnLst     : List of Position__c objects containing the company names to match against existing Accounts.
   * @return            : A list of Account objects that match the company names in the Position__c records.
   */
  @testVisible
  private static List<Account> queryForAcctsMatchingCompanyNames(
    List<Position__c> posnLst
  ) {
    List<Account> acctsMatchingNames = new List<Account>(); // Initialize the list to store matching accounts
    String qry = 'SELECT Id, Name FROM Account WHERE Name IN ('; // Start constructing the SOQL query
    Integer counter = 0; // Counter to track the number of positions to include in the query

    // Loop through the Position__c records and build the query if the company name is provided and not already associated with an account
    Set<String> companyNamesSet = new Set<String>();
    for (Position__c posn : posnLst) {
      if (posn.Company__c == null && !String.isBlank(posn.Company_Name__c)) {
        companyNamesSet.add(posn.Company_Name__c.trim()); // Extract the company name
      }
    }
    List<String> companyNamesLst = new List<String>(companyNamesSet);
    for (String companyName : companyNamesLst) {
      // increment counter;
      counter++;
      qry += '\'' + companyName + '\',';
    }

    // If there were any companies to query, remove the trailing comma and close the query string
    if (counter > 0) {
      qry = qry.substring(0, qry.length() - 1) + ')';
      system.debug('**query: ' + qry); // Log the generated query
      acctsMatchingNames = Database.query(qry); // Execute the query
    }

    return acctsMatchingNames; // Return the list of matching accounts
  }

  /**
   * @description       : Creates new Account records for companies that don't already have associated accounts in Salesforce.
   *                      This method checks for Position__c records with company names but without linked accounts and creates new Account records.
   * @param posnLst     : List of Position__c objects containing the companies that may need new Account records.
   * @return            : A list of newly created Account objects.
   */
  @testVisible
  private static List<Account> createNewAcctsForCompanies(
    List<Position__c> posnLst
  ) {
    final String MTD_NAME = 'createNewAcctsForCompanies'; // Method name for logging or exceptions
    List<Account> newAccounts = new List<Account>(); // List to store new accounts

    // Loop through the Position__c records and create Account records for companies without existing accounts
    for (Position__c posn : posnLst) {
      if (posn.Company__c == null && posn.Company_Name__c != null) {
        Account newAcct = new Account(Name = posn.Company_Name__c); // Create a new Account using the company name
        newAccounts.add(newAcct); // Add the new Account to the list
      }
    }

    // Insert the new accounts into Salesforce and log the results
    System.debug(
      Util_Insert.insertList(
        'Account',
        newAccounts,
        MTD_NAME + ' of ' + CLS_NAME
      )
    );

    return newAccounts; // Return the list of newly created Account objects
  }

/**
   * @description       : Removes or updates existing Position__c records if they match with new positions based on the External_System_Id__c.
   *                      If the existing position's last updated date is more recent, it updates the record. Otherwise, it removes the new position.
   * @param posnLst     : List of Position__c objects to be checked for duplicates or updates against existing positions.
   * @return            : Updated list of Position__c objects after removing duplicates or updating existing records.
   */
  @testVisible
  private static List<Position__c> removeUpdateExistingPositions(
    List<Position__c> posnLst
  ) {
    // Query the existing Position__c records from Salesforce that are currently open
    Map<Id, Position__c> existingPosnMap = new Map<Id, Position__c>(
      [
        SELECT
          Id,
          Title__c,
          Reported_Last_Updated__c,
          Company_Name__c,
          Geographic_Job_Location__c,
          Position_Link__c,
          Salary__c,
          Source__c,
          Time_Type__c,
          Position_Status__c,
          Position_Description__c,
          External_System_Id__c
        FROM Position__c
        WHERE Position_Status__c = 'Open'
        WITH USER_MODE
        ORDER BY Reported_Last_Updated__c DESC
        LIMIT 1000
      ]
    );

    // Loop through the list of new positions and compare them with the existing positions in Salesforce
    for (Integer i = 0; i < posnLst.size(); i++) {
      for (Id posnId : existingPosnMap.keySet()) {
        Position__c mapPosn = existingPosnMap.get(posnId); // Get the existing position record
        // Check if the External_System_Id__c matches between the new and existing position
        if (
          mapPosn.External_System_Id__c != null &&
          posnLst[i].External_System_Id__c != null &&
          mapPosn.External_System_Id__c.equals(posnLst[i].External_System_Id__c)
        ) {
          // If the Reported_Last_Updated__c is the same, remove the new position
          if (
            mapPosn.Reported_Last_Updated__c ==
            posnLst[i].Reported_Last_Updated__c
          ) {
            posnLst.remove(i); // Remove the duplicate position
          } else {
            // If the existing position is more recent, update the new position with the existing record's ID
            if (
              mapPosn.Reported_Last_Updated__c >
              posnLst[i].Reported_Last_Updated__c
            ) {
              posnLst[i].Id = mapPosn.Id; // Update the new position's ID to match the existing one
            }
          }
        }
      }
    }

    return posnLst; // Return the updated list of positions
  }

  @testVisible
  //private helper method to clean up the messy input data and to make parsing the JSON possible
  private static String removeExtraneous(String input) {
    input = input.replaceAll('\'', '');
    input = input.replaceAll('\\\\[a-z]', '');
    input = input.replaceAll('~', '');
    input = input.replaceAll('&nbsp;', '');
    input = input.replaceAll('\\?\\?', '');
    input = input.replaceAll('</*[a-z]>', '');
    input = input.replaceAll('\\.0{7}', '');
    input = input.replaceAll('"id":-', '"id":');
    input = input.replaceAll('"salary":""', '"salary":"0.00"');
    input = input.replaceAll(
      '^\\{"totalCount":[0-9]+,"jobs":\\[',
      '\\{"jobs":['
    );
    return input;
  }
}