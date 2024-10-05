trigger ExceptionLog on Exception_Log__e (after insert) {
    List<Exception__c> excList = new List<Exception__c>();
    for(Exception_Log__e ex: Trigger.new){
        Exception__c exc = new Exception__c();
        exc.Object__c = ex.Object__c;
        exc.Process__c = ex.Process__c;
        exc.Operation__c = ex.Operation__c;
        exc.Obj_Record_Id__c = ex.Obj_Record_Id__c;
        exc.Exception_Details__c = ex.Exception_Details__c;
        exc.OwnerId = ex.Running_User_Id__c;
        excList.add(exc);
    }
    
    if (!excList.isEmpty()){
        insert as system excList;
    }
}