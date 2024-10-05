/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JoobleCalloutBatchScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    JoobleCalloutBatch jobBatch = new JoobleCalloutBatch();
    Database.executeBatch(jobBatch);
  }
}