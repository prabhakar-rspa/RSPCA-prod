public class SendBulkRenewalInvoiceEmailBatch implements Database.Batchable<sObject>, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Name, Head_Office__r.Primary_Contact__c, Head_Office__r.Primary_Contact__r.Email, Invoice_Email_Sent__c FROM Bulk_Renewal__c WHERE Invoice_Email_Sent__c = false');
    }

    public void execute(Database.BatchableContext bc, List<Bulk_Renewal__c> appList){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'BulkRenewalInvoiceEmail'];
        List<Bulk_Renewal__c> blkRnwUpdateList = new List<Bulk_Renewal__c>();
        for(Bulk_Renewal__c app : appList){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(app.Head_Office__r.Primary_Contact__c); 
            message.setSenderDisplayName('RSPCA Assured'); 
            message.setReplyTo('accounts@rspcaassured.org.uk');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(true);
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(app.Id);
            message.toAddresses = new String[] {app.Head_Office__r.Primary_Contact__r.Email};
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success){
                System.debug('The email was sent successfully.');
                app.Invoice_Email_Sent__c = true;
                blkRnwUpdateList.add(app);
            }else {
                System.debug('The email failed to send: '+results[0].errors[0].message);
            }
        }
        if(blkRnwUpdateList.size() > 0){
            update blkRnwUpdateList;
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
    public void execute(SchedulableContext sc){
        SendBulkRenewalInvoiceEmailBatch obj = new SendBulkRenewalInvoiceEmailBatch();
        Database.executeBatch(obj);
    }
}