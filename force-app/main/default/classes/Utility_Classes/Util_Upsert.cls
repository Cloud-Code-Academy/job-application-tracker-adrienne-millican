/**
 * @description       :
 * @author            : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 * @group             :
 * @last modified on  : 09-11-2024
 * @last modified by  : admillican08@gmail.com
 **/
public without sharing class Util_Upsert {
  public static String messageStr { get; private set; }

  /**
   * @description
   * @author admillican08@gmail.com | 09-11-2024
   * @param objName
   * @param objsToUpd
   * @param callingMethod
   * @return String
   **/
  public static String upsertList(
    String objName,
    List<sObject> objsToUpd,
    String callingMethod
  ) {
    String methodName = 'upsertList method of Util_Upsert class';
    String objId;
    if (objsToUpd.size() > 0) {
      try {
        // Upsert the list
        upsert as SYSTEM objsToUpd;
        messageStr =
          '**Upserted ' +
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
        ' to upsert in ' +
        methodName +
        ' called by ' +
        callingMethod;
    }
    return messageStr;
  }
  /**
   * @description static method for upserting a single sObject record
   * @author admillican08@gmail.com | 09-11-2024
   * @param objName
   * @param objRecd
   * @param callingMethod
   * @return String
   **/
  public static String upsertRecord(
    String objName,
    sObject objRecd,
    String callingMethod
  ) {
    List<sObject> objLst = new List<sObject>{ objRecd };
    String methodName = 'upsertRecord method of Util_Upsert class';
    String objId;
    callingMethod = methodName + ' called by ' + callingMethod;
    return Util_Upsert.upsertList(objName, objLst, callingMethod);
  }

  @InvocableMethod(
    label='Upsert Records'
    description='Allows the upsert of sObject records'
  )
  /**
   * @description Invocable method for upserting a list of list of sObjects
   * @author admillican08@gmail.com | 09-11-2024
   * @param lstofSobjectLsts
   **/
  public static void upsertListInvocable(List<List<sObject>> lstofSobjectLsts) {
    String methodName = 'upsertListInvocable method of Util_Upsert class';
    List<sObject> objLst = new List<sObject>();
    for (List<sObject> invLst : lstofSobjectLsts) {
      if (invLst.size() > 0) {
        for (sObject obj : invLst) {
          objLst.add(obj);
        }
      }
    }
    messageStr = Util_Upsert.upsertList('<objName>', objLst, methodName);
  }
}
