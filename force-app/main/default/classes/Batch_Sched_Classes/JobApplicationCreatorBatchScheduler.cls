/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JobApplicationCreatorBatchScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    JobApplicationCreatorBatch jobApplBatch = new JobApplicationCreatorBatch();
    Database.executeBatch(jobApplBatch);
  }
}