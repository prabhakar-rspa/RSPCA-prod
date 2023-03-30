@isTest
public class SiteUnitsControllerTest {
    @isTest
    public static void SiteUnitsControllerTest() {
        //Create Account
        FObject siteObj = DataFactory.getDefSiteAccounts();
        siteObj.insertRecords(true);
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        System.assertEquals(1, insertedAccounts.size());
        insertedAccounts[0].Membership_Expiry_Date__c = Date.today() + 365;
        update insertedAccounts;

        // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = insertedAccounts[0].Id;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unit1.Status__c = 'Certified';
        insert unit1;

        SiteUnitsController.getUnits(insertedAccounts[0].Id);
    }
}