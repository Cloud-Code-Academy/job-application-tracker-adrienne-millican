/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-10-2024
 * @last modified by  : admillican08@gmail.com
 **/
public with sharing class Util_ProfileRoleUtils {
  private static Map<String, Id> profNameToIdMap = new Map<String, Id>();
  private static Map<String, Id> roleNameToIdMap = new Map<String, Id>();
  public static Id getProfileIdByName(String name) {
    if (profNameToIdMap.isEmpty()) {
      for (Profile prof : [
        SELECT Id, Name
        FROM Profile
        WHERE UserLicense.Name = 'Salesforce' AND UserType = 'Standard'
      ]) {
        profNameToIdMap.put(prof.Name, prof.Id);
      }
    }
    return profNameToIdMap.get(name);
  }

  public static Id getUserRoleIdByDevName(String devName) {
    if (roleNameToIdMap.isEmpty()) {
      for (UserRole urole : [
        SELECT Id, DeveloperName, ParentRoleId
        FROM UserRole
      ]) {
        roleNameToIdMap.put(urole.DeveloperName, urole.Id);
      }
    }
    return roleNameToIdMap.get(devName);
  }
}
