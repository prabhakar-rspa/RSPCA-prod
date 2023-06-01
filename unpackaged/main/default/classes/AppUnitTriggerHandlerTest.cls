@isTest
public class AppUnitTriggerHandlerTest {
    
    @testSetup static void setup() {
        Pricebook2 mbp = new Pricebook2(Name = 'Membership Price Book', IsActive = true);
        insert mbp;
        // Create joinFee product
        FObject joinFee = new FObject('Product2', 1);
        joinFee.setDefinition('Name','static value(Joining Fee)');
        joinFee.setDefinition('ProductCode','static value(JOINFEE)');
        joinFee.setDefinition('IsActive','static value(true)');
        joinFee.insertRecords(true);
        
        // Create revisitFee product
        FObject revisitFee = new FObject('Product2', 1);
        revisitFee.setDefinition('Name','static value(Revisit)');
        revisitFee.setDefinition('ProductCode','static value(REVISIT)');
        revisitFee.setDefinition('IsActive','static value(true)');
        revisitFee.insertRecords(true);

        // Create species discount product
        FObject speciesDiscount = new FObject('Product2', 1);
        speciesDiscount.setDefinition('Name','static value(Species Discount)');
        speciesDiscount.setDefinition('ProductCode','static value(SPECIESDISCOUNT)');
        speciesDiscount.setDefinition('IsActive','static value(true)');
        speciesDiscount.insertRecords(true); 
        
        // Create processor/packer product
        FObject poultryHatchery = new FObject('Product2', 1);
        poultryHatchery.setDefinition('Name','static value(Poultry hatchery)');
        poultryHatchery.setDefinition('IsActive','static value(true)');
        poultryHatchery.setDefinition('ProductCode','static value(poultryHatchery)');
        poultryHatchery.setDefinition('Family','static value(Site Fee)');
        poultryHatchery.setDefinition('Business__c', 'static value(Hatchery)');
        poultryHatchery.setDefinition('Animal__c','static value(Chickens)');
        poultryHatchery.setDefinition('Production__c', 'static value(Hatchery)');
        poultryHatchery.setDefinition('Pricing_Method__c', 'static value(Per Site)');
        poultryHatchery.insertRecords(true);

		// Create Beef Cattle prod
        FObject beefCattlePlus = new FObject('Product2', 1);
        beefCattlePlus.setDefinition('Name','static value(Beef Cattle Plus)');
        beefCattlePlus.setDefinition('IsActive','static value(true)');
        beefCattlePlus.setDefinition('ProductCode','static value(beefCattlePlus)');
        beefCattlePlus.setDefinition('Family','static value(Livestock)');
        beefCattlePlus.setDefinition('Business__c', 'static value(Producer)');
        beefCattlePlus.setDefinition('Animal__c','static value(Beef Cattle)');
        beefCattlePlus.setDefinition('Production__c', 'static value(Finishing)');
        beefCattlePlus.setDefinition('Pricing_Method__c', 'static value(Dynamic Quantity Price)');
        beefCattlePlus.setDefinition('Quantity_Threshold__c', 'static value(200)');
        beefCattlePlus.setDefinition('Dynamic_Quantity_Pricing_Component__c', 'static value(true)');
        beefCattlePlus.insertRecords(true);

        // Create Beef Cattle prod
        FObject beefCattle = new FObject('Product2', 1);
        beefCattle.setDefinition('Name','static value(Beef Cattle)');
        beefCattle.setDefinition('IsActive','static value(true)');
        beefCattle.setDefinition('ProductCode','static value(beefCatt)');
        beefCattle.setDefinition('Family','static value(Livestock)');
        beefCattle.setDefinition('Business__c', 'static value(Producer)');
        beefCattle.setDefinition('Animal__c','static value(Beef Cattle)');
        beefCattle.setDefinition('Production__c', 'static value(Finishing)');
        beefCattle.setDefinition('Pricing_Method__c', 'static value(Dynamic Quantity Price)');
        beefCattle.setDefinition('Quantity_Threshold__c', 'static value(200)');
        beefCattle.setDefinition('Dynamic_Quantity_Product__c', 'static lookup(Product2) field(ProductCode) value(beefCattlePlus) source(forceea)');
        beefCattle.insertRecords(true);
        
        // Create processor/packer product
        FObject vehicleProductAdd = new FObject('Product2', 1);
        vehicleProductAdd.setDefinition('Name','static value(Vehicle/ Trailer Additional)');
        vehicleProductAdd.setDefinition('ProductCode','static value(VEHICLEADDITIONAL)');
        vehicleProductAdd.setDefinition('IsActive','static value(true)');
        vehicleProductAdd.setDefinition('Family','static value(Vehicle)');
        vehicleProductAdd.setDefinition('Business__c', 'static value(Haulier)');
        vehicleProductAdd.setDefinition('Animal__c','static value(Chickens)');
        vehicleProductAdd.setDefinition('Production__c', 'static value(Haulier)');
        vehicleProductAdd.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        vehicleProductAdd.setDefinition('Quantity_Threshold__c', 'static value(1)');
        vehicleProductAdd.setDefinition('Additional_Quantity_Pricing_Component__c', 'static value(true)');
        vehicleProductAdd.insertRecords(true);

        // Create processor/packer product
        FObject vehicleProduct = new FObject('Product2', 1);
        vehicleProduct.setDefinition('Name','static value(Vehicle/ Trailer)');
        vehicleProduct.setDefinition('ProductCode','static value(VEHICLE)');
        vehicleProduct.setDefinition('IsActive','static value(true)');
        vehicleProduct.setDefinition('Family','static value(Vehicle)');
        vehicleProduct.setDefinition('Business__c', 'static value(Haulier)');
        vehicleProduct.setDefinition('Animal__c','static value(Chickens)');
        vehicleProduct.setDefinition('Production__c', 'static value(Haulier)');
        vehicleProduct.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        vehicleProduct.setDefinition('Quantity_Threshold__c', 'static value(1)');
        vehicleProduct.setDefinition('Additional_Quantity_Product__c', 'static lookup(Product2) field(ProductCode) value(VEHICLEADDITIONAL) source(forceea)');
        vehicleProduct.insertRecords(true);
        
        // Create processor/packer product
        FObject catchingAdd = new FObject('Product2', 1);
        catchingAdd.setDefinition('Name','static value(Catching Team)');
        catchingAdd.setDefinition('ProductCode','static value(CATCHINGADD)');
        catchingAdd.setDefinition('IsActive','static value(true)');
        catchingAdd.setDefinition('Family','static value(Poultry)');
        catchingAdd.setDefinition('Business__c', 'static value(Catching)');
        catchingAdd.setDefinition('Animal__c','static value(Chickens)');
        catchingAdd.setDefinition('Production__c', 'static value(Catching Team)');
        catchingAdd.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        catchingAdd.setDefinition('Quantity_Threshold__c', 'static value(1)');
        catchingAdd.setDefinition('Additional_Quantity_Pricing_Component__c', 'static value(true)');
        catchingAdd.insertRecords(true);

        // Create processor/packer product
        FObject catching = new FObject('Product2', 1);
        catching.setDefinition('Name','static value(Catching Team)');
        catching.setDefinition('ProductCode','static value(CATCHING)');
        catching.setDefinition('IsActive','static value(true)');
        catching.setDefinition('Family','static value(Poultry)');
        catching.setDefinition('Business__c', 'static value(Catching)');
        catching.setDefinition('Animal__c','static value(Chickens)');
        catching.setDefinition('Production__c', 'static value(Catching Team)');
        catching.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        catching.setDefinition('Quantity_Threshold__c', 'static value(1)');
        catching.setDefinition('Additional_Quantity_Product__c', 'static lookup(Product2) field(ProductCode) value(CATCHINGADD) source(forceea)');
        catching.insertRecords(true);
        
        // Create processor/packer product
        FObject pigs = new FObject('Product2', 1);
        pigs.setDefinition('Name','static value(Pigs)');
        pigs.setDefinition('IsActive','static value(true)');
        pigs.setDefinition('ProductCode','static value(pigs)');
        pigs.setDefinition('Family','static value(Livestock)');
        pigs.setDefinition('Business__c', 'static value(Producer)');
        pigs.setDefinition('Animal__c','static value(Pigs)');
        pigs.setDefinition('Production__c', 'static value(Breeding)');
        pigs.setDefinition('Pricing_Method__c', 'static value(Per Site)');
        pigs.setDefinition('Quantity_Threshold__c', 'static value(1)');
        pigs.insertRecords(true);

        // Create processor/packer product
        FObject pigStage1 = new FObject('Product2', 1);
        pigStage1.setDefinition('Name','static value(Pigs1)');
        pigStage1.setDefinition('ProductCode','static value(PIGSTAGE1DISCOUNT)');
        pigStage1.setDefinition('IsActive','static value(true)');
        pigStage1.setDefinition('Family','static value(Livestock)');
        pigStage1.insertRecords(true);

        // Create processor/packer product
        FObject pigStage2 = new FObject('Product2', 1);
        pigStage2.setDefinition('Name','static value(Pigs2)');
        pigStage2.setDefinition('ProductCode','static value(PIGSTAGE2DISCOUNT)');
        pigStage2.setDefinition('IsActive','static value(true)');
        pigStage2.setDefinition('Family','static value(Livestock)');
        pigStage2.insertRecords(true);
        
        // Create processor/packer product
        FObject chickensAdd = new FObject('Product2', 1);
        chickensAdd.setDefinition('Name','static value(ChickensAdd)');
        chickensAdd.setDefinition('ProductCode','static value(CHICKENADD)');
        chickensAdd.setDefinition('IsActive','static value(true)');
        chickensAdd.setDefinition('Family','static value(Poultry)');
        chickensAdd.setDefinition('Business__c', 'static value(Producer)');
        chickensAdd.setDefinition('Animal__c','static value(Chickens)');
        chickensAdd.setDefinition('Production__c', 'static value(Producer)');
        chickensAdd.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        chickensAdd.setDefinition('Quantity_Threshold__c', 'static value(30000)');
        chickensAdd.setDefinition('Additional_Quantity_Pricing_Component__c', 'static value(true)');
        //chickens.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        chickensAdd.insertRecords(true);

        // Create processor/packer product
        FObject chickens = new FObject('Product2', 1);
        chickens.setDefinition('Name','static value(Chickens)');
        chickens.setDefinition('ProductCode','static value(CHICKEN)');
        chickens.setDefinition('IsActive','static value(true)');
        chickens.setDefinition('Family','static value(Poultry)');
        chickens.setDefinition('Business__c', 'static value(Producer)');
        chickens.setDefinition('Animal__c','static value(Chickens)');
        chickens.setDefinition('Production__c', 'static value(Producer)');
        chickens.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        chickens.setDefinition('Quantity_Threshold__c', 'static value(30000)');
        chickens.setDefinition('Additional_Quantity_Product__c', 'static lookup(Product2) field(ProductCode) value(CHICKENADD) source(forceea)');
        //chickens.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        chickens.insertRecords(true);
        
        // Create processor/packer product
        FObject layingHensAdd = new FObject('Product2', 1);
        layingHensAdd.setDefinition('Name','static value(Laying Hens Add)');
        layingHensAdd.setDefinition('ProductCode','static value(LAYINGHENSADD)');
        layingHensAdd.setDefinition('IsActive','static value(true)');
        layingHensAdd.setDefinition('Family','static value(Poultry)');
        layingHensAdd.setDefinition('Business__c', 'static value(Producer)');
        layingHensAdd.setDefinition('Animal__c','static value(Laying Hens)');
        layingHensAdd.setDefinition('Production__c', 'static value(Multi-tier with Veranda)');
        layingHensAdd.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        layingHensAdd.setDefinition('Quantity_Threshold__c', 'static value(6000)');
        layingHensAdd.setDefinition('Additional_Quantity_Pricing_Component__c', 'static value(true)');
        //chickens.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        layingHensAdd.insertRecords(true);

        // Create processor/packer product
        FObject layingHens = new FObject('Product2', 1);
        layingHens.setDefinition('Name','static value(Laying Hens)');
        layingHens.setDefinition('ProductCode','static value(LAYINGHENS)');
        layingHens.setDefinition('IsActive','static value(true)');
        layingHens.setDefinition('Family','static value(Poultry)');
        layingHens.setDefinition('Business__c', 'static value(Producer)');
        layingHens.setDefinition('Animal__c','static value(Laying Hens)');
        layingHens.setDefinition('Production__c', 'static value(Multi-tier with Veranda)');
        layingHens.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        layingHens.setDefinition('Quantity_Threshold__c', 'static value(6000)');
        layingHens.setDefinition('Additional_Quantity_Product__c', 'static lookup(Product2) field(ProductCode) value(LAYINGHENSADD) source(forceea)');
        //chickens.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        layingHens.insertRecords(true);
        
        // Create processor/packer product
        FObject pulletAdd = new FObject('Product2', 1);
        pulletAdd.setDefinition('Name','static value(Pulletsadd)');
        pulletAdd.setDefinition('ProductCode','static value(PULLETSADD)');
        pulletAdd.setDefinition('IsActive','static value(true)');
        pulletAdd.setDefinition('Family','static value(Poultry)');
        pulletAdd.setDefinition('Business__c', 'static value(Producer)');
        pulletAdd.setDefinition('Animal__c','static value(Pullets)');
        pulletAdd.setDefinition('Production__c', 'static value(Multi-tier (two-storey))');
        pulletAdd.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        pulletAdd.setDefinition('Quantity_Threshold__c', 'static value(12000)');
        pulletAdd.setDefinition('Additional_Quantity_Pricing_Component__c', 'static value(true)');
        //pullet.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        pulletAdd.insertRecords(true);

        // Create processor/packer product
        FObject pullet = new FObject('Product2', 1);
        pullet.setDefinition('Name','static value(Pullets)');
        pullet.setDefinition('ProductCode','static value(PULLETS)');
        pullet.setDefinition('IsActive','static value(true)');
        pullet.setDefinition('Family','static value(Poultry)');
        pullet.setDefinition('Business__c', 'static value(Producer)');
        pullet.setDefinition('Animal__c','static value(Pullets)');
        pullet.setDefinition('Production__c', 'static value(Multi-tier (two-storey))');
        pullet.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        pullet.setDefinition('Quantity_Threshold__c', 'static value(12000)');
        pullet.setDefinition('Additional_Quantity_Product__c', 'static lookup(Product2) field(ProductCode) value(PULLETSADD) source(forceea)');
        //pullet.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        pullet.insertRecords(true);
        
        // Create processor/packer product
        FObject turkeyAdd = new FObject('Product2', 1);
        turkeyAdd.setDefinition('Name','static value(Turkeysadd)');
        turkeyAdd.setDefinition('ProductCode','static value(TURKEYSADD)');
        turkeyAdd.setDefinition('IsActive','static value(true)');
        turkeyAdd.setDefinition('Family','static value(Poultry)');
        turkeyAdd.setDefinition('Business__c', 'static value(Producer)');
        turkeyAdd.setDefinition('Animal__c','static value(Turkeys)');
        turkeyAdd.setDefinition('Production__c', 'static value(Brood)');
        turkeyAdd.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        turkeyAdd.setDefinition('Quantity_Threshold__c', 'static value(12000)');
        turkeyAdd.setDefinition('Additional_Quantity_Pricing_Component__c', 'static value(true)');
        //pullet.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        turkeyAdd.insertRecords(true);
        
        // Create processor/packer product
        FObject turkey = new FObject('Product2', 1);
        turkey.setDefinition('Name','static value(Turkeys)');
        turkey.setDefinition('ProductCode','static value(TURKEYS)');
        turkey.setDefinition('IsActive','static value(true)');
        turkey.setDefinition('Family','static value(Poultry)');
        turkey.setDefinition('Business__c', 'static value(Producer)');
        turkey.setDefinition('Animal__c','static value(Turkeys)');
        turkey.setDefinition('Production__c', 'static value(Brood)');
        turkey.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        turkey.setDefinition('Quantity_Threshold__c', 'static value(12000)');
        turkey.setDefinition('Additional_Quantity_Product__c', 'static lookup(Product2) field(ProductCode) value(TURKEYSADD) source(forceea)');
        //pullet.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        turkey.insertRecords(true);
        
        // Create processor/packer product
        FObject duckAdd = new FObject('Product2', 1);
        duckAdd.setDefinition('Name','static value(Ducksadd)');
        duckAdd.setDefinition('ProductCode','static value(DUCKSADD)');
        duckAdd.setDefinition('IsActive','static value(true)');
        duckAdd.setDefinition('Family','static value(Poultry)');
        duckAdd.setDefinition('Business__c', 'static value(Producer)');
        duckAdd.setDefinition('Animal__c','static value(Ducks)');
        duckAdd.setDefinition('Production__c', 'static value(Producer)');
        duckAdd.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        duckAdd.setDefinition('Quantity_Threshold__c', 'static value(30000)');
        duckAdd.setDefinition('Additional_Quantity_Pricing_Component__c', 'static value(true)');
        //duck.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        duckAdd.insertRecords(true);

        // Create processor/packer product
        FObject duck = new FObject('Product2', 1);
        duck.setDefinition('Name','static value(Ducks)');
        duck.setDefinition('ProductCode','static value(DUCKS)');
        duck.setDefinition('IsActive','static value(true)');
        duck.setDefinition('Family','static value(Poultry)');
        duck.setDefinition('Business__c', 'static value(Producer)');
        duck.setDefinition('Animal__c','static value(Ducks)');
        duck.setDefinition('Production__c', 'static value(Producer)');
        duck.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
        duck.setDefinition('Quantity_Threshold__c', 'static value(30000)');
        duck.setDefinition('Additional_Quantity_Product__c', 'static lookup(Product2) field(ProductCode) value(DUCKSADD) source(forceea)');
        //duck.setDefinition('Dynamic_Quantity_Price__c', 'static value()');
        duck.insertRecords(true);
        
        
        List<Product2> insertedProducts = FObject.getInsertedRecords('Product2');
        List<PricebookEntry> SpbeList = new List<PricebookEntry>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for(Product2 p: insertedProducts){
            PricebookEntry pbe = new PricebookEntry(
                IsActive = true,
                Pricebook2Id = mbp.Id,
                Product2Id = p.Id,
                UnitPrice = 100
            );
            pbeList.add(pbe);

            PricebookEntry pbe1 = new PricebookEntry(
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = p.Id,
                UnitPrice = 100
            );
            SpbeList.add(pbe1);
        }
        insert SpbeList;
        insert pbeList;
        
    }
    
