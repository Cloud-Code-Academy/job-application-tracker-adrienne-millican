/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-25-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class JoobleCalloutScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    // Call the future method in the JoobleCallout class
    JoobleCallout.createNewPositionsFromJooble();
  }
}
