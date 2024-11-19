/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-27-2024
 * @last modified by  : admillican08@gmail.com
 **/
trigger TaskTrigger on Task(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  TriggerDispatcher.run(new TaskTriggerHandler('Task'));
}