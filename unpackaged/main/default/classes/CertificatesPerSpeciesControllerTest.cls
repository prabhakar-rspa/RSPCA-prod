@isTest
public class CertificatesPerSpeciesControllerTest {
	@isTest
    static void loadData(){
        FObject siteObj = DataFactory.getDefSiteAccounts();
        siteObj.setDefinition('Certificate_Issue_Date__c', 'static value(2023-09-21)');
        siteObj.insertRecords(true);
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        System.assertEquals(1, insertedAccounts.size());
        insertedAccounts[0].Membership_Expiry_Date__c = Date.today() + 365;
        update insertedAccounts;
		List<Unit__c> units = new List<Unit__c>();
        // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = insertedAccounts[0].Id;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unit1.Status__c = 'Certified';
        units.add(unit1);

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = insertedAccounts[0].Id;
        unit2.Name = '02';
        unit2.Business__c = 'Supply Chain';
        unit2.Ingredients__c = 'Beef';
        unit2.Production__c = 'Processor';
        unit2.Order_Sizes__C = 'Single';
        unit2.Status__c = 'Certified';
        units.add(unit2);
        
        Unit__c unit3 = new Unit__c();
        unit3.Account__c = insertedAccounts[0].Id;
        unit3.Name = '03';
        unit3.Business__c = 'Producer';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Chickens';
        units.add(unit3);
        unit3 = new Unit__c();
        unit3.Account__c = insertedAccounts[0].Id;
        unit3.Name = '04';
        unit3.Business__c = 'Abattoir';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Salmon';
        units.add(unit3);
        unit3 = new Unit__c();
        unit3.Account__c = insertedAccounts[0].Id;
        unit3.Name = '05';
        unit3.Business__c = 'Catching';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Ducks';
        units.add(unit3);
        unit3 = new Unit__c();
        unit3.Account__c = insertedAccounts[0].Id;
        unit3.Name = '05';
        unit3.Business__c = 'Hatchery';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Salmon';
        units.add(unit3);
        unit3 = new Unit__c();
        unit3.Account__c = insertedAccounts[0].Id;
        unit3.Name = '05';
        unit3.Business__c = 'Haulier';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Salmon';
        unit3.Vehicle_Type__c = 'Wellboat';
        units.add(unit3);
        insert units;
        PageReference pageRef = Page.SupplyChainCertificateSpecies;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', insertedAccounts[0].Id);
        //ApexPages.currentPage().getParameters().put('species', insertedAccounts[0].Id);

        // Instantiate a new controller with all parameters in the page
        CertificatesPerSpeciesController controller = new CertificatesPerSpeciesController(); 
        controller.getSupplyChainUnits();
        controller.getTroutAnimalScheme();
        controller.getTroutAnimals();
        controller.getTroutRearingSystems();
        controller.getAllAnimalScheme();
        controller.getAllAnimals();
        controller.getAllAnimalRearingSystems();
        controller.getSCISchemeTexts();
        controller.getSCISchemeTitle();
		system.assert(controller.currentRecord != null && controller.currentRecord.Id == insertedAccounts[0].Id);
    }
}