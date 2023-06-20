@isTest
public class SendTwoWeekRenewalReminderEmailBatchTest {
    
    @isTest
    static void SendTwoWeekRenewEmailTest(){
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
        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        insert app;
        Account acc = [SELECT Id,Name,X2_Week_Renewal_Scheduled_Date__c FROM Account WHERE Id=:site.Id limit 1];
        system.debug('acc:::'+acc);
        system.debug('acc:::'+acc.X2_Week_Renewal_Scheduled_Date__c);
        x2WeekRenewalReminderTestDate__c testDate = new x2WeekRenewalReminderTestDate__c(Name='Test');
        testDate.Use_Test_Date_Data__c = true;
        testDate.Test_Date__c = acc.X2_Week_Renewal_Scheduled_Date__c;
        insert testDate;
        Test.startTest();
        
        
        SendTwoWeekRenewalReminderEmailBatch obj = new SendTwoWeekRenewalReminderEmailBatch();
        obj.execute(null);
        
        Test.stopTest();
    }
    
}