/**
 * @description       :
 * @author            : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 * @group             :
 * @last modified on  : 10-29-2023
 * @last modified by  : Adrienne D. Millican <adrienne.millican@swisslog-healthcare.com>
 **/
public without sharing class RecursiveChecker {
  public static Map<String, Set<String>> objMethodsRunMap {
    get {
      if (objMethodsRunMap == null) {
        objMethodsRunMap = new Map<String, Set<String>>();
        return objMethodsRunMap;
      } else {
        return objMethodsRunMap;
      }
    }
    private set;
  }

  public static Boolean hasRun(String objName, String methodName) {
    Set<String> methodsRun = new Set<String>();
    if (objMethodsRunMap.keySet().contains(objName)) {
      methodsRun = objMethodsRunMap.get(objName);
    }
    if (methodsRun.size() > 0 && methodsRun.contains(methodName)) {
      return true;
    } else {
      return false;
    }
  }

  public static Boolean hasRun(String objName, Set<String> methodNameSet) {
    Set<String> methodsRun = new Set<String>();
    if (objMethodsRunMap.keySet().contains(objName)) {
      methodsRun = objMethodsRunMap.get(objName);
    }
    if (methodsRun.size() > 0 && methodsRun.containsAll(methodNameSet)) {
      return true;
    } else {
      return false;
    }
  }

  public static void addMethodNames(String objName, Set<String> methodNames) {
    Set<String> methodsRun;
    if (!objMethodsRunMap.keySet().contains(objName)) {
      methodsRun = new Set<String>();
      objMethodsRunMap.put(objName, methodsRun);
    } else {
      methodsRun = objMethodsRunMap.get(objName);
    }
    methodsRun.addAll(methodNames);
  }

  public static void addMethodName(String objName, String methodName) {
    Set<String> methodsRun;
    if (!objMethodsRunMap.keySet().contains(objName)) {
      methodsRun = new Set<String>();
      objMethodsRunMap.put(objName, methodsRun);
    } else {
      methodsRun = objMethodsRunMap.get(objName);
    }
    methodsRun.add(methodName);
  }

  public static void removeMethodName(String objName, String methodName) {
    if (objMethodsRunMap.keySet().contains(objName)) {
      Set<String> methodsRun = objMethodsRunMap.get(objName);
      methodsRun.remove(methodName);
    }
  }

  @InvocableMethod(label='resetObjectTriggers')
  public static void resetObjectTriggers(List<String> objNameLst) {
    Integer i = objNameLst.size();
    for (Integer k = 0; k < i; k++) {
      String objName = objNameLst[k];
      if (objMethodsRunMap.keyset().contains(objName)) {
        Set<String> methodsRun = objMethodsRunMap.get(objName);
        methodsRun.clear();
      }
    }
  }

  public static void resetAllTriggers() {
    if (objMethodsRunMap.size() > 0) {
      objMethodsRunMap = new Map<String,Set<String>>();
    }
  }
}