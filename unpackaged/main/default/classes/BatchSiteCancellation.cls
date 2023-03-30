global class BatchSiteCancellation implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    
    public Date twoWeeksBeforeToday = Date.today() -14;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,
                                                Account__c,
                                                Account__r.Membership_Expiry_Date__c,
                                                Account__r.Status__c,
                                                Status__c
                                                FROM Unit__c 
                                                WHERE Account__r.Membership_Expiry_Date__c < LAST_N_DAYS:27
                                                AND Status__c = 'Lapsed'
                                                AND Account__r.Status__c != 'CANCELLED']);
    }
    global void execute(Database.BatchableContext BC, List<Unit__c> scope) {
        Set<Id> accountIds = new Set<Id>();
        for(Unit__c unit : scope) {
            accountIds.add(unit.Account__c);
        }
        List<Account> accList = [SELECT Id, Status__c FROM Account WHERE Id IN :accountIds];
        for(Account a : accList){
            a.Status__c = 'CANCELLED';
        }
        if(!accList.isEmpty()){
            update accList;
        }
    }

    global void finish(Database.BatchableContext BC) {
    }

    // Schedulable method
    global void execute(SchedulableContext ctx) {
		Database.executeBatch(new BatchSiteCancellation(), 100);
    }
}