    @isTest
    public static Application__c createApplication(){
        
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
    public static Application__c createApplicationWithoutPrices(){
		
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
        insertedApp[0].Application_Type__c = 'New';
        update insertedApp[0];
        return insertedApp[0];
    }

    // Supply chain fee product units
    @isTest
    public static void supplyChainUnitAddTest() {
        Test.startTest();
        
        Application__c application = createApplicationWithoutPrices();
        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Supply Chain)');
        unitObj.setDefinition('Production__c', 'static value(Processor)');
        unitObj.setDefinition('Ingredients__c', 'static value(Chicken)');
        unitObj.setDefinition('Order_Sizes__c', 'static value(Medium)');
        unitObj.insertRecords(true);
        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
        List<Unit__c> insertedUnitList = FObject.getInsertedRecords('Unit__c'); 
        List<Application_Unit__c> insertedAppUnitList = FObject.getInsertedRecords('Application_Unit__c'); 
        Test.StopTest();
    }

     // Supply chain fee product units
     @isTest
     public static void supplyChainUnitAddTest2() {
        Test.startTest();
         // New Application
         Application__c application = createApplicationWithoutPrices();
         application.Existing_Member__c = 'Yes';
         application.Application_Type__c = 'Update';
         application.Update_Type__c = 'New Unit';
         update application;
         // Create Units
         FObject unitObj = new FObject('Unit__c', 1);
         unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
         unitObj.setDefinition('Name', 'static value(01)');
         unitObj.setDefinition('Business__c', 'static value(Supply Chain)');
         unitObj.setDefinition('Production__c', 'static value(Processor)');
         unitObj.setDefinition('Ingredients__c', 'static value(Chicken)');
         unitObj.setDefinition('Order_Sizes__c', 'static value(Medium)');
         unitObj.insertRecords(true);
         // Application Unit
         FObject appUnit = new FObject('Application_Unit__c', 1);
         appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
         appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
         appUnit.insertRecords(true);
         List<Unit__c> insertedUnitList = FObject.getInsertedRecords('Unit__c'); 
         List<Application_Unit__c> insertedAppUnitList = FObject.getInsertedRecords('Application_Unit__c'); 
         Test.stopTest();
     }

