@isTest
public class UnitLapseTest {

    @isTest
    public static void UnitLapseTest() {
         // Create account
         FObject accObj = DataFactory.getDefSiteAccounts();
         accObj.insertRecords(true);
         List<Account> accounts = FObject.getInsertedRecords('Account');
 
         // Create Units
         Unit__c unit = new Unit__c();
         unit.Account__c = accounts[0].Id;
         unit.Name = '01';
         unit.Business__c = 'Producer';
         unit.Animals__c = 'Chickens';
         unit.Production__c = 'Producer';
         unit.Status__c = 'Certified';
         insert unit;
 
         // Check records created
         List<Unit__c> units = [SELECT Id FROM Unit__C];
         System.assertEquals(1, accounts.size());
         System.assertEquals(1, units.size());

         accounts[0].Membership_Expiry_Date__c = Date.today() -1;

         update accounts;

         Test.startTest();
         ScheduleUnitLapse sh1 = new ScheduleUnitLapse();
         String sch = '0 0 23 * * ?'; 
         system.schedule('Test Territory Check', sch, sh1); 
         Test.stopTest();
 
    }
}