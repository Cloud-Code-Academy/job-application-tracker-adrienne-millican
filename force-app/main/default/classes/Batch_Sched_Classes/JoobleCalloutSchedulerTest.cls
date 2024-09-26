/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : admillican08@gmail.com
 **/
@IsTest
public class JoobleCalloutSchedulerTest {
  @IsTest
  static void testSchedulerExecutesSuccessfully() {
    // Set up mock callout to simulate the web service
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    Test.startTest();

    // Schedule the job
    String cronExpression = '0 0 0 15 3 ? 2025';
    String jobId = System.schedule(
      'Test JoobleCalloutScheduler Job',
      cronExpression,
      new JoobleCalloutScheduler()
    );

    // Assert that the job is scheduled
    CronTrigger cronTrigger = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE Id = :jobId
    ];
    Assert.isNotNull(cronTrigger, 'Expected job does not exist');
    Assert.areEqual(
      cronExpression,
      cronTrigger.CronExpression,
      'Expected match does not exist'
    );

    Test.stopTest();

    // Verify that the callout was simulated successfully via the mock
    // The logic in MockHttpResponseGenerator will handle this
  }

  public class MockHttpResponseGenerator implements HttpCalloutMock {
    // Simulate a successful response
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setBody('{"success":true}');
      return res;
    }
  }
}
