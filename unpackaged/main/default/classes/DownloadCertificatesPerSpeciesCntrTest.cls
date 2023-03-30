@isTest
public class DownloadCertificatesPerSpeciesCntrTest {
@testSetup
    static void loadData(){
        FObject siteObj = DataFactory.getDefSiteAccounts();
        siteObj.setDefinition('Certificate_Issue_Date__c', 'static value(2023-09-21)');
        siteObj.insertRecords(true);
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        System.assertEquals(1, insertedAccounts.size());
        insertedAccounts[0].Membership_Expiry_Date__c = Date.today() + 365;
        update insertedAccounts;
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        insertedAccounts[0].ParentId = headOffice.Id;
        update insertedAccounts[0];
        // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = insertedAccounts[0].Id;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unit1.Status__c = 'Certified';
        insert unit1;

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = insertedAccounts[0].Id;
        unit2.Name = '02';
        unit2.Business__c = 'Supply Chain';
        unit2.Ingredients__c = 'Beef';
        unit2.Production__c = 'Processor';
        unit2.Order_Sizes__C = 'Single';
        unit2.Status__c = 'Certified';
        insert unit2;
        
        Unit__c unit3 = new Unit__c();
        unit3.Account__c = insertedAccounts[0].Id;
        unit3.Name = '03';
        unit3.Business__c = 'Producer';
        unit3.Status__c = 'Certified';
        insert unit3;
        
    }
    @isTest
    static void testMethod1(){
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE ParentId != null];
        ApexPages.StandardController sc = new ApexPages.StandardController(headOffice);
        DownloadCertificatesPerSpeciesController downloadCertificates = new DownloadCertificatesPerSpeciesController(sc);
        system.assert(downloadCertificates.sciCertificateList != null && downloadCertificates.sciCertificateList.size()>0) ;
        system.assert(downloadCertificates.supplyChainCertificateList != null && downloadCertificates.supplyChainCertificateList.size()>0) ;

    }
}