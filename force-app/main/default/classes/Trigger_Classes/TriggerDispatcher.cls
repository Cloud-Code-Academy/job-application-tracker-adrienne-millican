/**
 * @description       : Based on the desgin by Jigar Shah and Amit Chaudhary
 * @author            : admillican08@gmail.com
 * @group             : 
 * @last modified on  : 09-13-2024
 * @last modified by  : admillican08@gmail.com
**/

public with sharing class TriggerDispatcher {
  public static void run(ITriggerHandler handler) {
    //System.debug('*** Run method of TriggerDispatcher is executing ***');

    // Detect the current trigger context and fire relevant methods on
    // the trigger handler:

    // Before trigger logic:
    if (Trigger.isBefore) {
      if (Trigger.isInsert)
        handler.beforeInsert(Trigger.new);

      if (Trigger.isUpdate)
        handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);

      if (Trigger.isDelete)
        handler.beforeDelete(Trigger.oldMap);
    } // isBefore

    // After trigger logic:

    if (Trigger.isAfter) {
      if (Trigger.IsInsert)
        handler.afterInsert(Trigger.newMap);

      if (Trigger.isUpdate) {
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
      }
      if (Trigger.isDelete) {
        handler.afterDelete(Trigger.oldMap);
      } // isAfter
    }
  }
}
