public class UnitDesriptionUpdateBatchJob implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        string query = 'SELECT ID,Description__c  FROM Unit__c Where Description__c !=null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Unit__c> units){
        List<Unit__c> updateUnits = new List<Unit__c>();
        for(Unit__c unit : units){
            if(unit.Description__c.contains('(')){
              unit.Description__c = unit.Description__c.substringBeforeLast('(');
              updateUnits.add(unit);   
            }            
        }
        if(!updateUnits.isEmpty())
        update updateUnits;
    }
    public void finish(Database.BatchableContext bc){
       
    }

}