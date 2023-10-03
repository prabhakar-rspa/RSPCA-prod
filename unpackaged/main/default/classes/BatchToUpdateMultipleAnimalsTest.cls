@isTest
public class BatchToUpdateMultipleAnimalsTest {
	@testSetup
    static void loadData(){
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
        List<Unit__c> units = new List<Unit__c>();
        Unit__c unit2 = TestDataFactory.createUnit(act.Id,false);
        unit2.Name = '02';
        unit2.Business__c = 'Abattoir';
        unit2.Animals__c = 'Beef Cattle';
        unit2.Ingredients__c='';
        unit2.Production__c = 'Abattoir';
        unit2.Order_Sizes__c = null;
        units.add(unit2);
        unit2 = TestDataFactory.createUnit(act.Id,false);
        unit2.Name = '02';
        unit2.Business__c = 'Abattoir';
        unit2.Animals__c = 'Chickens';
        unit2.Animals_List__c = 'Beef Cattle';
        unit2.Ingredients__c='';
        unit2.Order_Sizes__c = null;
        unit2.Production__c = 'Abattoir';
        units.add(unit2);
        unit2 = TestDataFactory.createUnit(act.Id,false);
        unit2.Name = '02';
        unit2.Business__c = 'Abattoir';
        unit2.Animals__c = 'Chickens';
        unit2.Animals_List__c = 'Beef Cattle';
        unit2.Ingredients__c='';
        unit2.Order_Sizes__c = null;
        unit2.Production__c = 'Abattoir';
        unit2.Description__c = 'TESTING(Beef Cattle)';
        units.add(unit2);
        insert units;
    }
    @isTest
    static void testMethod1(){
        Test.startTest();
        BatchToUpdateMultipleAnimals obj = new BatchToUpdateMultipleAnimals();
		Database.executeBatch(obj);
        Test.stopTest();
        List<Unit__c> units = [SELECT Id,Animals__c FROM Unit__c where Animals__c='List'];
        system.Assert(units.size()==3);
    }
}