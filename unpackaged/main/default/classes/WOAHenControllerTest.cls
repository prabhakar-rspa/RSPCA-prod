@isTest
public class WOAHenControllerTest {
@testSetup
    static void loadData(){
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
        
        Application__c app = insertedApp[0];
        app.Send_Application_Confirmation_Email__c = true;
        update app;
        List<WOA__c> woaList = new List<WOA__c>{
            new WOA__c(Application__c=app.Id,Species_Type__c='Laying Hen')
        };
        insert woaList;
        WOAHens__c woaHens = new WOAHens__c(WOA__c = woaList[0].Id);
        insert woaHens;
    }
    @isTest
    static void testMethod1(){
        WOAHens__c woaHens = [SELECT ID,WOA__C,Comments__c FROM WOAHens__c LIMIT 1];
        woaHens = WOAHenController.getWOAHens(woaHens.WOA__c);
        system.Assert(String.isBlank(woaHens.Comments__c));
        woaHens.Comments__c = 'xxxxx';
        WOAHenController.saveWOAHens(woaHens);
        woaHens = [SELECT ID,WOA__C,Comments__c FROM WOAHens__c LIMIT 1];
        system.Assert(String.isNotBlank(woaHens.Comments__c));

    }
}