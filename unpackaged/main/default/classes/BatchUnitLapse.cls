global class BatchUnitLapse implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,
                                                Account__c,
                                                Account__r.Membership_Expiry_Date__c,
                                                Status__c
                                                FROM Unit__c 
                                                WHERE Account__r.Membership_Expiry_Date__c < TODAY
                                                AND Status__c = 'Certified']);
    }
    global void execute(Database.BatchableContext BC, List<Unit__c> scope) {
        Set<Id> accountIds = new Set<Id>();
        for(Unit__c unit : scope) {
            unit.Status__c = 'Lapsed';
            accountIds.add(unit.Account__c);
        }
        update scope;

        List<Account> lapsedSites = [SELECT Id, Status__c FROM Account WHERE Id IN:accountIds];
        for(Account a : lapsedSites){
            a.Status__c = 'LAPSED';
        }
        update lapsedSites;
    }

    global void finish(Database.BatchableContext BC) {

    }
}