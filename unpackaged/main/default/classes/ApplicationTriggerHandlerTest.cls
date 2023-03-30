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