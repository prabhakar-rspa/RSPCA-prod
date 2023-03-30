@isTest
public class AccountTriggerHandlerTest {
    @isTest
    static void createSiteNumberTest() {
        // Create Head office account
        FObject headOffice = DataFactory.getDefHeadOfficeAccounts();
        headOffice.setDefinition('Head_Office_Number__c', 'static value(1234)');// Set Head Office Number
        headOffice.insertRecords(true);
        //AccountTriggerHandler.firstRunBeforeUpdate = true;
        // Create Site 1 account with existing Site number
        FObject site1 = DataFactory.getDefSiteAccounts();
        site1.setDefinition('ParentId', 'static lookup(Account) field(Site) value(HeadOffice) source(forceea)');
        site1.setDefinition('Site_Number__c', 'static value(0001)');
        site1.insertRecords(true);

        //AccountTriggerHandler.firstRunBeforeUpdate = true;
        // Create Site 2 account with generate site number checked
        FObject site2 = DataFactory.getDefSiteAccounts();
        site2.setDefinition('ParentId', 'static lookup(Account) field(Site) value(HeadOffice) source(forceea)');
        site2.setDefinition('Generate_Site_Number__c', 'static value(true)');
        site2.insertRecords(true);

        
    }
    @isTest
    static void createHeadOfficeNumberTest() {
        // Create Head Office 1 account with head office number populated
        FObject headOffice1 = DataFactory.getDefHeadOfficeAccounts();
        headOffice1.setDefinition('Head_Office_Number__c', 'static value(1234)');
        headOffice1.insertRecords(true);

        //AccountTriggerHandler.firstRunBeforeUpdate = true;
        // Create Head Office 2 account with generate head office number checked
        FObject headOffice2 = DataFactory.getDefHeadOfficeAccounts();
        headOffice2.setDefinition('Generate_Head_Office_Number__c', 'static value(true)');
        headOffice2.insertRecords(true);

    }
}