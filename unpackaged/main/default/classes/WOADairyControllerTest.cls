@isTest
public class WOADairyControllerTest {
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
            new WOA__c(Application__c=app.Id,Species_Type__c='Dairy Cattle')
        };
        insert woaList;
        WOADairy__c woaDairy = new WOADairy__c(WOA__c = woaList[0].Id);
        insert woaDairy;
        Id RecordtypeId = Schema.SObjectType.Cows_Housing__c.getRecordTypeInfosByName().get('Dry').getRecordTypeId();

        List<Cows_Housing__c> cows = new List<Cows_Housing__c>{
            new Cows_Housing__c(WOADairy__c =woaDairy.Id,RecordTypeId=RecordtypeId ),
                new Cows_Housing__c(WOADairy__c =woaDairy.Id,RecordTypeId=RecordtypeId )
        };
            insert cows;
        List<Mobility_Scoring__c> mobilityScoring = new List<Mobility_Scoring__c>{
            new Mobility_Scoring__c(WOADairy__c =woaDairy.Id ),
                new Mobility_Scoring__c(WOADairy__c =woaDairy.Id )
        };
            insert mobilityScoring;
        List<Lameness_Prevalence__c> lamenessPrevalence = new List<Lameness_Prevalence__c>{
            new Lameness_Prevalence__c(WOADairy__c =woaDairy.Id ),
                new Lameness_Prevalence__c(WOADairy__c =woaDairy.Id )
        };
            insert lamenessPrevalence;
    }
    @isTest
    static void testMethod1(){
        WOADairy__c woaDairy = [SELECT Id,WOA__c FROM WOADairy__c LIMIT 1];
        WOADairyController.getWOADairy(woaDairy.WOA__c);
        String cowHousing = WOADairyController.getCowHousing(woaDairy.Id, 'Dry');
        String lamenessPrevalence = WOADairyController.getLamenessPrevalence(woaDairy.Id);
        STring mobilityScoring = WOADairyController.getMobilityScoring(woaDairy.Id);
        List<Cows_Housing__c> cowHousingList = (List<Cows_Housing__c>)JSON.deserialize(cowHousing, List<Cows_Housing__c>.class);
        system.Assert(cowHousingList.size() ==2);
        List<Mobility_Scoring__c> mobilityScoringList = (List<Mobility_Scoring__c>)JSON.deserialize(mobilityScoring, List<Mobility_Scoring__c>.class);
        system.Assert(mobilityScoringList.size() ==2);
        WOADairyController.saveWOADairy(woaDairy, cowHousing, new List<String>{cowHousingList[0].Id}, mobilityScoring, new List<String>{mobilityScoringList[0].Id}, lamenessPrevalence);
        cowHousingList = [SELECT ID FROM Cows_Housing__c WHERE WOADairy__c=:woaDairy.Id];
        system.Assert(cowHousingList.size() ==1);
        mobilityScoringList = [SELECT ID FROM Mobility_Scoring__c WHERE WOADairy__c=:woaDairy.Id];
        system.Assert(mobilityScoringList.size() ==1);
        
    }
}