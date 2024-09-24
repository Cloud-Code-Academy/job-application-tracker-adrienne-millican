/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-23-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class AccountCreator {
  public static final String CLS_NAME = 'Account Creator';
  public static final String OBJ_NAME = 'Account';
  public static String createAccount(String acctName) {
    final String MTD_NAME = 'createAccount of' + CLS_NAME;
    Account acct = new Account(name = acctName);
    String msg = Util_Insert.insertRecord(OBJ_NAME, acct, MTD_NAME);
    Id acctId = acct.Id;
    msg += '; acct ID:' + acctId;
    return msg;
  }
}
