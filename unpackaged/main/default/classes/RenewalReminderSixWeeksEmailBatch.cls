public class RenewalReminderSixWeeksEmailBatch implements Database.Batchable<sObject>, Schedulable{
    // Working version of the Bulk Six Week renewal reminder
    public Database.QueryLocator start(Database.BatchableContext bc){
        if(UserInfo.getUserEmail() == 'help@rspcaassured.org.uk'){
            Date reminderDate = Date.today();
            x6WeekRenewalReminderTestDate__c testDateSetting = x6WeekRenewalReminderTestDate__c.getOrgDefaults();
            if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Date__c != null){
                reminderDate = testDateSetting.Test_Date__c;
            }
            List<Account> siteList = [SELECT Id,
                                            Status__c,
                                            Primary_Contact__c,
                                            Primary_Contact__r.Email,
                                            Membership_Expiry_Date__c,
                                            Renewal_Date__c,
                                            Six_Week_Renewal_Reminder_Sent__c,
                                            ParentId
                                            FROM Account
                                            WHERE
                                            Status__c = 'MEMBER'
                                            AND
                                            X6_Week_Renewal_Scheduled_Date__c =:reminderDate
                                            AND 
                                            Six_Week_Renewal_Reminder_Sent__c = null
                                            AND RecordType.DeveloperName = 'Site'
                                            AND ParentId != null
                                            AND Active__c = true
                                            AND Renewal_Reminder_Ready__c = true];
            Set<Id> headOfcIdSet = new Set<Id>();
            for(Account acc : siteList){
                if(acc.ParentId != null){
                    headOfcIdSet.add(acc.ParentId);
                }
            }
            return Database.getQueryLocator('SELECT Id, Primary_Contact__c, Primary_Contact__r.Email FROM Account WHERE Id IN:headOfcIdSet AND Primary_Contact__r.Email != null');
        }else{
            return null;
        }
            
    }

    public void execute(Database.BatchableContext bc, List<Account> actList){
        x6WeekRenewalReminderTestDate__c testDateSetting = x6WeekRenewalReminderTestDate__c.getOrgDefaults();
        
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE DeveloperName = 'RenewalReminderSixWeek'];
        Set<String> headOfficeRemindersSent = new Set<String>();
        for(Account act : actList){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Contact_Id__c != null){
                message.setTargetObjectId(testDateSetting.Test_Contact_Id__c); 
                message.setSaveAsActivity(false);
            }else {
                message.setTargetObjectId(act.Primary_Contact__c); 
                message.setSaveAsActivity(true);
            }
            message.setSenderDisplayName('RSPCA Assured'); 
            message.setReplyTo('help@rspcaassured.org.uk');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(act.Id);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success){
                System.debug('The email was sent successfully.');
                headOfficeRemindersSent.add(act.Id);
                Renewal_Reminder_Log__c log = new Renewal_Reminder_Log__c(
                    Status__C = 'Success',
                    Target_Object_Id__c = act.Id,
                    Reminder_Name__c = 'Six Week Renewal Reminder From Head Office'
                );
                insert log;
            }else {
                System.debug('The email failed to send: '+results[0].errors[0].message);
                Object sc = (Object)results.get(0).getErrors()[0].getStatusCode();
                Renewal_Reminder_Log__c log = new Renewal_Reminder_Log__c(Status__C = 'Error', Target_Object_Id__c = results.get(0).getErrors()[0].getTargetObjectId(), Error_Message__c = results.get(0).getErrors()[0].getMessage(), Fields__c = results.get(0).getErrors()[0].getFields().toString(), Status_Code__c = sc.toString(), Reminder_Name__c = 'Six Week Renewal Reminder From Head Office');
                insert log;
            }
        }
        if(testDateSetting.Use_Test_Date_Data__c == false){
            // Update site sent checkbox
            List<Account> sites = [SELECT Id, Six_Week_Renewal_Reminder_Sent__c, Final_Renewal_Reminder_Sent__c FROM Account WHERE Status__c = 'MEMBER' AND
            X6_Week_Renewal_Scheduled_Date__c =:Date.today()
            AND 
            Six_Week_Renewal_Reminder_Sent__c = null
            AND RecordType.DeveloperName = 'Site'
            AND ParentId IN: headOfficeRemindersSent
            AND Active__c = true
            AND Renewal_Reminder_Ready__c = true];
            for(Account a : sites){
                a.Six_Week_Renewal_Reminder_Sent__c = Date.today();
            }
            update sites;
        }
        
    }
    
    public void finish(Database.BatchableContext bc){}
    
    public void execute(SchedulableContext sc){
        RenewalReminderSixWeeksEmailBatch obj = new RenewalReminderSixWeeksEmailBatch();
        Database.executeBatch(obj, 1);
    }
}