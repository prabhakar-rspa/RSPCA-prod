public class SendPaymentConfirmationEmailBatch implements Database.Batchable<sObject>, Schedulable{

    public List<Application__c> appList = new List<Application__c>();

    public Database.QueryLocator start(Database.BatchableContext bc){
        appList = [SELECT Id, Name, Head_Office__c FROM Application__c WHERE Payment_Confirmation_Sent__c = false AND (Stage__c = 'Application' OR Renewal_Stage__c = 'Renewal') AND (RecordType.Name = 'Applications' OR RecordType.Name = 'Renewal') AND Paid__c = true];
        Set<Id> headOfcIdSet = new Set<Id>();
        for(Application__c app : appList){
            if(app.Head_Office__c != null){
                headOfcIdSet.add(app.Head_Office__c);
            }
        }
        return Database.getQueryLocator('SELECT Id, Primary_Contact__c, Primary_Contact__r.Email FROM Account WHERE Id IN: headOfcIdSet');
    }

    public void execute(Database.BatchableContext bc, List<Account> actList){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'CombinedPaymentConfirmationEmail'];
        List<Application__c> appUpdateList = new List<Application__c>();
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
                if(appList.size() > 0){
                    for(Application__c app : appList){
                        if(act.Id == app.Head_Office__c){
                            app.Payment_Confirmation_Sent__c = true;
                            appUpdateList.add(app);
                        }
                    }
                }
            }else {
                System.debug('The email failed to send: '+results[0].errors[0].message);
            }
        }
        if(appUpdateList.size() > 0){
            update appUpdateList;
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
    public void execute(SchedulableContext sc){
        SendPaymentConfirmationEmailBatch obj = new SendPaymentConfirmationEmailBatch();
        Database.executeBatch(obj);
    }
}