@isTest
public class CertificatesControllerTest {

    @isTest
    public static void supplyChainCertificateTest() {
        //Create Account
        FObject siteObj = DataFactory.getDefSiteAccounts();
        siteObj.setDefinition('Certificate_Issue_Date__c', 'static value(2023-09-21)');
        siteObj.insertRecords(true);
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        System.assertEquals(1, insertedAccounts.size());
        insertedAccounts[0].Membership_Expiry_Date__c = Date.today() + 365;
        update insertedAccounts;

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

        PageReference pageRef = Page.SupplyChainCertificate;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', insertedAccounts[0].Id);

        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getSupplyChainUnits();

        ApexPages.StandardController sc = new ApexPages.StandardController(insertedAccounts[0]);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

        //Get Head Office Account for Bulk Certificates Download
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        
        insertedAccounts[0].ParentId = headOffice.Id;
        update insertedAccounts[0];

        ApexPages.StandardController sc1 = new ApexPages.StandardController(headOffice);
        BulkDownloadCertificatesController bulkDownloadCertificates = new BulkDownloadCertificatesController(sc1);


        
    }

    @isTest
    public static void troutCertificateTest() {
        //Create Account
        FObject siteObj = DataFactory.getDefSiteAccounts();
        siteObj.setDefinition('Certificate_Issue_Date__c', 'static value(2023-09-21)');
        siteObj.insertRecords(true);
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        System.assertEquals(1, insertedAccounts.size());
        insertedAccounts[0].Membership_Expiry_Date__c = Date.today() + 365;
        update insertedAccounts;

        // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = insertedAccounts[0].Id;
        unit1.Name = '01';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Freshwater';
        unit1.Animals__c = 'Trout';
        unit1.Number_Of_Animals__c = 100;
        unit1.Status__c = 'Certified';
        unit1.Rearing_System__c = 'n/a';
        insert unit1;

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = insertedAccounts[0].Id;
        unit2.Name = '02';
        unit2.Business__c = 'Producer';
        unit2.Production__c = 'Freshwater';
        unit2.Animals__c = 'Trout';
        unit2.Number_Of_Animals__c = 100;
        unit2.Status__c = 'Certified';
        unit2.Rearing_System__c = 'n/a';
        insert unit2;

        PageReference pageRef = Page.TroutCertificate;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', insertedAccounts[0].Id);

        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getTroutAnimalScheme();
        controller.getTroutAnimals();
        controller.getTroutRearingSystems();

        ApexPages.StandardController sc = new ApexPages.StandardController(insertedAccounts[0]);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

        //Get Head Office Account for Bulk Certificates Download
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        
        insertedAccounts[0].ParentId = headOffice.Id;
        update insertedAccounts[0];

        ApexPages.StandardController sc1 = new ApexPages.StandardController(headOffice);
        BulkDownloadCertificatesController bulkDownloadCertificates = new BulkDownloadCertificatesController(sc1);
        
    }

    @isTest
    public static void nsfUkasCertificateTest1() {
        //Create Account
        FObject siteObj = DataFactory.getDefSiteAccounts();
        siteObj.setDefinition('Certificate_Issue_Date__c', 'static value(2023-09-21)');
        siteObj.insertRecords(true);
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        System.assertEquals(1, insertedAccounts.size());
        insertedAccounts[0].Membership_Expiry_Date__c = Date.today() + 365;
        update insertedAccounts;

        // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = insertedAccounts[0].Id;
        unit1.Name = '01';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Producer';
        unit1.Animals__c = 'Chickens';
        unit1.Number_Of_Animals__c = 10000;
        unit1.Status__c = 'Certified';
        unit1.Rearing_System__c = 'Free Range';
        insert unit1;

        PageReference pageRef = Page.NSFUKASCertification;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', insertedAccounts[0].Id);

        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getAllAnimalScheme();
        controller.getAllAnimals();
        controller.getAllAnimalRearingSystems();

        ApexPages.StandardController sc = new ApexPages.StandardController(insertedAccounts[0]);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

        //Get Head Office Account for Bulk Certificates Download
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        
        insertedAccounts[0].ParentId = headOffice.Id;
        update insertedAccounts[0];

        ApexPages.StandardController sc1 = new ApexPages.StandardController(headOffice);
        BulkDownloadCertificatesController bulkDownloadCertificates = new BulkDownloadCertificatesController(sc1);
        
    }
    @isTest
    public static void nsfUkasCertificateTest2() {
        //Create Account
        FObject siteObj = DataFactory.getDefSiteAccounts();
        siteObj.setDefinition('Certificate_Issue_Date__c', 'static value(2023-09-21)');
        siteObj.insertRecords(true);
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        System.assertEquals(1, insertedAccounts.size());
        insertedAccounts[0].Membership_Expiry_Date__c = Date.today() + 365;
        update insertedAccounts;

        // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = insertedAccounts[0].Id;
        unit1.Name = '01';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Producer';
        unit1.Animals__c = 'Ducks';
        unit1.Number_Of_Animals__c = 10000;
        unit1.Status__c = 'Certified';
        unit1.Rearing_System__c = 'Free Range';
        insert unit1;

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = insertedAccounts[0].Id;
        unit2.Name = '02';
        unit2.Business__c = 'Producer';
        unit2.Production__c = 'Producer';
        unit2.Animals__c = 'Chickens';
        unit2.Number_Of_Animals__c = 20000;
        unit2.Status__c = 'Certified';
        unit2.Rearing_System__c = 'Organic';
        insert unit2;

        PageReference pageRef = Page.NSFUKASCertification;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', insertedAccounts[0].Id);

        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getAllAnimalScheme();
        controller.getAllAnimals();
        controller.getAllAnimalRearingSystems();

        ApexPages.StandardController sc = new ApexPages.StandardController(insertedAccounts[0]);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

        //Get Head Office Account for Bulk Certificates Download
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        
        insertedAccounts[0].ParentId = headOffice.Id;
        update insertedAccounts[0];

        ApexPages.StandardController sc1 = new ApexPages.StandardController(headOffice);
        BulkDownloadCertificatesController bulkDownloadCertificates = new BulkDownloadCertificatesController(sc1);
        
    }
}