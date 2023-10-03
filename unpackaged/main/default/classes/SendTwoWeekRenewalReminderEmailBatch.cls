/*
 * Name: Prabhakar
 * Description:Send renewal reminder email 1 month before the Membership Expiry date
 * History :  Removed date from the email subject and added membership expiry date in the subject
*/
public class SendTwoWeekRenewalReminderEmailBatch implements Database.Batchable<sObject>, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc){
        //if(UserInfo.getUserEmail() == 'help@rspcaassured.org.uk'){
            Date reminderDate = Date.today();
            x2WeekRenewalReminderTestDate__c testDateSetting = x2WeekRenewalReminderTestDate__c.getOrgDefaults();
            if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Date__c != null){
                reminderDate = testDateSetting.Test_Date__c;
            }
            List<Account> siteList = [SELECT Id,Name,
                                            Status__c,
                                            Primary_Contact__c,
                                            Primary_Contact__r.Email,
                                            Renewal_Date__c,
                                            Membership_Expiry_Date__c,
                                            Final_Renewal_Reminder_Sent__c,
                                            ParentId 
                                            FROM Account
                                            WHERE
                                            Status__c = 'MEMBER'
                                            AND
                                            X2_Week_Renewal_Scheduled_Date__c =:reminderDate
                                            AND 
                                            Final_Renewal_Reminder_Sent__c  = null
                                            AND RecordType.DeveloperName = 'Site'
                                            AND ParentId != null
                                            AND Active__c = true
                                            AND Renewal_Reminder_Ready__c = true
                                     ];
            Set<Id> headOfcIdSet = new Set<Id>();
            for(Account acc : siteList){
                if(acc.ParentId != null){
                    headOfcIdSet.add(acc.ParentId);
                }
            }
            return Database.getQueryLocator('SELECT Id,Name, Primary_Contact__c, Primary_Contact__r.Email FROM Account WHERE Id IN: headOfcIdSet AND Primary_Contact__r.Email != null');
        /*}else{
            return null;
        }*/
        
    }

    public void execute(Database.BatchableContext bc, List<Account> actList){
        x2WeekRenewalReminderTestDate__c testDateSetting = x2WeekRenewalReminderTestDate__c.getOrgDefaults();
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE DeveloperName = 'RenewalReminderTwoWeek'];
        Set<String> headOfficeRemindersSent = new Set<String>();
        Map<String,Date> membershipDateMap = getMembershipExpiryDate(actList);
        for(Account act : actList){
            String contactId = act.Primary_Contact__c;
            if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Contact_Id__c != null){
                contactId = testDateSetting.Test_Contact_Id__c;
            }
            PageReference reportPage = new PageReference('/apex/MembershipPrices');
            reportPage.getParameters().put('id', act.Id);
            Blob reportPdf;
            try {
                system.debug('reportPage:::'+reportPage);
                reportPdf = reportPage.getContentAsPDF();
            }
            catch (Exception e) {
                system.debug('going catch:::'+e);
                reportPdf = Blob.valueOf(e.getMessage());
            }
            ContentVersion cv = new ContentVersion();
            cv.VersionData = reportPdf;
            cv.Title = 'MembershipPrices';
            cv.PathOnClient = 'MembershipPrices.pdf';
            cv.Description = act.Name;
            cv.isMajorVersion = true;
            insert cv;
            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, contactId, act.Id);
            if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Contact_Id__c != null){
                message.setSaveAsActivity(false);
            }else {
                message.setSaveAsActivity(true);
            }
			message.setEntityAttachments(new list<Id> {cv.Id});
            message.setSenderDisplayName('RSPCA Assured'); 
            message.setReplyTo('help@rspcaassured.org.uk');
            message.setUseSignature(false); 
            message.setBccSender(false); 

            message.setSubject('Renewal Reminder');
            /*if(membershipDateMap.containsKey(act.Id)){
                Date membershipDate = membershipDateMap.get(act.Id);
                String dateStr =  membershipDate.day()+ '/'+membershipDate.month() + '/'+membershipDate.year() ;
                message.setSubject('Renewal Reminder - '+dateStr);
            }*/
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
         // Update site sent checkbox
         if(testDateSetting.Use_Test_Date_Data__c == false){
            List<Account> sites = [SELECT Id, Six_Week_Renewal_Reminder_Sent__c, Final_Renewal_Reminder_Sent__c FROM Account WHERE Status__c = 'MEMBER'
            AND
            X2_Week_Renewal_Scheduled_Date__c =:Date.today()
            AND 
            Final_Renewal_Reminder_Sent__c  = null
            AND RecordType.DeveloperName = 'Site'
            AND ParentId IN:headOfficeRemindersSent
            AND Active__c = true
            AND Renewal_Reminder_Ready__c = true];
            for(Account a : sites){
                a.Final_Renewal_Reminder_Sent__c = Date.today();
            }
            update sites;
        }
    }
    public static Map<String,Date> getMembershipExpiryDate(List<Account> accountList){
        Map<String,Date> membershipExpiryDate = new Map<String,Date>();
        Date reminderDate = Date.today();
        x2WeekRenewalReminderTestDate__c testDateSetting = x2WeekRenewalReminderTestDate__c.getOrgDefaults();
        if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Date__c != null){
            reminderDate = testDateSetting.Test_Date__c;
        }
        Set<String> siteIds = new Set<String>();
        List<Renewal_Price_Report__c> renewalSites = [SELECT Id,Site__r.ParentId, Site__c,Site__r.Membership_Expiry_Date__c FROM Renewal_Price_Report__c 
                                                            WHERE Site__r.Renewal_Reminder_Ready__c = true 
                                                            AND Site__r.ParentId IN:accountList 
                                                            AND Site__r.Status__c ='Member'];
        for(Renewal_Price_Report__c rpr : renewalSites){
            membershipExpiryDate.put(rpr.Site__r.ParentId,rpr.Site__r.Membership_Expiry_Date__c);
        }
        
        return membershipExpiryDate;
    }
    public void finish(Database.BatchableContext bc){}
    
    public void execute(SchedulableContext sc){
        SendTwoWeekRenewalReminderEmailBatch obj = new SendTwoWeekRenewalReminderEmailBatch();
        Database.executeBatch(obj, 1);
    }
}