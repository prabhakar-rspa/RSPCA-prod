global class RenewalApplicationReminder6Weeks implements Database.Batchable<sObject>, Schedulable {
	global Database.QueryLocator start(Database.BatchableContext BC) {
        Date reminderDate = Date.today();
        x6WeekRenewalReminderTestDate__c testDateSetting = x6WeekRenewalReminderTestDate__c.getOrgDefaults();
        if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Date__c != null){
            reminderDate = testDateSetting.Test_Date__c;
        }
        return Database.getQueryLocator([SELECT Id,
                                        		Status__c,
                                        		Primary_Contact__c,
                                         		Primary_Contact__r.Email,
                                                Membership_Expiry_Date__c,
                                                Renewal_Date__c,
                                         		Six_Week_Renewal_Reminder_Sent__c 
                                         		FROM Account
                                        		WHERE
                                        		Status__c = 'MEMBER'
                                        		AND
                                        		X6_Week_Renewal_Scheduled_Date__c =:reminderDate
                                        		AND 
                                         		Six_Week_Renewal_Reminder_Sent__c = null
                                        		AND 
                                        		Primary_Contact__r.Email != null
                                                AND RecordType.DeveloperName = 'Site']);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        EmailTemplate template = [SELECT Id, Subject, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName ='NewRenewalReminder6WeekWithFees'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help@rspcaassured.org.uk'];
        try {
            for (Account acc : scope){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(acc.Primary_Contact__c);
                message.setReplyTo('help@rspcaassured.org.uk');
                message.setOrgWideEmailAddressId(owea.get(0).Id);
                message.setUseSignature(false);
                message.setBccSender(false);
                message.setSaveAsActivity(true);
                message.setTemplateID(template.Id);
                message.setWhatId(acc.Id); //This is important for the merge fields in template to work
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
    
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].isSuccess()) {
                    System.debug('The email was sent successfully.');
                    acc.Six_Week_Renewal_Reminder_Sent__c = Date.today();
                    Renewal_Reminder_Log__c log = new Renewal_Reminder_Log__c(
                        Status__C = 'Success',
                        Target_Object_Id__c = acc.Id,
                        Reminder_Name__c = 'Six Week Renewal Reminder'
                    );
                    insert log;
    
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    Object sc = (Object)results.get(0).getErrors()[0].getStatusCode();
                    Renewal_Reminder_Log__c log = new Renewal_Reminder_Log__c(Status__C = 'Error', Target_Object_Id__c = results.get(0).getErrors()[0].getTargetObjectId(), Error_Message__c = results.get(0).getErrors()[0].getMessage(), Fields__c = results.get(0).getErrors()[0].getFields().toString(), Status_Code__c = sc.toString(), Reminder_Name__c = 'Six Week Renewal Reminder');
                    insert log;
                }
            }
            update scope;
        } catch (Exception e) {
            System.debug(e);
            Renewal_Reminder_Log__c log = new Renewal_Reminder_Log__c(Status__C = 'Error', Error_Message__c = e.getMessage(), Reminder_Name__c = 'Six Week Renewal Reminder');
            insert log;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext ctx) {
		Id batchInstanceId = Database.executeBatch(new RenewalApplicationReminder6Weeks(), 1);
    }
}