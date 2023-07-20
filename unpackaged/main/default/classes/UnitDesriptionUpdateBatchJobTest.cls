@isTest
public class UnitDesriptionUpdateBatchJobTest {
        
    @isTest
    static void testUnitDescriptionUpdate(){

         // Create account
         FObject accObj = DataFactory.getDefSiteAccounts();
         accObj.insertRecords(true);
         List<Account> accounts = FObject.getInsertedRecords('Account');
 
         // Create Units
         List<Unit__c> units = new List<Unit__c>();
         Unit__c unit = new Unit__c();
         unit.Account__c = accounts[0].Id;
         unit.Name = '01';
         unit.Business__c = 'Producer';
         unit.Animals__c = 'Chickens';
         unit.Production__c = 'Producer';
         unit.Status__c = 'Certified';
         unit.Description__c = 'Wholesaler Unit (Beef) (Chickens) (Pigs)';
         units.add(unit);
        
         Unit__c unit2 = new Unit__c();
         unit2.Account__c = accounts[0].Id;
         unit2.Name = '02';
         unit2.Business__c = 'Producer';
         unit2.Animals__c = 'Chickens';
         unit2.Production__c = 'Producer';
         unit2.Status__c = 'Certified';
         unit2.Description__c = 'Producer Unit (Chickens, Pigs) (Pigs)';
         units.add(unit2);
        
         Unit__c unit3 = new Unit__c();
         unit3.Account__c = accounts[0].Id;
         unit3.Name = '03';
         unit3.Business__c = 'Producer';
         unit3.Animals__c = 'Chickens';
         unit3.Production__c = 'Producer';
         unit3.Status__c = 'Certified';
         unit3.Description__c = 'Producer Unit';
         units.add(unit3);
        
         insert units;
        
        //Check description value of Unit before batch job
        List<Unit__c> unitsBefore = [SELECT Id, Name,Description__c  FROM Unit__c];
        for(Unit__c u : unitsBefore){
            if(u.Name == '01'){
                system.assertEquals(unit.Description__c, u.Description__c, 'Description should be same');
            }else if(u.Name == '02'){
                system.assertEquals(unit2.Description__c, u.Description__c, 'Description should be same');
            }else{
                system.assertEquals(unit3.Description__c, u.Description__c, 'Description should be same');
            }
        }       
        
        //start test
        Test.startTest();        
        UnitDesriptionUpdateBatchJob testJob = new UnitDesriptionUpdateBatchJob();
        Database.executeBatch(testJob);
        Test.stopTest();
        
        
        //Check description value of Unit after batch job
        List<Unit__c> unitsAfter = [SELECT Id, Name,Description__c  FROM Unit__c];
        for(Unit__c u : unitsAfter){
            if(u.Name == '01'){
                system.assertEquals('Wholesaler Unit (Beef) (Chickens)', u.Description__c, 'Description should be updated');
            }else if(u.Name == '02'){
                system.assertEquals('Producer Unit (Chickens, Pigs)', u.Description__c, 'Description should be updated');
            }else{
                system.assertEquals(unit3.Description__c, u.Description__c, 'Description should be same');
            }
        }       
    }
}