     // Supply chain fee product units
     @isTest
     public static void supplyChainUnitAddTest3() {
         Test.startTest();
       		String renewalRecordType = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
         Application__c application = createApplicationWithoutPrices();
         application.RecordTypeId = renewalRecordType;
         application.Existing_Member__c = 'Yes';
         application.Renewal_Stage__c = 'Renewal';
         application.Application_Type__c = 'Renewal';
         application.Update_Type__c = '';
         update application;
         // Create Units
         FObject unitObj = new FObject('Unit__c', 1);
         unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
         unitObj.setDefinition('Name', 'static value(01)');
         unitObj.setDefinition('Business__c', 'static value(Supply Chain)');
         unitObj.setDefinition('Production__c', 'static value(Processor)');
         unitObj.setDefinition('Ingredients__c', 'static value(Chicken)');
         unitObj.setDefinition('Order_Sizes__c', 'static value(Medium)');
         unitObj.insertRecords(true);
         Product2 unitProduct = new Product2(IsActive=true,Name='Test Product 1',ProductCode='test product',Business__c='Supply Chain',Production__c='Processor');
         insert unitProduct;
         // Application Unit
         FObject appUnit = new FObject('Application_Unit__c', 1);
         appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
         appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
         appUnit.insertRecords(true);
         List<Unit__c> insertedUnitList = FObject.getInsertedRecords('Unit__c'); 
         List<Application_Unit__c> insertedAppUnitList = FObject.getInsertedRecords('Application_Unit__c'); 
		Test.stopTest();
     }
    @isTest
     public static void supplyChainUnitAddTest4() {
         Test.startTest();
       		String renewalRecordType = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Applications').getRecordTypeId();
         Application__c application = createApplicationWithoutPrices();
         application.RecordTypeId = renewalRecordType;
         application.Existing_Member__c = 'Yes';
         //application.Renewal_Stage__c = 'Renewal';
         application.Application_Type__c = 'Update';
         application.Update_Type__c = 'New Unit';
         update application;
         // Create Units
         FObject unitObj = new FObject('Unit__c', 1);
         unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
         unitObj.setDefinition('Name', 'static value(01)');
         unitObj.setDefinition('Business__c', 'static value(Supply Chain)');
         unitObj.setDefinition('Production__c', 'static value(Processor)');
         unitObj.setDefinition('Ingredients__c', 'static value(Chicken)');
         unitObj.setDefinition('Order_Sizes__c', 'static value(Medium)');
         unitObj.insertRecords(true);
         Product2 unitProduct = new Product2(IsActive=true,Name='Test Product 1',ProductCode='test product',Business__c='Supply Chain',Production__c='Processor');
         insert unitProduct;
         // Application Unit
         FObject appUnit = new FObject('Application_Unit__c', 1);
         appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
         appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
         appUnit.insertRecords(true);
         List<Unit__c> insertedUnitList = FObject.getInsertedRecords('Unit__c'); 
         List<Application_Unit__c> insertedAppUnitList = FObject.getInsertedRecords('Application_Unit__c'); 
		Test.stopTest();
     }
	@isTest
     public static void supplyChainUnitAddTest5() {
         Test.startTest();
       		String renewalRecordType = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Applications').getRecordTypeId();
         Application__c application = createApplicationWithoutPrices();
         application.RecordTypeId = renewalRecordType;
         application.Existing_Member__c = 'No';
         application.Application_Type__c = 'New';
         application.Update_Type__c = '';
         update application;
         // Create Units
         FObject unitObj = new FObject('Unit__c', 1);
         unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
         unitObj.setDefinition('Name', 'static value(01)');
         unitObj.setDefinition('Business__c', 'static value(Supply Chain)');
         unitObj.setDefinition('Production__c', 'static value(Processor)');
         unitObj.setDefinition('Ingredients__c', 'static value(Chicken)');
         unitObj.setDefinition('Order_Sizes__c', 'static value(Medium)');
         unitObj.insertRecords(true);
         Product2 unitProduct = new Product2(IsActive=true,Name='Test Product 1',ProductCode='test product',Business__c='Supply Chain',Production__c='Processor');
         insert unitProduct;
         // Application Unit
         FObject appUnit = new FObject('Application_Unit__c', 1);
         appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
         appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
         appUnit.insertRecords(true);
         List<Unit__c> insertedUnitList = FObject.getInsertedRecords('Unit__c'); 
         List<Application_Unit__c> insertedAppUnitList = FObject.getInsertedRecords('Application_Unit__c'); 
		Test.stopTest();
     }
    // Per Site Animal Product units
    @isTest
    public static void perSiteAnimalUnitsTest() {
        Test.startTest();
       
        // New Application
        Application__c application = createApplicationWithoutPrices();
        application.Application_Type__c = 'New';
        update application;

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Hatchery)');
        unitObj.setDefinition('Production__c', 'static value(Hatchery)');
        unitObj.setDefinition('Animals__c', 'static value(Chickens)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);

        List<Unit__c> insertedUnitList = FObject.getInsertedRecords('Unit__c'); 
        List<Application_Unit__c> insertedAppUnitList = FObject.getInsertedRecords('Application_Unit__c'); 

        // Application Type = Update
        Application__c application1 = application.clone(false, false, false, false);
        application1.Existing_Member__c = 'Yes';
        application1.Application_Type__c = 'Update';
        application1.Update_Type__c = 'New Unit';
        insert application1;
        // Application Unit
        Application_Unit__c newAppUnit1 = insertedAppUnitList[0].clone(false,false,false,false);
        newAppUnit1.Application__c = application1.Id;
        newAppUnit1.Unit__c = insertedUnitList[0].Id;
        insert newAppUnit1;
        // Application Type = Renewal
        String renewalRecordType = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Application__c application2 = application1.clone(false, false, false, false);
        application2.RecordTypeId = renewalRecordType;
        application2.Renewal_Stage__c = 'Renewal';
        application2.Application_Type__c = 'Renewal';
        application2.Update_Type__c = '';
        insert application2;
        // Application Unit
        Application_Unit__c newAppUnit2 = insertedAppUnitList[0].clone(false,false,false,false);
        newAppUnit2.Application__c = application2.Id;
        newAppUnit2.Unit__c = insertedUnitList[0].Id;
        insert newAppUnit2;

		Test.stopTest();
    }

