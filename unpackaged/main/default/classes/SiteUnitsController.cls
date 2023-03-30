public without sharing class SiteUnitsController {
    
    @AuraEnabled
    public static List<Unit__c> getUnits(String accId){
        List<Unit__c> unitList = [SELECT Id, Account__c, Name, Business__c, Production__c, Rearing_System__c, Status__c  FROM Unit__c WHERE Account__c =:accId AND Status__c IN ('Lapsed','Certified')];
        System.debug('Unit Size ==> ' + unitList.size());
        return unitList;
    }
}