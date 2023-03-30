global class WeeklyNotificationSchedule implements Database.Batchable<sObject>, Schedulable, Database.stateful{
    private static Set<String> emailTemplateNames = new Set<String>{
        'Weekly_Summary_Assessor'
    };
    // Query all email templates from the email template names set
    private static List<EmailTemplate> emailTemplateList = [SELECT Id,DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName IN :emailTemplateNames];
    
    // Query the org wide email address
    private static OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help@rspcaassured.org.uk'];

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, IsActive, Email, Assessor__c FROM User WHERE IsActive = true AND Assessor__c = true]);
    }
    global void execute(Database.BatchableContext BC, List<User> scope) {
        // Create email template variables for each email template
        EmailTemplate weeklyNotificationAssessors = new EmailTemplate();

        // iterate through the list of email templates and assign to the email template variables
        for(EmailTemplate et : emailTemplateList){
            if(et.DeveloperName == 'Weekly_Summary_Assessor'){
                weeklyNotificationAssessors = et;
            }
        }
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for(User u : scope){       
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(u.Id);
            message.setReplyTo('help@rspcaassured.org.uk');
            message.setOrgWideEmailAddressId(owea.get(0).Id);
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(weeklyNotificationAssessors.Id);
            message.setWhatId(u.Id); //This is important for the merge fields in template to work

            messages.add(message);
        }
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        for(Messaging.SendEmailResult result : results){
            if (result.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }

    global void execute(SchedulableContext ctx) {
        Id batchInstanceId = Database.executeBatch(new WeeklyNotificationSchedule(), 10);
    }
}