    // Dynamic Quantity unit test 1 with below threshold
    @isTest
    public static void dynamicQuantityUnitsTest1() {
        
		Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Unit below below threshold
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Producer)');
        unitObj.setDefinition('Production__c', 'static value(Finishing)');
        unitObj.setDefinition('Animals__c', 'static value(Beef Cattle)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(100)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
        Test.stopTest();
    }

    // Dynamic Quantity unit test 2 with above threshold
    @isTest
    public static void dynamicQuantityUnitsTest2() {
		
        Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();


        // Create unit above threshold
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Producer)');
        unitObj.setDefinition('Production__c', 'static value(Finishing)');
        unitObj.setDefinition('Animals__c', 'static value(Beef Cattle)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(201)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);

        // Application Unit 2
        FObject appUnit2 = new FObject('Application_Unit__c', 1);
        appUnit2.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit2.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit2.insertRecords(true);
		Test.stopTest();
    }

    // Additional Quantity Product units tests
    @isTest
    public static void newVehicleUnitsTest() {
        
        Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();
        
        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Haulier)');
        unitObj.setDefinition('Production__c', 'static value(Haulier)');
        unitObj.setDefinition('Animals__c', 'static value(Chickens)');
        //unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        //unitObj.setDefinition('Number_of_Animals__c', 'static value(201)');
        unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
        
