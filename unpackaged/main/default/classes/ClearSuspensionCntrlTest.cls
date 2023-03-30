@isTest
public class ClearSuspensionCntrlTest {
    /*
    @isTest
    static void createSuspensionHistoryTest(){
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
        site.Request_for_Suspension__c = true;
        site.Reason_For_Suspension_Picklist__c = 'Other';
        site.Reason_for_Suspension__c = 'Test Reason';
        site.Approved__c = 'Yes';
        site.Further_Information__c = 'test info';
        site.Outcome__c = 'Withdraw';
        insert site;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(site);
        ClearSuspensionCntrl cs = new ClearSuspensionCntrl(sc);
        cs.createSuspensionHistory();
		Test.stopTest();
    }
    */
}