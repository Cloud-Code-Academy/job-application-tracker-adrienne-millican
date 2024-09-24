/**
 * @description       : Based on the desgin by Jigar Shah and Amit Chaudhary
 * @author            : admillican08@gmail.com
 * @group             : 
 * @last modified on  : 09-13-2024
 * @last modified by  : admillican08@gmail.com
**/

public interface ITriggerHandler {
  void beforeInsert(List<SObject> newItems);

  void beforeUpdate(Map<Id, SOBject> newItems, Map<Id, SObject> oldItems);

  void beforeDelete(Map<ID, SOBject> oldItems);

  void afterInsert(Map<Id, SObject> newItems);

  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);

  void afterDelete(Map<Id, SObject> oldItems);

  void afterUndelete(Map<Id, SObject> newItems);
} // ITriggerhandler ends