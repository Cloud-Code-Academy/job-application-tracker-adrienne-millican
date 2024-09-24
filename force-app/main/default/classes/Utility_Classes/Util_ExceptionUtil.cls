/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/

public without sharing class Util_ExceptionUtil {
  public class CustomException extends Exception {
  }

  @InvocableMethod(
    label='Invoke ExceptionUtil'
    description='throws new Custom Exception'
  )
  public static void throwCustomException(List<String> exMessage) {
    String msg = exMessage[0];
    if (!msg.startsWith('***ERROR: ') && !msg.startsWith('**ERROR: ')) {
      msg = '**ERROR: ' + exMessage[0];
    } else {
      msg = exMessage[0];
    }
    throw new CustomException(msg);
  }

  // publish an Exception platform event. This allows us
  // to capture Exception information even if the
  // Exception is rolled back

  public static void publishException(
    String objName,
    String procName,
    String opName,
    String recId,
    String excDetails
  ) {
    //Create platform event and assign
    Exception_Log__e pe = new Exception_Log__e();
    pe.Object__c = objName;
    pe.Process__c = procName;
    pe.Operation__c = opName;
    pe.Exception_Details__c = excDetails;
    pe.Obj_Record_Id__c = recId;
    pe.Running_User_Id__c = UserInfo.getUserId();
    EventBus.publish(pe);
    throwCustomException(new List<String>{ excDetails });
  }
}
