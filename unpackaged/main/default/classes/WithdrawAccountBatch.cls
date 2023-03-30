public class WithdrawAccountBatch implements Database.Batchable<sObject>, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Name, Status__c, Date_Suspended_No_Evidence__c FROM Account WHERE Date_Suspended_No_Evidence__c != null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> actList){
        List<Account> ActUpdateList = new List<Account>();
        for(Account act : actList){
            if(act.Date_Suspended_No_Evidence__c.addDays(90) >= Date.today()){
                act.Status__c = 'WITHDRAWN';
                ActUpdateList.add(act);
            } 
        }
        if(ActUpdateList.size() > 0){
            try{
                update ActUpdateList;
            }catch(DMLException e){
                System.debug('Error while updating Account Status to Withdrawn '+e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc){}

    public void execute(SchedulableContext sc){
        WithdrawAccountBatch obj = new WithdrawAccountBatch();
        Database.executeBatch(obj);
    }
}