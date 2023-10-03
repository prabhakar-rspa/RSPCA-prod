@isTest
public class AdditionalApplicationControllerTest {
    @isTest
    static void fetchCustomerContactWithUserTest() {
        // Create System Admin User with Role to create the account
        FObject adminUser = new FObject('User', 1);
        adminUser.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
        adminUser.setDefinition('Alias','static value(testadm)');
        adminUser.setDefinition('LastName','static value(testadmin)');
        adminUser.setDefinition('UserName','static value(testadmin543434234324@test.com)');
        adminUser.setDefinition('Email','static value(testadmin@test.com)');
        adminUser.setDefinition('UserRoleId', 'random lookup(UserRole) source(forceea)');
        adminUser.insertRecords(true);
        List<User> insertedUsers = FObject.getInsertedRecords('User');
        User insertedAdminUser = new User();
        for(User u : insertedUsers){
            if(u.Alias == 'testadm'){
                insertedAdminUser = u;
            }
        }

        System.runAs(insertedAdminUser){
            // Account
            FObject acc = DataFactory.getDefSiteAccounts();
            acc.setDefinition('Primary_Contact__c', 'random lookup(Contact) source(forceaa)');
            acc.insertRecords(true);
            
            // Contact
            FObject con = DataFactory.getDefContact();
            con.setDefinition('AccountId', 'random lookup(Account) source(forceea)');
            con.insertRecords(true);
        }
        

        // Create customer user to run the tests with
        FObject customerUser = new FObject('User', 1);
        customerUser.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(RSPCA Assured Community User Site) source(salesforce)');
        customerUser.setDefinition('ContactId', 'random lookup(Contact) source(forceea)');
        customerUser.setDefinition('Alias','static value(test)');
        customerUser.setDefinition('LastName','static value(Last)');
        customerUser.setDefinition('UserName','static value(tester@test.com)');
        customerUser.setDefinition('Email','static value(tester@test.com)');
        customerUser.insertRecords(true);
        List<User> users = FObject.getInsertedRecords('User');
        List<Account> accounts = FObject.getInsertedRecords('Account');
        User insertedCustomerUser = new User();
        for(User u : users){
            if(u.Alias == 'test'){
                insertedCustomerUser = u;
            }
        }
        Test.startTest();
        System.runAs(insertedCustomerUser){
            AdditionalApplicationController.fetchCustomerContact(accounts[0].Id);
            
        }
        Test.stopTest();

    }

    @isTest
    static void fetchCustomerContactWithoutUserTest() {

        // Account
        FObject acc = DataFactory.getDefSiteAccounts();
        acc.insertRecords(true);
        
        // Contact
        FObject con = DataFactory.getDefContact();
        con.setDefinition('FirstName', 'static value(test)');
        con.setDefinition('AccountId', 'random lookup(Account) source(forceea)');
        con.insertRecords(true);
        List<Contact> contacts = FObject.getInsertedRecords('Contact');
        List<Account> accounts = FObject.getInsertedRecords('Account');
        Account accRecord = accounts[0];
        accRecord.Primary_Contact__c = contacts[0].Id;
        update accRecord;
        AdditionalApplicationController.fetchCustomerContact(accounts[0].Id);

    }
    
