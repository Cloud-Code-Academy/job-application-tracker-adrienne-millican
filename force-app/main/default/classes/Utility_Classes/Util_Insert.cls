/**
 * @description       :
 * @author            : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 * @group             :
 * @last modified on  : 09-11-2024
 * @last modified by  : admillican08@gmail.com
 **/
public without sharing class Util_Insert {
  public static String messageStr { get; private set; }

  /**
   * @description static method for inserting a list of sObjects
   * @author admillican08@gmail.com | 09-11-2024
   * @param objName
   * @param objsToUpd
   * @param callingMethod
   * @return String
   **/
  public static String insertList(
    String objName,
    List<sObject> objsToUpd,
    String callingMethod
  ) {
    String methodName = 'insertList method of Util_Insert class';
    String objId;
    if (objsToUpd.size() > 0) {
      try {
        // Insert the list
        insert as SYSTEM objsToUpd;
        messageStr =
          '**Inserted ' +
          objsToUpd.size() +
          ' record(s) of ' +
          objName +
          ' type in ' +
          methodName +
          ' called by ' +
          callingMethod;
      } catch (DmlException dmlEx) {
        String insDetails =
          'Method: ' +
          methodName +
          '; Cause: ' +
          dmlEx.getCause() +
          '; Line Number: ' +
          dmlEx.getLineNumber() +
          '; MessageStr: ' +
          dmlEx.getMessage() +
          '; Stack Trace: ' +
          dmlEx.getStackTraceString() +
          '; Type Name: ' +
          dmlEx.getTypeName();
        //Publish a platform event that is published immediately with the exception information in case the exception is rolled back
        objId = Test.isRunningTest() ? 'test' : objsToUpd[0].id;
        Util_ExceptionUtil.publishException(
          objName,
          methodName,
          callingMethod,
          objId,
          insDetails
        );
        Util_ExceptionUtil.throwCustomException(new List<String>{ insDetails });
      }
    } else {
      messageStr =
        '**No records of ' +
        objName +
        ' to insert in ' +
        methodName +
        ' called by ' +
        callingMethod;
    }
    return messageStr;
  }

  /**
   * @description static method for inserting a single sObject
   * @author admillican08@gmail.com | 09-11-2024
   * @param objName
   * @param objRecd
   * @param callingMethod
   * @return String
   **/
  public static String insertRecord(
    String objName,
    sObject objRecd,
    String callingMethod
  ) {
    List<sObject> objLst = new List<sObject>{ objRecd };
    String methodName = 'insertRecord method of Util_Insert class';
    String objId;
    callingMethod = methodName + ' called by ' + callingMethod;
    return Util_Insert.insertList(objName, objLst, callingMethod);
  }

  @InvocableMethod(
    label='Insert Records'
    description='Allows the insert of sObject records'
  )
  /**
   * @description invocable method for inserting a list of list of SObjects
   * @author admillican08@gmail.com | 09-11-2024
   * @param lstofSobjectLsts
   **/
  public static void insertListInvocable(List<List<sObject>> lstofSobjectLsts) {
    String methodName = 'insertListInvocable method of Util_Insert class';
    List<sObject> objLst = new List<sObject>();
    for (List<sObject> invLst : lstofSobjectLsts) {
      if (invLst.size() > 0) {
        for (sObject obj : invLst) {
          objLst.add(obj);
        }
      }
    }
    messageStr = Util_Insert.insertList('<objName>', objLst, methodName);
  }
}
