public class AppUnitInsertBatch implements Database.Batchable<sObject>,Database.stateful {
    public List<Application_Unit__c> appUnits;
    public AppUnitInsertBatch(List<Application_Unit__c> appUnits) {
        this.appUnits = appUnits;
    }

    public Iterable<SObject> start(Database.BatchableContext BC){
        return appUnits;
    }
    
    public void execute(Database.BatchableContext BC, List<Application_Unit__c> auList){
        insert auList;
    }
    
    public void finish(Database.BatchableContext BC){
    //code for Finish
    }
}