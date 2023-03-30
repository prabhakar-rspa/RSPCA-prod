@isTest
public class SuspendAccountBatchTest {

    @isTest
    static void AccountStatusUpdateTest(){
        Account headOfc = new Account();
        headOfc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        headOfc.Name = 'Test Head Office';
        headOfc.Status__c = 'ENQUIRY';
        insert headOfc;
        
        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = headOfc.Id;
        site.Company_Industry__c = 'Fish';
        site.Status__c = 'ENQUIRY';
        insert site;

        Account site1 = new Account();
        site1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site1.Name = 'Test Site1';
        site1.ParentId = headOfc.Id;
        site1.Company_Industry__c = 'Fish';
        site1.Status__c = 'ENQUIRY';
        insert site1;

        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Head_Office__c = headOfc.Id;
        app.Site__c = site.Id;
        app.Evidence_Deadline__c = Date.today().addDays(-1);
        insert app;

        Application__c app1 = new Application__c();
        app1.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app1.Existing_Member__c = 'No';
        app1.Application_Type__c = 'New';
        app1.Head_Office__c = headOfc.Id;
        app1.Site__c = site1.Id;
        app1.Extension_Deadline__c = Date.today().addDays(-1);
        insert app1;

        Test.startTest();
        SuspendAccountBatch obj = new SuspendAccountBatch();
        obj.execute(null);
        Test.stopTest();
    }
}