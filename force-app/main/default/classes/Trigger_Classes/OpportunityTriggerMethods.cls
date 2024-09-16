/**
 * @description       : 
 * @author            : admillican08@gmail.com
 * @group             : 
 * @last modified on  : 09-13-2024
 * @last modified by  : admillican08@gmail.com
**/
public with sharing class OpportunityTriggerMethods {
    public static final String GT = 'GateKeeper';
    public static final String BA = 'Budget Approver';
    public static final String TR = 'Technical Reviewer';
    public static final String DM = 'Decision Maker';
    public static final String EV = 'Evaluator';
    public static final String EDM = 'Economic Decision Maker';
    public static final String IF  = 'Influencer';
    public static final String NNB = 'Net New Business';
    public static final String CS = 'Cross-Sell';
    public static final String RN = 'Renewal';
    public static final String UP = 'Up-Sell';


    public String updateOpportunityContactRoles(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap){
        List<Opportunity> oppsToUpd = new List<Opportunity>();
        for(Opportunity newOpp: newOppMap.values()){
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if(newOpp?.Type.equals(oldOpp.Type)){
                return 'Nothing changed';
            }
            else if (!String.isBlank(newOpp.Type)){
                List<OpportunityContactRole> oppContactRoleLst = [SELECT Id, ContactId, Role FROM OpportunityContactRole];
                String oppType =  newOpp.Type;
                Map<Id, String> contCtToIdTypeMap = this.getContactTypes(newOpp.accountId);
                String conType =  
            }
        }
    }

    @Testvisible private Map<Id, String> getContactTypes(Id accountId){
        Map<Id, String> contactIdToTypeMap = new Map<Id, String>();
        Map<Id, Contact> contactMap = [SELECT Id, Type__c FROM Contact WHERE AccountId =: accountId AND Type IN ('GateKeeper', 'Budget Approver', 'Technical Reviewer', 'Decision Maker', 'Evaluator', 'Influencer')];
        for(Contact con: contactMap.values()){
            contactIdToTypeMap.put(con.Id, con.Type__c);
        }
        return contactIdToTypeMap;
    }

    @Testvisible private Map<String, List<String>> getContactTypeToOpportunityTypes(){
        Map<String, List<String>> conTypeToOppTypesMap = new Map<String, List<String>>();
        conTypeToOppTypesMap.put(GT, new List<String>{NNB});
        conTypeToOppTypesMap.put(BA, new List<String>{NNB, CS, RN, UP});
        conTypeToOppTypesMap.put(TR, new List<String>{NNB, CS, RN, UP});
        conTypeToOppTypesMap.put(DM, new List<String>{NNB, CS, RN, UP});
         conTypeToOppTypesMap.put(EV, new List<String>{NNB, UP});
          conTypeToOppTypesMap.put(IF, new List<String>{NNB, UP});
       
    }
}