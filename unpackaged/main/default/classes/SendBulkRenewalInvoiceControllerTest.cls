@isTest
public class SendBulkRenewalInvoiceControllerTest {
@testSetup
    static void loadData(){
        Account act = TestDataFactory.createHeadOfficeAccount();
        Contact cnt = TestDataFactory.createContact(act.Id);
        cnt.Roles__c = 'Invoice Contact';
        update cnt;
        act.Primary_Contact__c = cnt.Id;
        update act;
        Account site = TestDataFactory.createSiteAccount(act.Id);
        Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        Bulk_Renewal__c  bulk_renewal = TestDataFactory.createBulkRenewal(cnt.Id,act.Id,true);
        Application__c app = TestDataFactory.createApplication(recordTypeId, act.Id, act.Id, cnt.Id, false); 
        app.Pricebook_Id__c =  Test.getStandardPricebookId();
        app.Bulk_Renewal__c = bulk_renewal.Id;
        insert app;
        Product2 product = TestDataFactory.createProduct(true);
        TestDataFactory.createPriceBookEntry(product.Id,Test.getStandardPricebookId(),true);
        Unit__c unit = TestDataFactory.createUnit(act.Id,true);
        TestDataFactory.createApplicationLineItem(product.Id,app.Id,true);
    }
    @isTest
    static void testMethod1(){
        Bulk_Renewal__c  bulk_renewal = [SELECT Id FROM Bulk_Renewal__c LIMIT 1];
        String contacts = SendBulkRenewalInvoiceController.getContacts(bulk_renewal.Id);
        List<contact> contactList = (List<contact>)JSON.deserialize(contacts,List<contact>.class);
        system.assert(contactList.size()>0);
        Test.startTest();
        SendBulkRenewalInvoiceController.createInvoice(bulk_renewal.Id);
        SendBulkRenewalInvoiceController.sendMultipleInvoices(new List<Id>{contactList[0].Id}, 'Test message', bulk_renewal.Id);
        Test.stopTest();
        bulk_renewal = [SELECT Id,Sage_Invoice__c,Invoice_Email_Sent__c FROM Bulk_Renewal__c WHERE Id=:bulk_renewal.Id];
        system.assert(bulk_renewal.Sage_Invoice__c != null);
        system.assert(bulk_renewal.Invoice_Email_Sent__c);

    }
}