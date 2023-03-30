public class SendEvidenceReminderEmailBatch implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc){
        List<Application__c> extAppList = [SELECT Id, Name FROM Application__c WHERE Extension_Deadline__c != null AND Evidence_Email_Sent__c = false AND Extension_Deadline__c = NEXT_N_WEEKS:2];
        List<Application__c> evdAppList = [SELECT Id, Name FROM Application__c WHERE Evidence_Deadline__c != null AND Extension_Deadline__c = null AND Evidence_Email_Sent__c = false AND Evidence_Deadline__c = NEXT_N_WEEKS:2];
        Set<Id> appIdSet = new Set<Id>();
        for(Application__c app : extAppList){
            appIdSet.add(app.Id);
        }
        for(Application__c app : evdAppList){
            appIdSet.add(app.Id);
        }
        String query = 'SELECT Id, Applicant_Contact__c, Applicant_Contact__r.Email, Evidence_Email_Sent__c FROM Application__c WHERE Id IN: appIdSet';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Application__c> appList){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'EvidenceReminder'];
        List<Application__c> appUpdateList = new List<Application__c>();
        for(Application__c app : appList){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(app.Applicant_Contact__c); 
            message.setSenderDisplayName('RSPCA Assured'); 
            message.setReplyTo('help@rspcaassured.org.uk');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(true);
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(app.Id);
            message.toAddresses = new String[] {app.Applicant_Contact__r.Email};
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success){
                System.debug('The email was sent successfully.');
                app.Evidence_Email_Sent__c = true;
                appUpdateList.add(app);
            }else {
                System.debug('The email failed to send: '+results[0].errors[0].message);
            }
        }
        try{
            update appUpdateList;
        }catch(DMLException e){
            System.debug('Error updating Evidence Email Sent on Application '+e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc){}
    
    public void execute(SchedulableContext sc){
        SendEvidenceReminderEmailBatch obj = new SendEvidenceReminderEmailBatch();
        Database.executeBatch(obj);
    }
}