@isTest
public class CreateCreditNoteControllerTest {

    /*@testSetup static void setup() {
       // Create joinFee product
       FObject joinFee = new FObject('Product2', 1);
       joinFee.setDefinition('Name','static value(Joining Fee)');
       joinFee.setDefinition('ProductCode','static value(JOINFEE)');
       joinFee.setDefinition('IsActive','static value(true)');
       joinFee.setDefinition('Standard_Price__c','static value(28.80)');
       joinFee.insertRecords(true);
       
       // Create revisitFee product
       FObject revisitFee = new FObject('Product2', 1);
       revisitFee.setDefinition('Name','static value(Revisit)');
       revisitFee.setDefinition('ProductCode','static value(REVISIT)');
       revisitFee.setDefinition('IsActive','static value(true)');
       revisitFee.setDefinition('Standard_Price__c','static value(114.24)');
       revisitFee.insertRecords(true);
        Product2 pro = [SELECT ID FROM PRODUCT2 LIMIT 1];
		Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.AccountId = act.Id;
        insert opp;
        
        
       // Create Application
       FObject application = DataFactory.getDefNewApplications();
       application.setDefinition('Existing_Member__c', 'static value(No)');
       application.insertRecords(true);
    }
    

    @isTest
    static void getApplication(){
        // get application record
        List<Application__c> appList = [SELECT Id FROM Application__c];

        // run controller method
        Test.startTest();
        CreateCreditNoteController.getApplication(appList[0].Id);
        Test.stopTest();
    }

    @isTest
    static void getCreditLines(){
        // get application record
        List<Application__c> appList = [SELECT Id FROM Application__c];
        List<Application_Line_Item__c> appLineItems = [SELECT Id, Application__c, Product_Name__c, Quantity__c,List_Price__c, List_Price_Inc_Vat__c, Subtotal__c FROM Application_Line_Item__c];
        List<String> appLineIds = new List<String>();
        for(Application_Line_Item__c ali : appLineItems){
            appLineIds.add(ali.Id);
        }

        // run controller method
        Test.startTest();
        CreateCreditNoteController.getCreditLines(appLineIds);
        Test.stopTest();
    }
    
    @isTest
    static void createCreditNote(){
        // get application record
        List<Application__c> appList = [SELECT Id, Site_Name__c, Application_Type__c,Pricebook_Id__c, Applicant_Contact__c, Head_Office__c, Head_Office__r.BillingCountry FROM Application__c];
        List<Application_Line_Item__c> appLineItems = [SELECT Id, Application__c, Product_Name__c, Quantity__c,List_Price__c, List_Price_Inc_Vat__c, Subtotal__c FROM Application_Line_Item__c];
        List<String> appLineIds = new List<String>();
        for(Application_Line_Item__c ali : appLineItems){
            appLineIds.add(ali.Id);
        }

        // Get credit note line wrapper
        List<CreateCreditNoteController.CreditNoteLineWrapper> creditNoteLinesWrapper = CreateCreditNoteController.getCreditLines(appLineIds);

        // run controller method
        Test.startTest();
        CreateCreditNoteController.createCreditNote(appList[0], creditNoteLinesWrapper, 'Cancellation', 'ponumber', 'orderdetails');
        Test.stopTest();
    }*/
    @isTest
    static void getInvoiceTest(){
        Account act = TestDataFactory.createHeadOfficeAccount();
        Contact cnt = TestDataFactory.createContact(act.Id);
        cnt.Roles__c = 'Invoice Contact';
        update cnt;
        act.Primary_Contact__c = cnt.Id;
        update act;
        Account site = TestDataFactory.createSiteAccount(act.Id);
        site.Needs_an_Assessment__c = true;
        update site;
        Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        Bulk_Renewal__c  bulk_renewal = TestDataFactory.createBulkRenewal(cnt.Id,act.Id,true);
        
        Product2 product = TestDataFactory.createProduct(false);
        product.ProductCode = 'JOINFEE';
        insert product;
        PricebookEntry pbe = TestDataFactory.createPriceBookEntry(product.Id,Test.getStandardPricebookId(),true);
        Unit__c unit = TestDataFactory.createUnit(act.Id,true);
        Application__c app = TestDataFactory.createApplication(recordTypeId, act.Id, act.Id, cnt.Id, false); 
        app.Pricebook_Id__c =  Test.getStandardPricebookId();
        app.Payment_Due_Date__c = system.today();
        app.Invoice_Date__c = system.today();
        insert app;
        Application__c app1 = TestDataFactory.createApplication(recordTypeId, act.Id, site.Id, cnt.Id, false); 
        app1.Pricebook_Id__c =  Test.getStandardPricebookId();
        app1.Bulk_Renewal__c = bulk_renewal.Id;
        insert app1;
        TestDataFactory.createApplicationLineItem(product.Id,app.Id,true);
        Test.startTest();
        app.Send_Invoice__c = true;
        update app;
        Test.stopTest();
        app = [SELECT Id,Sage_Invoice__c,InvoiceSent__c FROM Application__c WHERE Id=:app.Id];
        CreateCreditNoteController.getInvoice(app.Sage_Invoice__c);
        List<String> oppLineIds = new List<String>();
        List<OpportunityLineItem> oppLines = CreateCreditNoteController.getInvoiceLineItems(app.Sage_Invoice__c);
        for(OpportunityLineItem oppLine:oppLines){
            oppLineIds.add(oppLine.Id);
        }
        CreateCreditNoteController.createCreditNote(CreateCreditNoteController.getApplication(app.Id),CreateCreditNoteController.getCreditLines(oppLineIds), 'Cancellation', 'ponumber', 'orderdetails');
    }
}