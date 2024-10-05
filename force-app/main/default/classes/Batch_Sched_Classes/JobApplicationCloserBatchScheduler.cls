/**
 * @description       : 
 * @author            : admillican08@gmail.com
 * @group             : 
 * @last modified on  : 09-26-2024
 * @last modified by  : admillican08@gmail.com
**/
public with sharing class JobApplicationCloserBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
    JobApplicationCloserBatch jobApps = new JobApplicationCloserBatch();
    Database.executeBatch(jobApps);
  }
}