@isTest
public class TransferControllerTest {
    /*
    @isTest
    public static void fetchCustomerContactWithUser() {
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
            //acc.setDefinition('Primary_Contact__c', 'random lookup(Contact) source(forceaa)');
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
            TransferController.fetchCustomerContact(accounts[0].Id);
            
        }
        Test.stopTest();
    }

    @isTest
    public static void fetchCustomerContactWithoutUser() {
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
        TransferController.fetchCustomerContact(accounts[0].Id);
    }

    @isTest
    public static void createTransferApplication() {
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
        revisitFee.setDefinition('Standard_Price__c','static value(119)');
        revisitFee.insertRecords(true);

        // Create species discount product
        FObject speciesDiscount = new FObject('Product2', 1);
        speciesDiscount.setDefinition('Name','static value(Species Discount)');
        speciesDiscount.setDefinition('ProductCode','static value(SPECIESDISCOUNT)');
        speciesDiscount.setDefinition('IsActive','static value(true)');
        speciesDiscount.setDefinition('Standard_Price__c','static value(-59.50)');
        speciesDiscount.setDefinition('Species_Discount_Extra__c','static value(-88.00)');
        speciesDiscount.insertRecords(true);

        // Create Head office account
        FObject headOffice = DataFactory.getDefHeadOfficeAccounts();
        headOffice.setDefinition('Head_Office_Number__c', 'static value(1234)');// Set Head Office Number
        headOffice.insertRecords(true);
        // Create Site 1 account with existing Site number
        FObject site1 = DataFactory.getDefSiteAccounts();
        site1.setDefinition('ParentId', 'static lookup(Account) field(Site) value(HeadOffice) source(forceea)');
        site1.setDefinition('Site_Number__c', 'static value(0001)');
        site1.insertRecords(true);

        List<Account> accounts = FObject.getInsertedRecords('Account');
        Account siteRecord = new Account();
        Account headOfficeRecord = new Account();
        for(Account acc : accounts){
            if(acc.Site_Number__c == '0001'){
                siteRecord = acc;
            }
            if(acc.Head_Office_Number__c == '1234'){
                headOfficeRecord = acc;
            }
        }
        // Create user for assessor
        FObject assessor = new FObject('User', 1);
        assessor.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
        //assessor.setDefinition('ContactId', 'random lookup(Contact) source(forceea)');
        assessor.setDefinition('Alias','static value(test)');
        assessor.setDefinition('LastName','static value(Last)');
        assessor.setDefinition('UserName','static value(tester5346435324455345@test.com)');
        assessor.setDefinition('Email','static value(tester@test.com)');
        assessor.setDefinition('Assessor__c', 'static value(true)');
        assessor.insertRecords(true);
        List<User> users = FObject.getInsertedRecords('User');

        // Create primary contact
        Contact c = new Contact();
        c.FirstName = 'first';
        c.LastName = 'last';
        c.Email = 'test@test.com';
        c.AccountId = siteRecord.Id;
        insert c;

        siteRecord.Primary_Contact__c = c.Id;
        siteRecord.Previous_Assessor__c = users[0].Id;

        update siteRecord;

        // Create Units
        List<Unit__c> unitList = new List<Unit__c>();
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = siteRecord.Id;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unit1.Status__c = 'Certified';
        unitList.add(unit1);

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = siteRecord.Id;
        unit2.Name = '02';
        unit2.Business__c = 'Abattoir';
        unit2.Animals__c = 'Beef Cattle';
        unit2.Production__c = 'Abattoir';
        unit1.Status__c = 'Certified';
        unitList.add(unit2);

        insert unitList;
        TransferController.getHeadOffice(siteRecord.Id, headOfficeRecord.Head_Office_Number__c);

        // Create transfer application
        FObject application = new FObject('Application__c', 1);
        application.setDefinition('Site__c', 'static lookup(Account) field(Site_Number__c) value(0001) source(forceea)');
        application.setDefinition('Head_Office__c', 'static lookup(Account) field(Head_Office_Number__c) value(1234) source(forceea)');
        application.setDefinition('RecordTypeId', 'static value(Renewal)');
        application.setDefinition('Renewal_Stage__c', 'static value(Renewal)');
        application.setDefinition('Existing_Member__c', 'static value(Yes)');
        application.setDefinition('Application_Type__c', 'static value(Transfer)');
        application.setDefinition('Payment_Method__c', 'static value(BACS)');
        application.setDefinition('Agreement__c', 'static value(true)');
        application.setDefinition('No_Offences__c', 'static value(true)');
        application.insertRecords(true);

        List<Application__c> insertedApps = FObject.getInsertedRecords('Application__c');

        Application__c application2 = insertedApps[0].clone(false,false,false,false);
        application2.Signatory_Contact__c = c.Id;
        application2.Applicant_Contact__c = c.Id;
        application2.Agreement_Date__c = Date.today();

        // Create independant transfer
        TransferController.createTransferApplication(application2, 'Independant', null, siteRecord);

        
    }*/
}