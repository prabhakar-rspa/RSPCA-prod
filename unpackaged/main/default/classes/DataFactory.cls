@isTest
public class DataFactory {
    // returns definitions for: Accounts 
    @isTest
    public static FObject getDefAccounts() {
        FObject result = new FObject('Account', 1);
        result.setDefinition('Name', 'static value(Company)');
        result.setDefinition('Name', 'serial type(number) from(1) step(1) scale(0)');
        result.setDefinition('Phone', 'random type(phone) format("(30) DDD dD-00-DD")');
        result.setDefinition('BillingCountry', 'static value(United Kingdom)');
        return result;
    }
    
    // returns definitions for: Accounts with headOffice record type
    @isTest
    public static FObject getDefHeadOfficeAccounts() {
        FObject result = getDefAccounts();
        result.setDefinition('RecordTypeId', 'static value(Head_Office)');
        result.setDefinition('Site', 'static value(HeadOffice)');
        return result;
    }

    // returns definitions for: Accounts with Site record type
    @isTest
    public static FObject getDefSiteAccounts() {
        FObject result = getDefAccounts();
        result.setDefinition('RecordTypeId', 'static value(Site)');
        result.setDefinition('Site', 'static value(Site)');
        return result;
    }

    // returns definitions for: Contact
    @isTest
    public static FObject getDefContact() {
        FObject result = new FObject('Contact', 1);
        result.setDefinition('Email', 'static value(test@test.com)');
        return result;
    }

    // returns definitions for: Application with inserted Head office and Site accounts
    @isTest
    public static FObject getDefApplications() {
        // initialize
        String objName = '';
        // Accounts
        objName = 'Account';
        FObject objHeadOffice = getDefHeadOfficeAccounts();
        objHeadOffice.insertRecords(true);
        FObject objSite = getDefSiteAccounts();
        objSite.setDefinition('ParentId', 'static lookup(Account) field(Site) value(HeadOffice) source(forceea)');
        objSite.insertRecords(true);
        // Contact
        FObject objCon = getDefContact(); 
        objCon.setDefinition('AccountId', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        objCon.insertRecords(true);
        // Application
        objName = 'Application__c';
        FObject objApplication = new FObject(objName, 1);
        objApplication.setDefinition('Site__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
        objApplication.setDefinition('Head_Office__c', 'static lookup(Account) field(Site) value(HeadOffice) source(forceea)');
        objApplication.setDefinition('Pricebook_Id__c', 'static value('+ Test.getStandardPricebookId()+')');
        objApplication.setDefinition('Applicant_Contact__c', 'random lookup(Contact) source(forceea)');
        return objApplication;
    }

    // returns definitions for: New Application record type with inserted Head office and Site accounts
    @isTest
    public static FObject getDefNewApplications() {
        FObject newApp = getDefApplications();
        newApp.setDefinition('RecordTypeId', 'static value(Applications)');
        return newApp;
    }

    // returns definitions for: Renewal Application record type with inserted Head office and Site accounts
    @isTest
    public static FObject getDefRenewalApplications() {
        FObject renewalApp = getDefApplications();
        renewalApp.setDefinition('RecordTypeId', 'static value(Renewal)');
        return renewalApp;
    }


    // Method to insert records
    public static void insertRecords(List<Fobject> fobjects) {
        for (FObject obj: fobjects) {
          obj.insertRecords(true);
        }
    }
}