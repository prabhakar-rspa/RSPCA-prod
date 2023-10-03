@isTest
public class RenewalReminderSixWeeksEmailBatchTest {
    @testSetup
    static void loadData(){
        
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Assess_Con_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Comm_In_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Renewal_Invite_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_FRReminder_png');
        TestDataFactory.createDocument('EvidenceReminder');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Final_Payment_Reminder_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Payment_Reminder_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Your_Certificates_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Invoice_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Lapsed_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Cancelled_Not_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Payment_Confirmation_png');
        TestDataFactory.createDocument('RSPCA_Assured_Email_Header_EG_png');
        TestDataFactory.createDocument('FinalEvidenceReminder');
    }
    @isTest
    static void SendSixWeekRenewEmailTest(){
        
        Id profileId=userinfo.getProfileId(); 
        User u = new User(Alias = 'standt', Email='help@rspcaassured.org.uk', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = profileId, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2'+ DateTime.now().millisecond() +'@testorg.com');
        insert u;
        
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;
        
        Contact cnt = new Contact();
        cnt.AccountId = act.Id;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;
        
        act.Primary_Contact__c = cnt.Id;
        update act;
        
        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Company_Industry__c = 'Fish';
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(14);
        site.Status__c = 'Member';
        insert site;
        Renewal_Price_Report__c report = new Renewal_Price_Report__c();
        report.Site__c = site.Id;
        report.Membership_Expiry_Date__c = Date.today().addDays(14);
        insert report;
        Renewal_Price_Line__c line = new Renewal_Price_Line__c();
        line.Renewal_Price_Report__c = report.Id;
        line.Total_Inc_VAT__c = 100;
        insert line;
        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        insert app;
        Account acc = [SELECT Id,Name,X6_Week_Renewal_Scheduled_Date__c,Renewal_Reminder_Ready__c FROM Account WHERE Id=:site.Id limit 1];
        system.debug('acc:::'+acc);
        x6WeekRenewalReminderTestDate__c testDate = new x6WeekRenewalReminderTestDate__c(Name='Test');
        testDate.Use_Test_Date_Data__c = true;
        testDate.Test_Date__c = acc.X6_Week_Renewal_Scheduled_Date__c;
        insert testDate;
        
        System.runAs(u){
        Test.startTest();
        
        RenewalReminderSixWeeksEmailBatch obj = new RenewalReminderSixWeeksEmailBatch();
        obj.execute(null);   
        
        Test.stopTest();
        }
    }
}