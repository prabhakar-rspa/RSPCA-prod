@isTest
public class BulkRenewControllerTest {
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
            BulkRenewController.fetchCustomerContact(accounts[0].Id);
            
        }
        Test.stopTest();

    }

    @isTest
    static void fetchCustomerContactWithoutUserTest() {

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

            Test.startTest();
            BulkRenewController.fetchCustomerContact(accounts[0].Id);
            Test.stopTest();
        }

    }

    @isTest
    static void getSitesTest(){
        // Account
        FObject headOffice = DataFactory.getDefHeadOfficeAccounts();
        headOffice.insertRecords(true);

        FObject site = DataFactory.getDefSiteAccounts();
        site.setDefinition('ParentId', 'static lookup(Account) field(Site) value(HeadOffice) source(forceea)');
        site.insertRecords(true);
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        System.assertEquals(2, insertedAccounts.size());
        
        for(Account acc : insertedAccounts){
            if(acc.Site == 'HeadOffice'){
                BulkRenewController.getSites(acc.Id);
            }
        }
    }

    @isTest
    static void createBulkRenewalTest(){
        // Create System Admin User with Role to create the account
        FObject adminUser = new FObject('User', 1);
        adminUser.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
        adminUser.setDefinition('Alias','static value(testadm)');
        adminUser.setDefinition('LastName','static value(testadmin)');
        adminUser.setDefinition('UserName','static value(testadmin543434234324@test.com)');
        adminUser.setDefinition('Email','static value(testadmin@test.com)');
        adminUser.setDefinition('UserRoleId', 'random lookup(UserRole) source(forceea)');
        adminUser.insertRecords(true);
        List<User> insertedUsersList = FObject.getInsertedRecords('User');
        User insertedAdminUser = new User();
        for(User u : insertedUsersList){
            if(u.Alias == 'testadm'){
                insertedAdminUser = u;
            }
        }
        System.runAs(insertedAdminUser){
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

            // Create assessor user
            FObject assessorUser = new FObject('User', 1);
            assessorUser.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(Assessors) source(salesforce)');
            assessorUser.setDefinition('Alias','static value(testAs)');
            assessorUser.setDefinition('LastName','static value(Last)');
            assessorUser.setDefinition('UserName','static value(tester14364543@test.com)');
            assessorUser.setDefinition('Email','static value(tester@test.com)');
            assessorUser.setDefinition('Assessor__c', 'static value(true)');
            assessorUser.insertRecords(true);
            List<User> insertedUsers = FObject.getInsertedRecords('User');
            System.assertEquals(2, insertedUsers.size());
            User assessor = new User();
            for(User u : insertedUsers){
                if(u.Alias == 'testAs'){
                    assessor = u;
                }
            }

            // Account
            FObject headOffice = DataFactory.getDefHeadOfficeAccounts();
            headOffice.insertRecords(true);

            FObject site = DataFactory.getDefSiteAccounts();
            site.setDefinition('ParentId', 'static lookup(Account) field(Site) value(HeadOffice) source(forceea)');
            site.insertRecords(true);
            List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
            System.assertEquals(2, insertedAccounts.size());

            FObject conObj = new FObject('Contact', 1);
            conObj.setDefinition('AccountId', 'static lookup(Account) field(Site) value(Site) source(forceea)');
            conObj.setDefinition('Email', 'static value(randomEmail@test12456643.com.34342342332)');
            conObj.insertRecords(true);
            List<Contact> insertedContacts = FObject.getInsertedRecords('Contact');
            System.assertEquals(1, insertedContacts.size());
            
            Account headOfficeAccount = new Account();
            Account siteAccount = new Account();
            List<String> lstOfSiteIds = new List<String>();
            for(Account acc : insertedAccounts){
                acc.Primary_Contact__c = insertedContacts[0].Id;
                acc.Previous_Assessor__c = assessor.Id;
                if(acc.Site == 'HeadOffice'){
                    headOfficeAccount = acc;
                }else{
                    siteAccount = acc;
                    lstOfSiteIds.add(acc.Id);
                }
            }
            

            update insertedAccounts;
            
            

            // Create Units
            List<Unit__c> unitList = new List<Unit__c>();
            Unit__c unit1 = new Unit__c();
            unit1.Account__c = siteAccount.Id;
            unit1.Name = '01';
            unit1.Business__c = 'Supply Chain';
            unit1.Ingredients__c = 'Beef';
            unit1.Production__c = 'Processor';
            unit1.Order_Sizes__C = 'Single';
            unit1.Status__c = 'Certified';
            unitList.add(unit1);
            
            Unit__c unit2 = new Unit__c();
            unit2.Account__c = siteAccount.Id;
            unit2.Name = '02';
            unit2.Business__c = 'Supply Chain';
            unit2.Ingredients__c = 'Beef';
            unit2.Production__c = 'Processor';
            unit2.Order_Sizes__C = 'Single';
            unit2.Status__c = 'Certified';
            unitList.add(unit2);
            
            insert unitList;

            //BulkRenewController.createBulkRenewal(headOfficeAccount.Id, true, true, 'BACS', lstOfSiteIds);
        }
    }

    
}