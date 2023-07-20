@isTest
public class BatchToUpdateLamenessPrevalenceTest {
	@testSetup
    static void loadData(){
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
            new WOA__c(Application__c=app.Id,Species_Type__c='Dairy Cattle')
        };
        insert woaList;
        WOADairy__c woaDairy = new WOADairy__c(WOA__c = woaList[0].Id);
        insert woaDairy;
        List<Lameness_Prevalence__c> lamenessPrevalence = new List<Lameness_Prevalence__c>{
            new Lameness_Prevalence__c(WOADairy__c =woaDairy.Id ,Percentage_Of_Score_2_cows__c=1, Percentage_Of_Score_3_cows__c=1),
                new Lameness_Prevalence__c(WOADairy__c =woaDairy.Id ,Percentage_Of_Score_2_cows__c=2, Percentage_Of_Score_3_cows__c=2),
                                new Lameness_Prevalence__c(WOADairy__c =woaDairy.Id )

        };
        insert lamenessPrevalence;
    }
    @isTest
    static void testMethod1(){
        Test.startTest();
        Database.executeBatch(new BatchToUpdateLamenessPrevalenceScore());
        Test.stopTest();
        List<WOADairy__c> woaDairys = [SELECT ID, Average_Percentage_Of_Score_2_cows__c, Average_Percentage_Of_Score_3_cows__c FROM WOADairy__c];
        system.assert(woaDairys[0].Average_Percentage_Of_Score_2_cows__c == 1.5);
        system.assert(woaDairys[0].Average_Percentage_Of_Score_2_cows__c == 1.5);
    }
}