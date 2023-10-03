@isTest
public class ApplicationTriggerHandlerTest {
	
    @isTest
    static Application__c createApplication(){
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

        // Create Application
        FObject application = DataFactory.getDefNewApplications();
        application.setDefinition('Existing_Member__c', 'static value(No)');
        application.insertRecords(true);

        // do assertions
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        List<Contact> insertedCon = FObject.getInsertedRecords('Contact');
        List<Application__c> insertedApp = FObject.getInsertedRecords('Application__c');
        System.debug('Acc Size => ' + insertedAccounts.size());
        System.debug('Con Size => ' + insertedCon.size());
        System.debug('App Size => ' + insertedApp.size());
        System.assert(insertedAccounts.size() == 2);
        System.assert(insertedCon.size() == 1);
        System.assert(insertedApp.size() == 1);
        return insertedApp[0];
    }

    @isTest
    static void createRenewalApplication(){
        // Create lateRenewalFee product
        FObject lateRenewalFee = new FObject('Product2', 1);
        lateRenewalFee.setDefinition('Name','static value(Late Renewal Fee)');
        lateRenewalFee.setDefinition('ProductCode','static value(LATEFEE)');
        lateRenewalFee.setDefinition('IsActive','static value(true)');
        lateRenewalFee.setDefinition('Standard_Price__c','static value(30)');
        lateRenewalFee.insertRecords(true);

        // Create renewal Application
        FObject application = DataFactory.getDefRenewalApplications();
        //application.setDefinition('Existing_Member__c', 'static value(No)');
        application.insertRecords(true);

        // do assertions
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        List<Contact> insertedCon = FObject.getInsertedRecords('Contact');
        List<Application__c> insertedApp = FObject.getInsertedRecords('Application__c');
        System.debug('Acc Size => ' + insertedAccounts.size());
        System.debug('Con Size => ' + insertedCon.size());
        System.debug('App Size => ' + insertedApp.size());
        System.assert(insertedAccounts.size() == 2);
        System.assert(insertedCon.size() == 1);
        System.assert(insertedApp.size() == 1);

        for(Account a : insertedAccounts){
            a.Membership_Expiry_Date__c = Date.today();
        }
        update insertedAccounts;

        Application__c clonedRenewal = insertedApp[0].clone(false,false,false,false);
        clonedRenewal.Id = null;
        insert clonedRenewal;


    }

    @isTest
    static void sendApplicationConfirmationEmail(){
        Application__c app = createApplication();
        app.Send_Application_Confirmation_Email__c = true;
        update app;
    }

    @isTest
    static void applicationWithBulkRenewal(){
        // create bulk renewal object
        FObject bulkRenewal = new FObject('Bulk_Renewal__c', 1);

        // Create Application
        FObject renewalApplication = DataFactory.getDefRenewalApplications();
        renewalApplication.setDefinition('Existing_Member__c', 'static value(Yes)');
        renewalApplication.setDefinition('Bulk_Renewal__c', 'random lookup(Bulk_Renewal__c) source(forceea)');
        renewalApplication.insertRecords(true);

    }
    @isTest
    static void testMethod1(){
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
        system.assert(app.Sage_Invoice__c != null);
        system.assert(app.InvoiceSent__c);
    }
    @isTest
    static void testMethod2(){
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
        
        
        Product2 product1 = TestDataFactory.createProduct(false);
        product1.ProductCode = 'REVISIT';
        insert product1;
        PricebookEntry pbe = TestDataFactory.createPriceBookEntry(product1.Id,Test.getStandardPricebookId(),true);
        Unit__c unit = TestDataFactory.createUnit(act.Id,true);
        /*Application__c app = TestDataFactory.createApplication(recordTypeId, act.Id, act.Id, cnt.Id, false); 
        app.Pricebook_Id__c =  Test.getStandardPricebookId();
        app.Payment_Due_Date__c = system.today();
        app.Invoice_Date__c = system.today();
        insert app;*/
        Application__c app1 = TestDataFactory.createApplication(recordTypeId, act.Id, site.Id, cnt.Id, false); 
        app1.Pricebook_Id__c =  Test.getStandardPricebookId();
        app1.Bulk_Renewal__c = bulk_renewal.Id;
        app1.Existing_Member__c = 'Yes';
        app1.Application_Type__c = 'Update';
        insert app1;
        TestDataFactory.createApplicationLineItem(product1.Id,app1.Id,true);
        
        
    }
    /*
    @isTest(SeeAllData = true)
    static void sendExtensionGrantedEmail(){
        Application__c app = createApplication();
        app.Extension_Granted__c = 'Yes';
        app.Extension_Period__c = '3 Weeks';
        app.Extension_Granted_On__c = Date.today();
        app.Extension_Deadline__c = Date.today();
        app.Reason_for_extension__c = 'test reason';
        update app;
    }*/
    /*
    @isTest(SeeAllData = true)
    static void sendAssessmentCompleteEmail(){
        Application__c app = createApplication();
        app.Stage__c = 'Assessment';
        app.Paid__c = true;
        app.Assessment_Checklist__c = 'Test link';
        app.Assessment_Report__c = 'Test link';
        update app;

        app.Stage__c = 'Compliance';
        update app;
    }
    */
}