/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-23-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JoobleCallout {
  public static final String OBJ_NAME = 'Position';
  public static final string CLS_NAME = 'JoobleCallout';

  @future(callout=true)
  public static void createNewPositionsFromJooble() {
    final String MTD_NAME = 'createNewPositionsFromJooble';
    String apiKey = [
      SELECT MasterLabel, Value__c
      FROM Api_Key__mdt
      WHERE MasterLabel = 'Jooble'
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
      List<Position__c> newPosnLst = new List<Position__c>();
      parser.nextToken();
      parser.nextToken();
      while (parser.nextToken() != null) {
        Position__c newPosn = new Position__c();
        newPosn = createPosition(parser, newPosn);
        newPosnLst.add(newPosn);
      }
      newPosnLst = removeUpdateExistingPositions(newPosnLst);
      newPosnLst = matchAcctsToCompanies(newPosnLst);
      List<Account> newAccts = createNewAcctsForCompanies(newPosnLst);
      Util_Insert.insertList(OBJ_NAME, newAccts, MTD_NAME + ' of ' + CLS_NAME);
      newPosnLst = matchAcctsToCompanies(newPosnLst);
      System.debug('**Size of Position List is ' + newPosnLst.size());
      System.debug(
        Util_Upsert.upsertList(
          OBJ_NAME,
          newPosnLst,
          MTD_NAME + ' of ' + CLS_NAME
        )
      );
    }
  }

  @testVisible
  private static Position__c createPosition(
    JsonParser parser,
    Position__c posn
  ) {
    final String MTH_NAME = 'createPosition';
    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
      try {
        switch on parser.getText() {
          when 'title' {
            parser.nextValue();
            posn.Title__c = parser.getText();
          }
          when 'location' {
            parser.nextValue();
            posn.Geographic_Job_Location__c = parser.getText();
          }
          when 'snippet' {
            parser.nextValue();
            posn.Position_Description__c = parser.getText();
          }
          when 'salary' {
            parser.nextValue();
            try {
              posn.Salary__c = Decimal.valueOf(parser.getText());
            } catch (TypeException te) {
              posn.Salary__c = null;
            }
          }
          when 'source' {
            parser.nextValue();
            posn.Source__c = parser.getText();
          }
          when 'type' {
            parser.nextValue();
            posn.Time_Type__c = parser.getText();
          }
          when 'link' {
            parser.nextValue();
            posn.Position_Link__c = parser.getText();
          }
          when 'company' {
            parser.nextValue();
            posn.Company_Name__c = parser.getText();
          }
          when 'updated' {
            parser.nextValue();
            posn.Reported_Last_Updated__c = parser.getDateTimeValue();
          }
          when 'id' {
            parser.nextValue();
            posn.External_System_Id__c = parser.getText();
          }
        }
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
    return posn;
  }
  private static List<Position__c> matchAcctsToCompanies(
    List<Position__c> posnLst
  ) {
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
      List<Account> acctLst = Database.query(qry, AccessLevel.USER_MODE);

      for (Position__c postn : posnLst) {
        for (Account acct : acctLst) {
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

  @testVisible
  private static List<Account> createNewAcctsForCompanies(
    List<Position__c> posnLst
  ) {
    List<Account> newAccounts = new List<Account>();
    for (Position__c posn : posnLst) {
      if (posn.Company__c == null) {
        Account newAcct = new Account(name = posn.Company_Name__c);
      }
    }
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
    return input;
  }
}
