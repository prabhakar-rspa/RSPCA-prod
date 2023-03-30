@isTest
public class SendPaymentConfirmationEmailBatchTest {
    /*
    @isTest(SeeAllData=true)
    static void SendPaymentConfirmEmailTest(){
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
        insert site;

        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        app.Paid__c = true;
        app.Payment_Confirmation_Sent__c = false;
        insert app;

        System.debug('app '+app);
        List<Application__c> appList = [SELECT Id, Name, Head_Office__c FROM Application__c WHERE (Stage__c = 'Application' OR Renewal_Stage__c = 'Renewal') AND (RecordType.Name = 'Applications' OR RecordType.Name = 'Renewal') AND Paid__c = true AND Payment_Confirmation_Sent__c != true];
        System.debug('appList '+appList);

        Test.startTest();
        SendPaymentConfirmationEmailBatch obj = new SendPaymentConfirmationEmailBatch();
        obj.execute(null);
        Test.stopTest();
    }
    */
}