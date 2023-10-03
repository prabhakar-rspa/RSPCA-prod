@isTest
public class SendInvoiceControllerTest {
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
        app.Payment_Due_Date__c = system.today();
        app.Invoice_Date__c = system.today();
        insert app;
        Application__c app1 = TestDataFactory.createApplication(recordTypeId, act.Id, act.Id, cnt.Id, false); 
        app1.Pricebook_Id__c =  Test.getStandardPricebookId();
        app1.Bulk_Renewal__c = bulk_renewal.Id;
        insert app1;
        Product2 product = TestDataFactory.createProduct(true);
        TestDataFactory.createPriceBookEntry(product.Id,Test.getStandardPricebookId(),true);
        Unit__c unit = TestDataFactory.createUnit(act.Id,true);
        TestDataFactory.createApplicationLineItem(product.Id,app.Id,true);
    }
    @isTest
    static void testMethod1(){
        Application__c app = [SELECT Id,Name FROM Application__c WHERE Bulk_Renewal__c =NULL LIMIT 1];
        String contacts = SendInvoiceController.getContacts(app.Id);
        List<contact> contactList = (List<contact>)JSON.deserialize(contacts,List<contact>.class);
        system.assert(contactList.size()>0);
        Test.startTest();
        SendInvoiceController.updateApplication(app.Id, 'Test message');
        SendInvoiceController.sendMultipleInvoices(new List<Id>{contactList[0].Id}, 'Test message', app.Id);
        Test.stopTest();
        app = [SELECT Id,Sage_Invoice__c,InvoiceSent__c FROM Application__c WHERE Id=:app.Id];
        system.assert(app.Sage_Invoice__c != null);
        system.assert(app.InvoiceSent__c);
        SendInvoiceController.updateApplication( app.Id,'Test message');
    }
}