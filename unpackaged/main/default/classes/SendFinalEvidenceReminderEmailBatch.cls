public class SendFinalEvidenceReminderEmailBatch implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc){
        Date before21Days = system.today().addDays(-21);
        /*List<Application__c> evdAppList = [
            SELECT Id, Name FROM Application__c 
            WHERE  Applicant_Contact__r.Email != null AND Evidence_Deadline__c != null 
            AND Extension_Deadline__c = null AND Final_Evidence_Email_Sent__c = false 
            AND Evidence_Reminder_Date__c =:Date.today()
        ];
        Set<Id> appIdSet = new Set<Id>();
        for(Application__c app : evdAppList){
            appIdSet.add(app.Id);
        }*/
        String query = 'SELECT Id,RecordType.DeveloperName, Membership_Number__c,Head_Office__c, Head_Office__r.Primary_Contact__c,Head_Office__r.Primary_Contact__r.Email, Final_Evidence_Email_Sent__c,Assessment_Date__c FROM Application__c WHERE Head_Office__r.Primary_Contact__r.Email != null AND Assessment_Date__c = :before21Days AND Final_Evidence_Email_Sent__c = false AND Evidence__c = NULL';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Application__c> appList){
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help@rspcaassured.org.uk'];
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'Evidence Reminder'];
        EmailTemplate additionalVisitEmailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'Evidence Reminder for Additional Visits'];
        List<Application__c> appUpdateList = new List<Application__c>();
        for(Application__c app : appList){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(app.Head_Office__r.Primary_Contact__c); 
            //message.setSenderDisplayName('RSPCA Assured'); 
            message.setReplyTo('help@rspcaassured.org.uk');
            message.setOrgWideEmailAddressId(owea.get(0).Id);
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(true);
            if(app.RecordType.DeveloperName == 'Additional_Visit'){
            	message.setTemplateID(additionalVisitEmailTemplate.Id); 
            }else{
            	message.setTemplateID(emailTemplate.Id); 
            }
            message.setWhatId(app.Id);
            message.toAddresses = new String[] {app.Head_Office__r.Primary_Contact__r.Email};//
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success){
                System.debug('The email was sent successfully.');
                app.Final_Evidence_Email_Sent__c = true;
                appUpdateList.add(app);
            }else {
                System.debug('The email failed to send: '+results[0].errors[0].message);
            }
        }
        try{
            update appUpdateList;
        }catch(DMLException e){
            System.debug('Error updating Final Evidence Email Sent on Application '+e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc){}
    
    public void execute(SchedulableContext sc){
        SendFinalEvidenceReminderEmailBatch obj = new SendFinalEvidenceReminderEmailBatch();
        Database.executeBatch(obj);
    }
}