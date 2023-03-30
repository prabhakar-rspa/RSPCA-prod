@isTest
public class WithdrawAccountBatchTest {

    @isTest
    static void UpdateAccountStatusTest(){
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
        site.Date_Suspended_No_Evidence__c = Date.today().addDays(-90);
        insert site;

        Test.startTest();
        WithdrawAccountBatch obj = new WithdrawAccountBatch();
        obj.execute(null);
        Test.stopTest();
    }
}