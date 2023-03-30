@isTest
public class RecordDetailUserPhotoControllerTest {
    @isTest
    static void fetchUserDetailTest() {
        // Create System Admin User with Role to create the account
        FObject adminUser = new FObject('User', 1);
        adminUser.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
        adminUser.setDefinition('Alias','static value(testadm)');
        adminUser.setDefinition('LastName','static value(testadmin)');
        adminUser.setDefinition('UserName','static value(testadmin543434234324@test.com)');
        adminUser.setDefinition('Email','static value(testadmin@test.com)');
        adminUser.setDefinition('UserRoleId', 'random lookup(UserRole) source(forceea)');
        adminUser.setDefinition('Assessor__c', 'static value(true)');
        adminUser.insertRecords(true);
        List<User> insertedUsers = FObject.getInsertedRecords('User');
        User insertedAdminUser = new User();
        for(User u : insertedUsers){
            if(u.Alias == 'testadm'){
                insertedAdminUser = u;
            }
        }
        System.runAs(insertedAdminUser){
            // Application Record
            FObject newApp = DataFactory.getDefNewApplications();
            newApp.insertRecords(true);
            List<Application__c> applications = FObject.getInsertedRecords('Application__c');

            Application__c app = applications[0];
            app.Assessor__c = insertedAdminUser.Id;
            update app;
            
            Test.startTest();
            RecordDetailUserPhotoController.fetchUserDetail(app.Id,'Assessor__c');
            Test.stopTest();
        }
    }
}