        Test.stopTest();
    }
    @isTest
    public static void newCatchingTeamUnitsTest() {
       
		Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Catching)');
        unitObj.setDefinition('Production__c', 'static value(Catching Team)');
        unitObj.setDefinition('Animals__c', 'static value(Chickens)');
        //unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        //unitObj.setDefinition('Number_of_Animals__c', 'static value(201)');
        //unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        //unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        //unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
		Test.stopTest();
    }
    @isTest
    public static void newPigsUnitsTest() {
       	Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;

        Contact cnt = new Contact();
        cnt.AccountId = act.Id;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;

        act.Primary_Contact__c = cnt.Id;
        update act;

        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Company_Industry__c = 'Fish';
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(14);
        site.Status__c = 'Member';
        site.Pig_Discount_Eligibility__c = true;
        insert site;
        
        Test.startTest();
        // New Application
        /*Application__c application = createApplicationWithoutPrices();
		application.Site__C = site.Id;
        update application;*/
        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        insert app;
        Unit__c unit =  new Unit__c();
        unit.Account__c = site.Id;
        unit.Name = '01';
        unit.Business__c = 'Producer';
        unit.Production__c = 'Breeding';
        unit.Animals__c = 'Pigs';
        unit.Rearing_System__c = 'Indoor';
        unit.Status__c = 'Certified';
        unit.Number_of_Animals__c = 1;
        insert unit;
        Unit__c unit1 =  new Unit__c();
        unit1.Account__c = site.Id;
        unit1.Name = '02';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Breeding';
        unit1.Animals__c = 'Pigs';
        unit1.Rearing_System__c = 'Indoor';
        unit1.Status__c = 'Certified';
        unit1.Number_of_Animals__c = 1;
        insert unit1;
        List<Application_Unit__c> appUnits = new List<Application_Unit__c>();
        Application_Unit__c appUnit = new Application_Unit__c(Application__c=app.Id,Unit__c=unit.Id);
        appUnits.add(appUnit);
        appUnit = new Application_Unit__c(Application__c=app.Id,Unit__c=unit1.Id);
        appUnits.add(appUnit);
		insert appUnits;
		Test.stopTest();
    }
    @isTest
    public static void newPigsUnitsTest1() {
       	Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;

        Contact cnt = new Contact();
        cnt.AccountId = act.Id;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;

        act.Primary_Contact__c = cnt.Id;
        update act;

        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Company_Industry__c = 'Fish';
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(14);
        site.Status__c = 'Member';
        site.Pig_Discount_Eligibility__c = true;
        insert site;
        
        Test.startTest();
        // New Application
        /*Application__c application = createApplicationWithoutPrices();
		application.Site__C = site.Id;
        update application;*/
        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        insert app;
        Unit__c unit =  new Unit__c();
        unit.Account__c = site.Id;
        unit.Name = '01';
        unit.Business__c = 'Producer';
        unit.Production__c = 'Breeding';
        unit.Animals__c = 'Pigs';
        unit.Rearing_System__c = 'Indoor';
        unit.Status__c = 'Certified';
        unit.Number_of_Animals__c = 1;
        insert unit;
        List<Application_Unit__c> appUnits = new List<Application_Unit__c>();
        Application_Unit__c appUnit = new Application_Unit__c(Application__c=app.Id,Unit__c=unit.Id);
        appUnits.add(appUnit);
		insert appUnits;
		Test.stopTest();
    }
    @isTest
    public static void newChickensUnitsTest1() {
        
        Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Producer)');
        unitObj.setDefinition('Production__c', 'static value(Producer)');
        unitObj.setDefinition('Animals__c', 'static value(Chickens)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(25000)');
        //unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        //unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        //unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
		Test.stopTest();
    }
    @isTest
    public static void newPigsUnitsTest2() {
       	Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;

        Contact cnt = new Contact();
        cnt.AccountId = act.Id;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;

        act.Primary_Contact__c = cnt.Id;
        update act;

        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Company_Industry__c = 'Fish';
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(14);
        site.Status__c = 'Member';
        site.Pig_Discount_Eligibility__c = true;
        insert site;
        
        Test.startTest();
        // New Application
        /*Application__c application = createApplicationWithoutPrices();
		application.Site__C = site.Id;
        update application;*/
        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        insert app;
        Unit__c unit =  new Unit__c();
        unit.Account__c = site.Id;
        unit.Name = '01';
        unit.Business__c = 'Producer';
        unit.Production__c = 'Breeding';
        unit.Animals__c = 'Pigs';
        unit.Rearing_System__c = 'Indoor';
        unit.Status__c = 'Certified';
        unit.Number_of_Animals__c = 1;
        insert unit;
        Unit__c unit1 =  new Unit__c();
        unit1.Account__c = site.Id;
        unit1.Name = '02';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Breeding';
        unit1.Animals__c = 'Pigs';
        unit1.Rearing_System__c = 'Indoor';
        unit1.Status__c = 'Certified';
        unit1.Number_of_Animals__c = 1;
        insert unit1;
        Unit__c unit2 =  new Unit__c();
        unit2.Account__c = site.Id;
        unit2.Name = '02';
        unit2.Business__c = 'Producer';
        unit2.Production__c = 'Breeding';
        unit2.Animals__c = 'Pigs';
        unit2.Rearing_System__c = 'Indoor';
        unit2.Status__c = 'Certified';
        unit2.Number_of_Animals__c = 1;
        insert unit2;
        List<Application_Unit__c> appUnits = new List<Application_Unit__c>();
        Application_Unit__c appUnit = new Application_Unit__c(Application__c=app.Id,Unit__c=unit.Id);
        appUnits.add(appUnit);
        appUnit = new Application_Unit__c(Application__c=app.Id,Unit__c=unit1.Id);
        appUnits.add(appUnit);
         appUnit = new Application_Unit__c(Application__c=app.Id,Unit__c=unit2.Id);
        appUnits.add(appUnit);
		insert appUnits;
		Test.stopTest();
    }
    @isTest
    public static void newChickensUnitsTest2() {
        
        Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Producer)');
        unitObj.setDefinition('Production__c', 'static value(Producer)');
        unitObj.setDefinition('Animals__c', 'static value(Chickens)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(35000)');
        //unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        //unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        //unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
		Test.stopTest();
    }

    @isTest
    public static void newLayingHens() {
      
        Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Producer)');
        unitObj.setDefinition('Production__c', 'static value(Multi-tier with Veranda)');
        unitObj.setDefinition('Animals__c', 'static value(Laying Hens)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(35000)');
        //unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        //unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        //unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);
        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
        
        Test.stopTest();
        
        

    }
    
    @isTest
    public static void newPullets() {
       
        /*Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Supply Chain)');
        unitObj.setDefinition('Production__c', 'static value(Multi-tier (two-storey))');
        unitObj.setDefinition('Animals__c', 'static value(Pullets)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(35000)');
        //unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        //unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        //unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
		Test.stopTest();*/
        
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;

        Contact cnt = new Contact();
        cnt.AccountId = act.Id;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;

        act.Primary_Contact__c = cnt.Id;
        update act;

        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Company_Industry__c = 'Fish';
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(14);
        site.Status__c = 'Member';
        site.Pig_Discount_Eligibility__c = true;
        insert site;
        
        Test.startTest();
        // New Application
        /*Application__c application = createApplicationWithoutPrices();
		application.Site__C = site.Id;
        update application;*/
        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        insert app;
        Unit__c unit =  new Unit__c();
        unit.Account__c = site.Id;
        unit.Name = '01';
        unit.Business__c = 'Haulier';
        unit.Production__c = 'Haulier';
        unit.Animals__c = 'Pullets';
        unit.Rearing_System__c = 'Free Range';
        unit.Status__c = 'Certified';
        unit.Number_of_Animals__c = 3500;
        unit.Animals_List__c = 'Pullets';
        insert unit;
        Product2 unitProduct = new Product2(Quantity_Threshold__c=1,Family = 'Poultry',Pricing_Method__c = 'Additional Quantity Price',IsActive=true,Name='Test Product 1',ProductCode='test product',Business__c='Haulier',Production__c='Haulier',Animal__c='Pullets');
        insert unitProduct;
        Product2 unitaddProduct = new Product2(Additional_Quantity_Product__c=unitProduct.Id,Additional_Quantity_Pricing_Component__c=true,IsActive=true,Name='Test Product 1',ProductCode='test product',Business__c='Haulier',Production__c='Haulier',Animal__c='Pullets');
        insert unitaddProduct;
        List<Application_Unit__c> appUnits = new List<Application_Unit__c>();
        Application_Unit__c appUnit = new Application_Unit__c(Application__c=app.Id,Unit__c=unit.Id);
        appUnits.add(appUnit);
        try{
			insert appUnits;
        }catch(Exception ex){
            
        }
		Test.stopTest();
    }
	@isTest
    public static void newPullets1() {
       
        /*Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Supply Chain)');
        unitObj.setDefinition('Production__c', 'static value(Multi-tier (two-storey))');
        unitObj.setDefinition('Animals__c', 'static value(Pullets)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(35000)');
        //unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        //unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        //unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
		Test.stopTest();*/
        
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;

        Contact cnt = new Contact();
        cnt.AccountId = act.Id;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;

        act.Primary_Contact__c = cnt.Id;
        update act;

        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Company_Industry__c = 'Fish';
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(14);
        site.Status__c = 'Member';
        site.Pig_Discount_Eligibility__c = true;
        insert site;
        
        Test.startTest();
        // New Application
        /*Application__c application = createApplicationWithoutPrices();
		application.Site__C = site.Id;
        update application;*/
        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        insert app;
        Unit__c unit =  new Unit__c();
        unit.Account__c = site.Id;
        unit.Name = '01';
        unit.Business__c = 'Haulier';
        unit.Production__c = 'Haulier';
        unit.Animals__c = 'Pullets';
        unit.Rearing_System__c = 'Free Range';
        unit.Status__c = 'Certified';
        unit.Number_of_Animals__c = 3500;
        unit.Animals_List__c = 'Pullets';
        insert unit;
        Product2 unitProduct = new Product2(Quantity_Threshold__c=10,Family = 'Poultry',Pricing_Method__c = 'Additional Quantity Price',IsActive=true,Name='Test Product 1',ProductCode='test product',Business__c='Haulier',Production__c='Haulier',Animal__c='Pullets');
        insert unitProduct;
        Product2 unitaddProduct = new Product2(Quantity_Threshold__c=10,Additional_Quantity_Product__c=unitProduct.Id,Additional_Quantity_Pricing_Component__c=true,IsActive=true,Name='Test Product 1',ProductCode='test product',Business__c='Haulier',Production__c='Haulier',Animal__c='Pullets');
        insert unitaddProduct;
        List<Application_Unit__c> appUnits = new List<Application_Unit__c>();
        Application_Unit__c appUnit = new Application_Unit__c(Application__c=app.Id,Unit__c=unit.Id);
        appUnits.add(appUnit);
        try{
			insert appUnits;
        }catch(Exception ex){
            
        }
		Test.stopTest();
    }
    @isTest
    public static void newTurkeys() {
        
        Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Producer)');
        unitObj.setDefinition('Production__c', 'static value(Brood)');
        unitObj.setDefinition('Animals__c', 'static value(Turkeys)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(35000)');
        //unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        //unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        //unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
        
        Test.stopTest();
    }

    @isTest
    public static void newDucks() {
       
        Test.startTest();
        // New Application
        Application__c application = createApplicationWithoutPrices();

        // Create Units
        FObject unitObj = new FObject('Unit__c', 1);
        unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        unitObj.setDefinition('Name', 'static value(01)');
        unitObj.setDefinition('Business__c', 'static value(Producer)');
        unitObj.setDefinition('Production__c', 'static value(Producer)');
        unitObj.setDefinition('Animals__c', 'static value(Ducks)');
        unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
        unitObj.setDefinition('Number_of_Animals__c', 'static value(35000)');
        //unitObj.setDefinition('Vehicle_Type__c', 'static value(Lorry)');
        //unitObj.setDefinition('Vehicle_Registration__c', 'static value(12345)');
        //unitObj.setDefinition('Chassis_Number__c', 'static value(12345)');
        unitObj.insertRecords(true);

        // Application Unit
        FObject appUnit = new FObject('Application_Unit__c', 1);
        appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        appUnit.insertRecords(true);
		Test.stopTest();
    }
    /*
    @isTest
    public static void testAppUnitHelper() {
		AppUnitHelper.getProductList();
        AppUnitHelper.getAllPricebookEntries(Set<String> pricebookIds)
        AppUnitHelper.getPriceForProduct(String productId);
        AppUnitHelper.getAllSiteUnits(Set<String> siteIds);
        AppUnitHelper.getAllExistingLines(Set<String> appIds);
        AppUnitHelper.getAllAppUnits(Set<String> appIds);
        getUnitsForCreatedAppUnit(Set<String> unitIds);
        getProduct(string business, string production);
        getProduct(string business, string animals, string production, string vehicleType,String animalsList);
        Product2 getAdditionalQuantityProduct(Product2 product);
    }
*/


}