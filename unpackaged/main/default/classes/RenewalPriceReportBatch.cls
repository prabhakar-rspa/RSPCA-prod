public class RenewalPriceReportBatch implements Database.Batchable<sObject>, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc){
        Date pricingDate = Date.today();
        x6WeekRenewalReminderTestDate__c testDateSetting = x6WeekRenewalReminderTestDate__c.getOrgDefaults();
        if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Date__c != null){
            pricingDate = testDateSetting.Test_Date__c;
        }
        return Database.getQueryLocator([SELECT Id,
                                        Status__c,
                                        Primary_Contact__c,
                                        Primary_Contact__r.Email,
                                        Renewal_Date__c,
                                        Membership_Expiry_Date__c,
                                        Final_Renewal_Reminder_Sent__c ,
                                        Six_Week_Renewal_Reminder_Sent__c,
                                        Renewal_Reminder_Ready__c,
                                        ParentId
                                        FROM Account
                                        WHERE
                                        Status__c = 'MEMBER'
                                        AND
                                        RenewalPriceReportBatchDate__c =:pricingDate
                                        AND 
                                        Renewal_Reminder_Ready__c  = false
                                        AND 
                                        Primary_Contact__r.Email != null
                                        AND RecordType.DeveloperName = 'Site'
                                        AND ParentId != null
                                        AND Active__c = true]);
    }

    public void execute(Database.BatchableContext bc, List<Account> actList){
        for(Account acc : actList){
            RenewalPriceChecker rpc = new RenewalPriceChecker();
            rpc.createRenewalPriceReport(acc.Id);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
    public void execute(SchedulableContext sc){
        RenewalPriceReportBatch obj = new RenewalPriceReportBatch();
        Database.executeBatch(obj, 1);
    }
}