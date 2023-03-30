public class SendFinalPaymentReminderEmailBatch implements Database.Batchable<sObject>, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc){
        List<Application__c> appList = [SELECT Id, Name, Head_Office__c FROM Application__c WHERE (Stage__c = 'Application' OR Renewal_Stage__c = 'Renewal') AND (RecordType.Name = 'Applications' OR RecordType.Name = 'Renewal') AND Paid__c = false AND CreatedDate = N_DAYS_AGO:4 AND Total_Amount_Inc_VAT__c > 0];
        Set<Id> headOfcIdSet = new Set<Id>();
        for(Application__c app : appList){
            if(app.Head_Office__c != null){
                headOfcIdSet.add(app.Head_Office__c);
            }
        }
        return Database.getQueryLocator('SELECT Id, Primary_Contact__c, Primary_Contact__r.Email FROM Account WHERE Id IN: '+headOfcIdSet);
    }

    public void execute(Database.BatchableContext bc, List<Account> actList){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'FinalPaymentReminder'];
        for(Account act : actList){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(act.Primary_Contact__c); 
            message.setSenderDisplayName('RSPCA Assured'); 
            message.setReplyTo('accounts@rspcaassured.org.uk');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(true);
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(act.Id);
            message.toAddresses = new String[] {act.Primary_Contact__r.Email};
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success){
                System.debug('The email was sent successfully.');
            }else {
                System.debug('The email failed to send: '+results[0].errors[0].message);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
    public void execute(SchedulableContext sc){
        SendFinalPaymentReminderEmailBatch obj = new SendFinalPaymentReminderEmailBatch();
        Database.executeBatch(obj);
    }
}