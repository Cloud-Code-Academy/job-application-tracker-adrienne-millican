/**
 * @description       :
 * @author            : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 * @group             :
 * @last modified on  : 10-29-2023
 * @last modified by  : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 **/
@IsTest(IsParallel=true)
private with sharing class RecursiveCheckerTest {
  @isTest
  public static void verifyMethodsRunContainsSingleString() {
    String newName1 = 'doThis';
    Test.startTest();
    RecursiveChecker.addMethodName('Contact', newName1);
    Boolean hasIt = RecursiveChecker.hasRun('Contact', newName1);
    Test.stopTest();
    System.assertEquals(
      true,
      hasIt,
      'Value of verifyMethodsRunContainsSingleString not as expected.'
    );
  }
  @isTest
  public static void verifyMethodsRunContainsStringSet() {
    String newName1 = 'doThis';
    String newName2 = 'doThat';
    String newName3 = 'doTheOtherThing';
    Test.startTest();
    Set<String> strSet = new Set<String>{ newName1, newName2, newName3 };
    RecursiveChecker.addMethodNames('Opportunity', strSet);
    Boolean hasIt = RecursiveChecker.hasRun('Opportunity', strSet);
    Test.stopTest();
    System.assertEquals(true, hasIt, 'Value of verifyMethodsRunContainsStringSet not as expected.');
  }
  @isTest
  public static void verifySingleMethodNameRemoved() {
    String newName1 = 'doThis';
    String newName2 = 'doThat';
    Test.startTest();
    RecursiveChecker.addMethodName('Account', newName1);
    RecursiveChecker.addMethodName('Contact', newName2);
    Boolean hasOne = RecursiveChecker.hasRun('Account', newName1);
    Boolean hasTwo = RecursiveChecker.hasRun('Contact', newName2);
    System.assertEquals(
      true,
      hasOne,
      'Value of setup for verifySingleMethodNameRemoved not as expected.'
    );
    System.assertEquals(
      true,
      hasTwo,
      'Value of setup for verifySingleMethodNameRemoved not as expected.'
    );
    RecursiveChecker.removeMethodName('Account', newName1);
    hasOne = RecursiveChecker.hasRun('Account', newName1);
    hasTwo = RecursiveChecker.hasRun('Contact', newName2);
    Test.stopTest();
    System.assertEquals(
      false,
      hasOne,
      'Value of removed method for verifySingleMethodNameRemoved not as expected.'
    );
    System.assertEquals(
      true,
      hasTwo,
      'Value of remaining method for verifySingleMethodNameRemoved not as expected.'
    );
  }
  @isTest
  public static void verifyAllMethodNamesRemoved() {
    String newName1 = 'doThis';
    String newName2 = 'doThat';
    String newName3 = 'doTheOtherThing';
    Test.startTest();
    Set<String> strSet = new Set<String>{ newName1, newName2, newName3 };
    RecursiveChecker.addMethodNames('Contract', strSet);
    Boolean hasThem = RecursiveChecker.hasRun('Contract', strSet);
    System.assertEquals(
      true,
      hasThem,
      'Value of setup for verifyAllMethodNamesRemoved not as expected.'
    );
    String test1 = 'Test1';
    String test2 = 'Test2';
    Set<String> testSet = new Set<String>{ test1, test2 };
    RecursiveChecker.addMethodNames('Account', testSet);
    Boolean alsoHas = RecursiveChecker.hasRun('Account', testSet);
    List<String> myObjectLst = new List<String>{
      'Opportunity',
      'Account',
      'Contact',
      'Asset',
      'Contract'
    };
    RecursiveChecker.resetObjectTriggers(myObjectLst);
    hasThem = RecursiveChecker.hasRun('Contract', strSet);
    alsoHas = RecursiveChecker.hasRun('Account', testSet);
    Test.stopTest();
    System.assertEquals(
      false,
      hasThem,
      'Value of result for hasThem in verifyAllMethodNamesRemoved not as expected.'
    );
    System.assertEquals(
      false,
      alsoHas,
      'Value of result for alsoHas in verifyAllMethodNamesRemoved not as expected.'
    );
  }

  @isTest
  public static void verifyMethodsRunDoesNotHaveString() {
    String newName1 = 'doThis';
    String obj = 'System__c';
    String nonMethod = 'noLuck';
    Test.startTest();
    RecursiveChecker.addMethodName('System__c', newName1);
    Boolean hasIt = RecursiveChecker.hasRun('System__c', nonMethod);
    Test.stopTest();
    System.assertEquals(
      false,
      hasIt,
      'Value of verifyMethodsRunDoesNotHaveString not as expected.'
    );
  }

  @isTest
  public static void verifyClearAllRemovesEverything() {
    String newName1 = 'doThis';
    String newName2 = 'doThat';
    String newName3 = 'doTheOtherThing';
    Set<String> strSet = new Set<String>{ newName1, newName2, newName3 };
    RecursiveChecker.addMethodNames('Case', strSet);
    Set<String> methodSet = new Set<String>{ 'Test1', 'Test2', 'Test3' };
    RecursiveChecker.addMethodNames('Lead', methodSet);
    RecursiveChecker.resetAllTriggers();
    System.assertEquals(
      0,
      RecursiveChecker.objMethodsRunMap.size(),
      'Size of objMethodsRunMap not as expected'
    );
  }
}