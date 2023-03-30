@isTest
public class RenewalApplicationReminderTest {
    /*
    @testSetup static void testSetup() {
        Id headOfficeRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Head_Office').getRecordTypeId();
        Id siteRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
        Id applicationsRecordType = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Applications').getRecordTypeId();
        Account headOffice = new Account();
        headOffice.Name = 'head Office';
        headOffice.Status__c = 'Member';
        headOffice.Head_Office_Number__c = '0001';
        headOffice.RecordTypeId = headOfficeRecordType;
        headOffice.Active__c = true;
        headOffice.Company_Industry__c = 'Poultry';
        headOffice.Accounts_Email__c = 'accounts.email@test.com';
        
        insert headOffice;
        
        Account site = new Account();
        site.Name = 'head Office';
        site.Status__c = 'Member';
        site.Site_Number__c = '0001';
        site.RecordTypeId = siteRecordType;
        site.Active__c = true;
        site.Company_Industry__c = 'Poultry';
        
        insert site;
        
        Contact con = new Contact();
        con.FirstName = 'first';
        con.LastName = 'last';
        con.Email = 'test@test.com';
        con.AccountId = site.Id;
        
        insert con;
        
        site.Primary_Contact__c = con.Id;
        update site;
        Profile p = [SELECT Id FROM Profile WHERE Name='Assessors'];
        User u = new User(Alias = 'standt', Email='Assessors@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Assessors432432pquvndddfsd@testorg.com', Assessor__c = true);
        insert u;
        
        Application__c app = new Application__c();
        app.Site__c = site.Id;
        app.Head_Office__c = headOffice.Id;
        app.RecordTypeId = applicationsRecordType;
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__C = 'Certification';
        app.Applicant_Contact__c = con.Id;
        app.Date_Certified__c = Date.today();
        app.Paid__c = true;
        app.Assessment_Approved_By_Assessor__c = u.Id;
        app.Assessment_Approved_By_Certifier__c = u.Id;
        app.Assessment_Approved_By_Office__c = u.Id;
        app.Application_Approved_By_Office__c = u.Id;
        app.Application_Approved_By_Certifier__c = u.Id;
        app.Evidence_Approved_By_Assessor__c = u.Id;
        app.Evidence_Approved_By_Certifier__c = u.Id;
        app.Evidence_Approved_By_Office__c = u.Id;
        app.Approved_for_Renewal__c = true;
        
        insert app;
        
        
        
        site.Membership_Expiry_Date__c = Date.today() +70; // 2 months and 14 days so that renewal is 2 months behind the Membership expiry date
        update site;
        
        
        
    }

    @isTest
    public static void renewalApplicationReminder6Weeks(){
        Test.startTest();        
        List<Application__c> apps = [SELECT Id, Site__c, Site__r.Status__c, Applicant_Contact__c, Membership_Expiry_Date__c, Stage__c, Renewal_Stage__c, Date_Certified__c FROM Application__c];
        RenewalApplicationReminder6Weeks job = new RenewalApplicationReminder6Weeks();
        job.execute(null);
        Test.stopTest();
    }
    @isTest
    public static void renewalApplicationReminder2Weeks(){
        Test.startTest();        
        List<Application__c> apps = [SELECT Id, Site__c, Site__r.Status__c, Applicant_Contact__c, Membership_Expiry_Date__c, Stage__c, Renewal_Stage__c, Date_Certified__c FROM Application__c];
        RenewalApplicationReminder2Weeks job = new RenewalApplicationReminder2Weeks();
        job.execute(null);
        Test.stopTest();
    }*/
}