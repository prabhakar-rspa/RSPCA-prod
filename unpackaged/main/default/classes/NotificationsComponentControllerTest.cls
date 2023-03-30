@isTest
public class NotificationsComponentControllerTest {
    @testSetup static void setup() {

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
            // Lead record
            Lead l = new Lead(
                FirstName = 'first',
                LastName = 'last',
                Email = 'test@test.com',
                Company = 'TestCompany',
                Company_Industry__C = 'Fish'
            );
            insert l;
        
            // Site Account Record type
            String siteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
            // Head Office Account Record type
            String headOfficeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Head_Office').getRecordTypeId();

        

            // Account Records
            List<Account> accList = new List<Account>();
            Account headOffice = new Account(
                Name = 'Test Head Office',
                RecordTypeId = headOfficeRecordTypeId,
                Status__c = 'Member',
                Head_Office_Number__c = '4342',
                Active__c = true,
                OwnerId = insertedAdminUser.Id
            );
            Account site = new Account(
                Name = 'test Site',
                RecordTypeId = siteRecordTypeId,
                Company_Industry__C = 'Fish',
                Status__c = 'Member',
                Site_Number__c = '1245',
                OwnerId = insertedAdminUser.Id
            );
            accList.add(headOffice);
            accList.add(site);
            insert accList;

            // Contact Records
            Contact con = new Contact(
                FirstName = 'First',
                LastName = 'Last',
                Email = 'test324324325234@test.com',
                AccountId = site.Id
            );

            insert con;

            site.Primary_Contact__c = con.Id;

            update site;

            // Application Record
            Application__c app = new Application__c(
                Existing_Member__c = 'No',
                Stage__c = 'Application',
                Application_Type__c = 'New',
                Head_Office__c = headOffice.Id,
                Site__c = site.Id,
                No_Offences__c = true,
                Agreement__c = true,
                Agreement_Date__c = Date.today(),
                Signatory_Contact__c = con.Id,
                Payment_Method__c = 'BACS',
                Applicant_Contact__c = con.id
            );

            insert app;
        }

        
    }

    @isTest
    static void getEnquiresTest(){
        List<Lead> leadList = [SELECT Id, Name, Company, Company_Industry__c, CreatedDate, IsConverted FROM Lead WHERE IsConverted = false];
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getEnquires();
        test.stopTest();
    }

    @isTest
    static void getApplicationsTest(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getApplications();
        test.stopTest();
    }

    @isTest
    static void getPaidApplicationsTest(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getPaidApplications();
        test.stopTest();
    }

    @isTest
    static void getPaidCardApplicationsTest(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getPaidCardApplications();
        test.stopTest();
    }

    @isTest
    static void getPendingBacsChequeApplicationsTest(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getPendingBacsChequeApplications();
        test.stopTest();
    }

    @isTest
    static void getAllocationApplicationsTest(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Allocation';
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getAllocationApplications();
        test.stopTest();
    }

    @isTest
    static void getAssessorAllocationsTest(){
        //Get user
        User u = [SELECT Id, LastName, Email, Assessor__c FROM User WHERE Assessor__c = true LIMIT 1];
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Allocation';
            // update assessor field
            app.Assessor__c = u.Id;
            app.Allocation_Status__c = 'Pending';
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.assessorId = u.Id;
        obj.getAssessorAllocations();
        test.stopTest();
    }

    @isTest
    static void getAssessmentBookingsPendingTest(){
        //Get user
        User u = [SELECT Id, LastName, Email, Assessor__c FROM User WHERE Assessor__c = true LIMIT 1];
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Assessment';
            // update assessor field
            app.Assessor__c = u.Id;
            app.Allocation_Status__c = 'Accepted';
            app.Assessment_Date__c = null;
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.assessorId = u.Id;
        obj.getAssessmentBookingsPending();
        test.stopTest();
    }

    @isTest
    static void getAssessmentReportsPendingTest(){
        //Get user
        User u = [SELECT Id, LastName, Email, Assessor__c FROM User WHERE Assessor__c = true LIMIT 1];
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Assessment';
            // update assessor field
            app.Assessor__c = u.Id;
            app.Allocation_Status__c = 'Accepted';
            app.Assessment_Date__c = Date.today() + 14;
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.assessorId = u.Id;
        obj.getAssessmentReportsPending();
        test.stopTest();
    }

    @isTest
    static void getAssessorApprovalsPendingTest(){
        //Get user
        User u = [SELECT Id, LastName, Email, Assessor__c FROM User WHERE Assessor__c = true LIMIT 1];
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Compliance';
            // update assessor field
            app.Assessor__c = u.Id;
            app.Allocation_Status__c = 'Accepted';
            app.Assessment_Date__c = Date.today() + 14;
            app.Assessment_Checklist__c = 'test.com';
            app.Assessment_Report__c = 'test.com';
            app.DTA__c = 'Yes';
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.assessorId = u.Id;
        obj.getAssessorApprovalsPending();
        test.stopTest();
    }

    @isTest
    static void getRejectionApplicationsTest(){
        User u = [SELECT Id, LastName, Email, Assessor__c FROM User WHERE Assessor__c = true LIMIT 1];
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Compliance';
            // update assessor field
            app.Assessor__c = u.Id;
            app.Allocation_Status__c = 'Accepted';
            app.Assessment_Date__c = Date.today() + 14;
            app.Reject__c = true;
            app.Rejection_Date__c = Datetime.now().addHours(-48);
            app.Reason_for_rejection__c = 'No evidence';
            app.Assessment_Checklist__c = 'test.com';
            app.Assessment_Report__c = 'test.com';
            app.DTA__c = 'Yes';
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getRejectionApplications();
        test.stopTest();
    }

    @isTest
    static void getApprovalApplicationsOfficeTest(){
        User u = [SELECT Id, LastName, Email, Assessor__c FROM User WHERE Assessor__c = true LIMIT 1];
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Compliance';
            // update assessor field
            app.Assessor__c = u.Id;
            app.Allocation_Status__c = 'Accepted';
            app.Assessment_Date__c = Date.today() + 14;
            app.Assessment_Checklist__c = 'test.com';
            app.Assessment_Report__c = 'test.com';
            app.DTA__c = 'Yes';
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getApprovalApplicationsOffice();
        test.stopTest();
    }

    @isTest
    static void getApprovalApplicationsNSFTest(){
        User u = [SELECT Id, LastName, Email, Assessor__c FROM User WHERE Assessor__c = true LIMIT 1];
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Compliance';
            // update assessor field
            app.Assessor__c = u.Id;
            app.Allocation_Status__c = 'Accepted';
            app.Assessment_Date__c = Date.today() + 14;
            app.Assessment_Checklist__c = 'test.com';
            app.Assessment_Report__c = 'test.com';
            app.DTA__c = 'Yes';
        }
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getApprovalApplicationsNSF();
        test.stopTest();
    }

    @isTest
    static void getCertifiedApplicationsTest(){
        User u = [SELECT Id, LastName, Email, Assessor__c FROM User LIMIT 1];
        List<Application__c> appList = [SELECT Id, Name, Applicant_Contact__c, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c];
        
        for(Application__c app : appList){
            app.Paid__c = true;
            app.Stage__c = 'Certification';
            // update assessor field
            app.Allocation_Status__c = 'Accepted';
            app.Assessment_Date__c = Date.today() + 14;
            app.Application_Approved_By_Office__c = u.Id;
            app.Application_Approved_By_Certifier__c = u.Id;
            app.Assessment_Approved_By_Office__c = u.Id;
            app.Assessment_Approved_By_Assessor__c = u.Id;
            app.Assessment_Approved_By_Certifier__c = u.Id;
            app.Evidence_Approved_By_Office__c = u.Id;
            app.Evidence_Approved_By_Assessor__c = u.Id;
            app.Evidence_Approved_By_Certifier__c = u.Id;
            app.Approved_for_Renewal__c = true;
            app.DTA__c = 'Yes';
        }
        
        update appList;
        test.startTest();
        NotificationsComponentController obj = new NotificationsComponentController();
        obj.getCertifiedApplications();
        test.stopTest();
    }
}