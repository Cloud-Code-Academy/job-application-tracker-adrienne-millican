/**
 * @description       :
 * @author            : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 * @group             :
 * @last modified on  : 09-24-2024
 * @last modified by  : admillican08@gmail.com
 **/
public without sharing class Util_Insert {
  public static String messageStr { get; private set; }
  public static final String CLSS_NAME = 'Util_Insert';

  /**
   * @description static method for inserting a list of sObjects
   * @author admillican08@gmail.com | 09-11-2024
   * @param objName
   * @param objsToUpdLst
   * @param callingMethod
   * @return String
   **/
  public static String insertList(
    String objName,
    List<sObject> objsToUpdLst,
    String callingMethod
  ) {
    final String MTHD_NAME = 'insertList method';
    if (objsToUpdLst.size() > 0) {
      try {
        // Insert the list
        insert as SYSTEM objsToUpdLst;
        messageStr =
          '**Inserted ' +
          objsToUpdLst.size() +
          ' record(s) of ' +
          objName +
          ' type in ' +
          MTHD_NAME +
          ', ' +
          CLSS_NAME +
          ' called by ' +
          callingMethod;
      } catch (DmlException dmlEx) {
        String insDetails =
          'Method: ' +
          MTHD_NAME +
          ', ' +
          CLSS_NAME +
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
        Util_ExceptionUtil.publishException(
          objName,
          MTHD_NAME + ' called by ' + callingMethod,
          CLSS_NAME,
          null,
          insDetails
        );
        Util_ExceptionUtil.throwCustomException(new List<String>{ insDetails });
      }
    } else {
      messageStr =
        '**No records of ' +
        objName +
        ' to insert in ' +
        MTHD_NAME +
        ', ' +
        CLSS_NAME +
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
    final String MTHD_NAME = 'insertRecord method';
    callingMethod =
      MTHD_NAME +
      ', ' +
      CLSS_NAME +
      ' called by ' +
      callingMethod;
    return Util_Insert.insertList(objName, objLst, callingMethod);
  }
}
