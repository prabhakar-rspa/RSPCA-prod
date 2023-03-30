public class SuspendAccountBatch implements Database.Batchable<sObject>, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Name, Evidence__c, Evidence_Deadline__c, Extension_Deadline__c, Site__c FROM Application__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Application__c> appList){
        Date dt = Date.today();
        List<Account> actUpdateList = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();
        for(Application__c app : appList){
            if(app.Site__c != null){
                accIdSet.add(app.Site__c);
            }
        }

        List<Account> actList = [SELECT Id, Name, Status__c FROM Account WHERE Id IN: accIdSet];

        for(Application__c app : appList){
            for(Account act : actList){
                if(app.Extension_Deadline__c != null && app.Evidence__c == null 
                   && app.Extension_Deadline__c <= dt && app.Site__c == act.Id){
                       act.Status__c = 'SUSPENDED';
                       act.Date_Suspended_No_Evidence__c = Date.today();
                       actUpdateList.add(act);
                   }else if(app.Evidence_Deadline__c != null && app.Evidence__c == null 
                            && app.Evidence_Deadline__c <= dt && app.Site__c == act.Id){
                                act.Status__c = 'SUSPENDED';
                                act.Date_Suspended_No_Evidence__c = Date.today();
                                actUpdateList.add(act);
                   }
            }
        }

        if(actUpdateList.size() > 0){
            try{
                update actUpdateList;
            }catch(DMLException e){
                System.debug('Error updating Account Status to suspended '+e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc){}

    public void execute(SchedulableContext sc){
        SuspendAccountBatch obj = new SuspendAccountBatch();
        Database.executeBatch(obj);
    }
}