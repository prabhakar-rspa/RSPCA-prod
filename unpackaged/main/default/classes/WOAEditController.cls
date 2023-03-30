public without sharing class WOAEditController {

    @AuraEnabled
    public static WOA__c getWOASummaryRecord(String recordId) {
        List<WOA__c> woaList = [SELECT Id, Name, Application__c,Application__r.Assessment_Date__c, FF_Reg_No__c, Form_Completion_Date__c, Houses__c, Producer__c, Species_Type__c, Visit_Date__c, Visit_Type__c, Assessor__c, CompletingWOA__c, IsCompleted__c FROM WOA__c WHERE Id =:recordId];
        return woaList[0];
    }

    @AuraEnabled
    public static List<Assessor> getAssessors(){
        List<Assessor> assessorOptionsList = new List<Assessor>();
        List<User> assessorUsers = [SELECT Id, Name, Assessor__c FROM User WHERE IsActive = true AND Assessor__c = true];
        for(User u : assessorUsers){
            Assessor assessOption = new Assessor();
            assessOption.label = u.Name;
            assessOption.value = u.Id;
            assessorOptionsList.add(assessOption);
        }
        return assessorOptionsList;

    }

    @AuraEnabled
    public static void saveWOASummary(WOA__c woaSummary){
        if(woaSummary != null){
            System.debug('woaSummary => ' + woaSummary);
            update woaSummary;
        }
    }

    public class Assessor {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
}