    @isTest
    static void createAppWithUnitsTest(){
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

        // Create species discount product
        FObject speciesDiscount = new FObject('Product2', 1);
        speciesDiscount.setDefinition('Name','static value(Species Discount)');
        speciesDiscount.setDefinition('ProductCode','static value(SPECIESDISCOUNT)');
        speciesDiscount.setDefinition('IsActive','static value(true)');
        speciesDiscount.setDefinition('Standard_Price__c','static value(-59.50)');
        speciesDiscount.setDefinition('Species_Discount_Extra__c','static value(-88.00)');
        speciesDiscount.insertRecords(true);

        // Create Application 1 with update type = New Unit
        FObject application1 = DataFactory.getDefNewApplications();
        application1.setDefinition('Existing_Member__c', 'static value(Yes)');
        application1.setDefinition('Application_Type__c', 'static value(Update)');
        application1.setDefinition('Update_Type__c', 'static value(New Unit)');
        application1.setDefinition('Payment_Method__c', 'static value(Card)');
        application1.insertRecords(true);
        
        List<Application__c> insertedApps = FObject.getInsertedRecords('Application__c');
        Application__c appNewUnits = new Application__c();
        for(Application__c app : insertedApps){
            app.Id = null;
            if(app.Update_Type__c == 'New Unit'){
                appNewUnits = app;
            }
            
        }
        

        // Create Units
        List<Unit__c> unitList = new List<Unit__c>();
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = appNewUnits.Site__c;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unitList.add(unit1);
        
        Unit__c unit2 = new Unit__c();
        unit2.Account__c = appNewUnits.Site__c;
        unit2.Name = '02';
        unit2.Business__c = 'Abattoir';
        unit2.Animals__c = 'Beef Cattle';
        unit2.Production__c = 'Abattoir';
        unitList.add(unit2);

        Unit__c unit3 = new Unit__c();
        unit3.Account__c = appNewUnits.Site__c;
        unit3.Name = '03';
        unit3.Business__c = 'Catching';
        unit3.Animals__c = 'Chickens';
        unit3.Production__c = 'Catching Team';
        unitList.add(unit3);

        Unit__c unit4 = new Unit__c();
        unit4.Account__c = appNewUnits.Site__c;
        unit4.Name = '04';
        unit4.Business__c = 'Cleaner Fish';
        unit4.Animals__c = 'Wrasse';
        unit4.Production__c = 'Cleaner Fish';
        unitList.add(unit4);

        Unit__c unit5 = new Unit__c();
        unit5.Account__c = appNewUnits.Site__c;
        unit5.Name = '05';
        unit5.Business__c = 'Hatchery';
        unit5.Animals__c = 'Meat Chicken Chicks';
        unit5.Production__c = 'Hatchery';
        unitList.add(unit5);

        Unit__c unit6 = new Unit__c();
        unit6.Account__c = appNewUnits.Site__c;
        unit6.Name = '06';
        unit6.Business__c = 'Haulier';
        unit6.Animals__c = 'Chickens';
        unit6.Production__c = 'Haulier';
        unitList.add(unit6);

        Unit__c unit7 = new Unit__c();
        unit7.Account__c = appNewUnits.Site__c;
        unit7.Name = '02';
        unit7.Business__c = 'Producer';
        unit7.Production__c = 'Freshwater';
        unit7.Animals__c = 'Trout';
        unit7.Number_Of_Animals__c = 100;
        unitList.add(unit7);

        System.debug(unitList.size());
        System.assertEquals(7, unitList.size());

        // Call the method to add new units
        AdditionalApplicationController.createAppWithUnits(appNewUnits, unitList,true,false);

        
        
        // call the method with the app size 0
        AdditionalApplicationController.createAppWithUnits(appNewUnits.clone(false,false,false,false), new List<Unit__c>(),false,true);
		AdditionalApplicationController.createRevisitFee(insertedApps[0]);

    }
    
    /*
    @isTest
    static void createAppWithUnitsTest1(){
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

        // Create species discount product
        FObject speciesDiscount = new FObject('Product2', 1);
        speciesDiscount.setDefinition('Name','static value(Species Discount)');
        speciesDiscount.setDefinition('ProductCode','static value(SPECIESDISCOUNT)');
        speciesDiscount.setDefinition('IsActive','static value(true)');
        speciesDiscount.setDefinition('Standard_Price__c','static value(-59.50)');
        speciesDiscount.setDefinition('Species_Discount_Extra__c','static value(-88.00)');
        speciesDiscount.insertRecords(true);


        // Create Application 2 with update type = update to flock size
        FObject application2 = DataFactory.getDefNewApplications();
        application2.setDefinition('Existing_Member__c', 'static value(Yes)');
        application2.setDefinition('Application_Type__c', 'static value(Update)');
        application2.setDefinition('Update_Type__c', 'static value(Update to flock size)');
        application2.setDefinition('Payment_Method__c', 'static value(BACS)');
        application2.insertRecords(true);
        
        List<Application__c> insertedApps = FObject.getInsertedRecords('Application__c');
        Application__c appUpdateFlock = new Application__c();
        for(Application__c app : insertedApps){
            app.Id = null;
            if(app.Update_Type__c == 'Update to flock size'){
                appUpdateFlock = app;
                // below has been commented out as card payment has not been enabled
                //app.Payment_Method__c = 'Card';
            }
            
        }
        // Create Units
        List<Unit__c> unitList = new List<Unit__c>();
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = appUpdateFlock.Site__c;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unitList.add(unit1);
        insert unitList;


        // Call the method to update flock size
        AdditionalApplicationController.createAppWithUnits(appUpdateFlock, unitList);

        // call the method with unit size 0
        AdditionalApplicationController.createAppWithUnits(null, new List<Unit__c>());
    }
*/
    @isTest
    static void getPoultryUnitsTest() {
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

        // Call method to get poultry units
        AdditionalApplicationController.getPoultryUnits(accounts[0].Id);

        // call method to get poultry units with site id = null
        AdditionalApplicationController.getPoultryUnits(null);

    }

    @isTest
    static void getNewUnitNumberTest() {
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

        // Call method to get new unit number
        AdditionalApplicationController.getNewUnitNumber(accounts[0].Id);


    }
}