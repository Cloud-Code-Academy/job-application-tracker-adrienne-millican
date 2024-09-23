/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-23-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JoobleCallout {
  @future(callout=true)
  public static void getJoobleJobListing() {
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
      // newDump = new Dump__c(Text__c = jsonStr);
      //insert newDump;
      JSONParser parser = JSON.createParser(jsonStr);
      List<Position__c> joobleJobLst = new List<Position__c>();
      parser.nextToken();
      parser.nextToken();
      while (parser.nextToken() != null) {
        Position__c newPosn = new Position__c();

        joobleJobLst.add(newPosn);
      }
      System.debug('**Size of Jooble Job List is ' + joobleJobLst.size());
    }
  }

  @testVisible
  private static String removeExtraneous(String input) {
    input = input.replaceAll('\\\\[a-z]', '');
    input = input.replaceAll('~', '');
    input = input.replaceAll('&nbsp;', '');
    input = input.replaceAll('\\?\\?', '');
    input = input.replaceAll('</*[a-z]>', '');
    return input;
  }

  @testVisible
  private static Position__c createPosition(
    JsonParser parser,
    Position__c posn
  ) {
    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
      switch on parser.getText() {
        when 'title' {
          parser.nextValue();
          posn.Title__c = parser.getText();
        }
        when 'location' {
          parser.nextValue();
          posn.Job_Location__c = parser.getText();
        }
        when 'snippet' {
          parser.nextValue();
          posn.Position_Description__c = parser.getText();
        }
        when 'salary' {
          parser.nextValue();
          posn.Salary__c = Decimal.valueOf(parser.getText());
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
          posn.company = parser.getText();
        }
        when 'updated' {
          parser.nextValue();
          posn.updated = parser.getText();
        }
        when 'id' {
          parser.nextValue();
          posn.id = parser.getText();
          System.debug('**New job: ' + posn);
        }
      }
    }
    return posn;
  }
}
