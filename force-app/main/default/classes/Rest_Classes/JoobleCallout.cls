/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-12-2024
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
      Dump__c newDump = new Dump__c(Text__c = jsonStr);
      insert newDump;
      JSONParser parser = JSON.createParser(jsonStr);
      List<JoobleJob> joobleJobLst = new List<JoobleJob>();
      parser.nextToken();
      parser.nextToken();
      JoobleJob newJob;
      while (parser.nextToken() != null) {
        if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
          switch on parser.getText() {
            when 'title' {
              newJob = new JoobleJob();
              parser.nextValue();
              newJob.title = parser.getText();
            }
            when 'location' {
              parser.nextValue();
              newJob.location = parser.getText();
            }
            when 'snippet' {
              parser.nextValue();
              newJob.description = parser.getText();
            }
            when 'salary' {
              parser.nextValue();
              newJob.salary = parser.getText();
            }
            when 'source' {
              parser.nextValue();
              newJob.source = parser.getText();
            }
            when 'type' {
              parser.nextValue();
              newJob.type = parser.getText();
            }
            when 'link' {
              parser.nextValue();
              newJob.link = parser.getText();
            }
            when 'company' {
              parser.nextValue();
              newJob.company = parser.getText();
            }
            when 'updated' {
              parser.nextValue();
              newJob.updated = parser.getText();
            }
            when 'id' {
              parser.nextValue();
              newJob.id = parser.getText();
              joobleJobLst.add(newJob);
              System.debug('**New job: ' + newJob);
            }
          }
        }
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
}
