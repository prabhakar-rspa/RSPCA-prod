@isTest
public class InvoicePDFControllerTest { 
	@testSetup
    static void loadData(){
        Account act = TestDataFactory.createHeadOfficeAccount();
        act.Membership_Expiry_Date__c = system.today();
        update act;
        Contact cnt = TestDataFactory.createContact(act.Id);
        cnt.Roles__c = 'Invoice Contact';
        update cnt;
        act.Primary_Contact__c = cnt.Id;
        update act;
        Account site = TestDataFactory.createSiteAccount(act.Id);
        Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Application__c app = TestDataFactory.createApplication(recordTypeId, act.Id, act.Id, cnt.Id, false); 
        app.Application_Type__c = 'Renewal';
        app.Existing_Member__c = 'Yes';
        insert app;
        Product2 product = TestDataFactory.createProduct(true);
        TestDataFactory.createPriceBookEntry(product.Id,Test.getStandardPricebookId(),true);
        TestDataFactory.createApplicationLineItem(product.Id,app.Id,true);
    }
    @isTest
    static void testMethod1(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        ApexPages.currentPage().getParameters().put('id',app.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(app);
        InvoicePDFController brCntrlStnd = new InvoicePDFController(controller);
        system.Assert(brCntrlStnd.startDate == system.today());
        system.Assert(brCntrlStnd.endDate == brCntrlStnd.startDate.addMonths(12));
    }
}