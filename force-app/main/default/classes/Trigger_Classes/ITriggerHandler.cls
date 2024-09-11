/**
 * @File Name          : ITriggerHandler.apxc
 * @Description        :
 * @Author             : Adrienne D. Millican, adapted from code by Jigar Shah and Jitendra Zaa
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
