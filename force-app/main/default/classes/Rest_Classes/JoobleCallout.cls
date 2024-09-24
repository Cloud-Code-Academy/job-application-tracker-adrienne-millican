/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/

public with sharing class JoobleCallout {
  public static final String OBJ_NAME = 'Position';
  public static final string CLS_NAME = 'JoobleCallout';

  @future(callout=true)
  public static void createNewPositionsFromJooble() {
    final String MTD_NAME = 'createNewPositionsFromJooble';
    List<Position__c> newPosnLst = new List<Position__c>();
    String apiKey = [
      SELECT MasterLabel, Value__c
      FROM Api_Key__mdt
      WHERE MasterLabel = 'Jooble'
      WITH USER_MODE
      LIMIT 1
    ]
    .Value__c;
    String keywordStr = '{ keywords: \'Salesforce\', location: \'United States\'}';
    // Create HTTP request to send.
    HttpRequest request = new HttpRequest();
    // Set the endpoint URL. Use direct URL or for best practices use Named Credential.
    request.setEndpoint('callout:Jooble' + '/' + apiKey);
    request.setHeader('Content-type', 'application/json');
    // Set the HTTP method to POST.
    request.setMethod('POST');
    request.setBody(keyWordStr);
    // Send the HTTP request and get the response.
    Http http = new Http();
    HttpResponse response = http.send(request);
    // If the HTTP response code is successful
    if (response.getStatusCode() == 200) {
      String jsonStr = response.getBody();
      jsonStr = removeExtraneous(jsonStr);
      Dump__c newDump = new Dump__c(Text__c = jsonStr);
      insert newDump;
      JSONParser parser = JSON.createParser(jsonStr);
      List<JPosition> jPosLst = parseJson(jsonStr, parser);
      newPosnLst = createPositions(jPosLst, newPosnLst);
      newPosnLst = removeUpdateExistingPositions(newPosnLst);
      newPosnLst = matchAcctsToCompanies(newPosnLst);
      List<Account> newAccts = createNewAcctsForCompanies(newPosnLst);
      newPosnLst = matchAcctsToCompanies(newPosnLst);
      System.debug(
        Util_Upsert.upsertList(
          OBJ_NAME,
          newPosnLst,
          MTD_NAME + ' of ' + CLS_NAME
        )
      );
    }
  }

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

  public static List<JPosition> parseJson(String jsonStr, JSONParser parser) {
    List<JPosition> jPosLst = new List<JPosition>();
    while (parser.nextToken() != null) {
      // Start at the array of jobs
      if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        while (parser.nextToken() != null) {
          // Advance to the job object
          if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
            System.debug('**About to read values');
            JPosition jooblePos = (JPosition) parser.readValueAs(
              JPosition.class
            );
            jPosLst.add(jooblePos);
          }
        }
      }
    }
    return jPosLst;
  }

  @testVisible
  private static List<Position__c> createPositions(
    List<JPosition> jPosnLst,
    List<Position__c> newPosnLst
  ) {
    for (JPosition jooblePos : jPosnLst) {
      Position__c posn = new Position__c();
      final String MTH_NAME = 'createPosition';
      try {
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
        newPosnLst.add(posn);
      } catch (Exception ex) {
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
        Util_ExceptionUtil.publishException(
          OBJ_NAME,
          MTH_NAME,
          CLS_NAME,
          null,
          insDetails
        );
      }
    }
    return newPosnLst;
  }

  private static List<Position__c> matchAcctsToCompanies(
    List<Position__c> posnLst
  ) {
    List<Account> acctsMatchingNames = queryForAcctsMatchingCompanyNames(
      posnLst
    );
    if (!acctsMatchingNames.isEmpty()) {
      for (Position__c postn : posnLst) {
        for (Account acct : acctsMatchingNames) {
          if (
            acct.Name.equals(postn.Company_Name__c) && postn.Company__c == null
          ) {
            postn.Company__c = acct.Id;
            break;
          }
        }
      }
    }
    return posnLst;
  }

  private static List<Account> queryForAcctsMatchingCompanyNames(
    List<Position__c> posnLst
  ) {
    List<Account> acctsMatchingNames = new List<Account>();
    String qry = 'SELECT Id, Name FROM Account WHERE Name IN (';
    Integer counter = 0;
    for (Position__c posn : posnLst) {
      if (posn.Company__c == null && !String.isBlank(posn.Company_Name__c)) {
        String companyName = posn.Company_Name__c;
        counter++;
        qry += '\'' + companyName + '\',';
      }
    }
    qry = qry.substring(0, qry.length() - 1);
    qry += ')';
    system.debug('**query: ' + qry);
    if (counter > 0) {
      acctsMatchingNames = Database.query(qry, AccessLevel.USER_MODE);
    }
    return acctsMatchingNames;
  }

  @testVisible
  private static List<Account> createNewAcctsForCompanies(
    List<Position__c> posnLst
  ) {
    final String MTD_NAME = 'createNewAcctsForCompanies';
    List<Account> newAccounts = new List<Account>();
    for (Position__c posn : posnLst) {
      if (posn.Company__c == null && posn.Company_Name__c != null) {
        Account newAcct = new Account(name = posn.Company_Name__c);
        System.debug('**New account: ' + newAcct.name);
        newAccounts.add(newAcct);
      }
    }
    System.debug(
      Util_Insert.insertList(
        'Account',
        newAccounts,
        MTD_NAME + ' of ' + CLS_NAME
      )
    );
    return newAccounts;
  }

  @testVisible
  private static List<Position__c> removeUpdateExistingPositions(
    List<Position__c> posnLst
  ) {
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
          Position_Description__c,
          External_System_Id__c
        FROM Position__c
      ]
    );

    for (Integer i = 0; i < posnLst.size(); i++) {
      for (Id posnId : existingPosnMap.keySet()) {
        Position__c mapPosn = existingPosnMap.get(posnId);
        if (
          mapPosn.External_System_Id__c != null &&
          posnLst[i].External_System_Id__c != null &&
          mapPosn
            ?.External_System_Id__c.equals(posnLst[i]?.External_System_Id__c)
        ) {
          if (
            mapPosn.Reported_Last_Updated__c ==
            posnLst[i].Reported_Last_Updated__c
          ) {
            posnLst.remove(i);
          } else {
            if (
              mapPosn.Reported_Last_Updated__c >
              posnLst[i].Reported_Last_Updated__c
            ) {
              posnLst[i].Id = mapPosn.Id;
            }
          }
        }
      }
    }
    return posnLst;
  }

  @testVisible
  private static String removeExtraneous(String input) {
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
