@isTest
public class CertificatesControllerTest {

    @isTest
    public static void supplyChainCertificateTest() {
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;
        
        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(42);
        insert site;
        
        Application__c newApplication = new Application__c();
        newApplication.Site__c = site.Id;
        newApplication.Head_Office__c = act.Id;
        newApplication.Assessment_Approved_By_Certifier_Date__c = System.today() + 2;
        newApplication.Assessment_Date__c = System.today() + 1;
        insert newApplication; 
        
        // Create Checklist Template
        Checklist_Template__c ChecklistTemplateObj = new Checklist_Template__c();
        ChecklistTemplateObj.Name = 'Salmon Test';
        ChecklistTemplateObj.Species__c = 'Salmon';
        ChecklistTemplateObj.Animals_List__c = 'Salmon';
        ChecklistTemplateObj.Start_Date__c = System.Today();
        ChecklistTemplateObj.End_Date__c = System.Today() + 30;
        ChecklistTemplateObj.Scheme_Wording__c = 'Testing Salmon';
        insert ChecklistTemplateObj;
       
        // Create certified units
       
        
		Unit__c unit1 = new Unit__c();
        unit1.Account__c = site.Id;
        unit1.Name = '01';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Freshwater';
        unit1.Animals__c = 'Salmon';
        unit1.Number_Of_Animals__c = 100;
        unit1.Status__c = 'Certified';
        unit1.Rearing_System__c = 'n/a';
        insert unit1;
        
        Unit__c unit3 = new Unit__c();
        unit3.Account__c = site.Id;
        unit3.Name = '01';
        unit3.Business__c = 'Supply Chain';
        unit3.Ingredients__c = 'Beef';
        unit3.Production__c = 'Processor';
        unit3.Order_Sizes__C = 'Single';
        unit3.Status__c = 'Certified';
        insert unit3;

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = site.Id;
        unit2.Name = '02';
        unit2.Business__c = 'Supply Chain';
        unit2.Ingredients__c = 'Beef';
        unit2.Production__c = 'Processor';
        unit2.Order_Sizes__C = 'Single';
        unit2.Status__c = 'Certified';
        insert unit2;
        
        Unit__c unit4 = new Unit__c();
        unit4.Account__c = site.Id;
        unit4.Name = '04';
        unit4.Business__c = 'Abattoir';
        unit4.Status__c = 'Certified';
        unit4.Animals__c = 'Salmon';
       	insert unit4;
        
        Application_Unit__c apu = new Application_Unit__c();
        apu.Unit__c = unit1.Id;
        apu.Application__c = newApplication.Id;
        insert apu;
        
        Application_Unit__c apu1= new Application_Unit__c();
        apu1.unit__c = unit4.Id;
        apu1.application__c = newApplication.Id;
        insert apu1;

        PageReference pageRef = Page.SupplyChainCertificate;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', site.Id);
        ApexPages.currentPage().getParameters().put('species', 'Salmon');

        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getSupplyChainUnits();
        controller.getSCISchemeTexts();
        controller.getSCISchemeTitle();

        ApexPages.StandardController sc = new ApexPages.StandardController(site);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

        //Get Head Office Account for Bulk Certificates Download
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        
        site.ParentId = headOffice.Id;
        update site;
	
        ApexPages.StandardController sc1 = new ApexPages.StandardController(headOffice);
        BulkDownloadCertificatesController bulkDownloadCertificates = new BulkDownloadCertificatesController(sc1);


        
    }

    @isTest
    public static void troutCertificateTest() {
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;
        
        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(42);
        insert site;
        
        Application__c newApplication = new Application__c();
        newApplication.Site__c = site.Id;
        newApplication.Head_Office__c = act.Id;
        newApplication.Assessment_Approved_By_Certifier_Date__c = System.today() + 2;
        newApplication.Assessment_Date__c = System.today() + 1;
        insert newApplication; 
                // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = site.Id;
        unit1.Name = '01';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Freshwater';
        unit1.Animals__c = 'Trout';
        unit1.Number_Of_Animals__c = 100;
        unit1.Status__c = 'Certified';
        unit1.Rearing_System__c = 'n/a';
        insert unit1;

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = site.Id;
        unit2.Name = '02';
        unit2.Business__c = 'Producer';
        unit2.Production__c = 'Freshwater';
        unit2.Animals__c = 'Trout';
        unit2.Number_Of_Animals__c = 100;
        unit2.Status__c = 'Certified';
        unit2.Rearing_System__c = 'n/a';
        insert unit2;
        
         // Create Checklist Template
        Checklist_Template__c ChecklistTemplateObj = new Checklist_Template__c();
        ChecklistTemplateObj.Name = 'Trout Test';
        ChecklistTemplateObj.Species__c = 'Trout';
        ChecklistTemplateObj.Animals_List__c = 'Trout';
        ChecklistTemplateObj.Start_Date__c = System.Today();
        ChecklistTemplateObj.End_Date__c = System.Today() + 30;
        ChecklistTemplateObj.Scheme_Wording__c = 'Testing Trout';
        insert ChecklistTemplateObj;
		
        Application_Unit__c apu = new Application_Unit__c();
        apu.Unit__c = unit1.Id;
        apu.Application__c = newApplication.Id;
        insert apu;
        
        PageReference pageRef = Page.TroutCertificate;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', site.Id);
		ApexPages.currentPage().getParameters().put('species', 'Trout');
        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getTroutAnimalScheme();
        controller.getTroutAnimals();
        controller.getTroutRearingSystems();

        ApexPages.StandardController sc = new ApexPages.StandardController(site);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

        //Get Head Office Account for Bulk Certificates Download
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        
        site.ParentId = headOffice.Id;
        update site;

        ApexPages.StandardController sc1 = new ApexPages.StandardController(headOffice);
        BulkDownloadCertificatesController bulkDownloadCertificates = new BulkDownloadCertificatesController(sc1);
        
    }

    @isTest
    public static void nsfUkasCertificateTest1() {
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;
        
        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(42);
        insert site;
        
        Application__c newApplication = new Application__c();
        newApplication.Site__c = site.Id;
        newApplication.Head_Office__c = act.Id;
        newApplication.Assessment_Approved_By_Certifier_Date__c = System.today() + 2;
        newApplication.Assessment_Date__c = System.today() + 1;
        insert newApplication; 
                // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = site.Id;
        unit1.Name = '01';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Freshwater';
        unit1.Animals__c = 'Trout';
        unit1.Number_Of_Animals__c = 100;
        unit1.Status__c = 'Certified';
        unit1.Rearing_System__c = 'n/a';
        insert unit1;

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = site.Id;
        unit2.Name = '02';
        unit2.Business__c = 'Producer';
        unit2.Production__c = 'Freshwater';
        unit2.Animals__c = 'Trout';
        unit2.Number_Of_Animals__c = 100;
        unit2.Status__c = 'Certified';
        unit2.Rearing_System__c = 'n/a';
        insert unit2;
        
         // Create Checklist Template
        Checklist_Template__c ChecklistTemplateObj = new Checklist_Template__c();
        ChecklistTemplateObj.Name = 'Trout Test';
        ChecklistTemplateObj.Species__c = 'Trout';
        ChecklistTemplateObj.Animals_List__c = 'Trout';
        ChecklistTemplateObj.Start_Date__c = System.Today();
        ChecklistTemplateObj.End_Date__c = System.Today() + 30;
        ChecklistTemplateObj.Scheme_Wording__c = 'Testing Trout';
        insert ChecklistTemplateObj;
		
        Application_Unit__c apu = new Application_Unit__c();
        apu.Unit__c = unit1.Id;
        apu.Application__c = newApplication.Id;
        insert apu;

        // Create certified units
        Unit__c unit3 = new Unit__c();
        unit3.Account__c = site.Id;
        unit3.Name = '01';
        unit3.Business__c = 'Producer';
        unit3.Production__c = 'Producer';
        unit3.Animals__c = 'Chickens';
        unit3.Number_Of_Animals__c = 10000;
        unit3.Status__c = 'Certified';
        unit3.Rearing_System__c = 'Free Range';
        insert unit3;

        PageReference pageRef = Page.NSFUKASCertification;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', site.Id);
		ApexPages.currentPage().getParameters().put('species', 'Trout');
        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getAllAnimalScheme();
        controller.getAllAnimals();
        controller.getAllAnimalRearingSystems();

        ApexPages.StandardController sc = new ApexPages.StandardController(site);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

        //Get Head Office Account for Bulk Certificates Download
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        
        site.ParentId = headOffice.Id;
        update site;

        ApexPages.StandardController sc1 = new ApexPages.StandardController(headOffice);
        BulkDownloadCertificatesController bulkDownloadCertificates = new BulkDownloadCertificatesController(sc1);
        
    }
    @isTest
    public static void nsfUkasCertificateTest2() {
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;
        
        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(42);
        insert site;
        
        Application__c newApplication = new Application__c();
        newApplication.Site__c = site.Id;
        newApplication.Head_Office__c = act.Id;
        newApplication.Assessment_Approved_By_Certifier_Date__c = System.today() + 2;
        newApplication.Assessment_Date__c = System.today() + 1;
        insert newApplication; 
                // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = site.Id;
        unit1.Name = '01';
        unit1.Business__c = 'Producer';
        unit1.Production__c = 'Freshwater';
        unit1.Animals__c = 'Trout';
        unit1.Number_Of_Animals__c = 100;
        unit1.Status__c = 'Certified';
        unit1.Rearing_System__c = 'n/a';
        insert unit1;

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = site.Id;
        unit2.Name = '02';
        unit2.Business__c = 'Producer';
        unit2.Production__c = 'Freshwater';
        unit2.Animals__c = 'Trout';
        unit2.Number_Of_Animals__c = 100;
        unit2.Status__c = 'Certified';
        unit2.Rearing_System__c = 'n/a';
        insert unit2;
        
         // Create Checklist Template
        Checklist_Template__c ChecklistTemplateObj = new Checklist_Template__c();
        ChecklistTemplateObj.Name = 'Trout Test';
        ChecklistTemplateObj.Species__c = 'Trout';
        ChecklistTemplateObj.Animals_List__c = 'Trout';
        ChecklistTemplateObj.Start_Date__c = System.Today();
        ChecklistTemplateObj.End_Date__c = System.Today() + 30;
        ChecklistTemplateObj.Scheme_Wording__c = 'Testing Trout';
        insert ChecklistTemplateObj;
		
        Application_Unit__c apu = new Application_Unit__c();
        apu.Unit__c = unit1.Id;
        apu.Application__c = newApplication.Id;
        insert apu;
        // Create certified units
        Unit__c unit3 = new Unit__c();
        unit3.Account__c = site.Id;
        unit3.Name = '01';
        unit3.Business__c = 'Producer';
        unit3.Production__c = 'Producer';
        unit3.Animals__c = 'Ducks';
        unit3.Number_Of_Animals__c = 10000;
        unit3.Status__c = 'Certified';
        unit3.Rearing_System__c = 'Free Range';
        insert unit3;

        Unit__c unit4 = new Unit__c();
        unit4.Account__c = site.Id;
        unit4.Name = '02';
        unit4.Business__c = 'Producer';
        unit4.Production__c = 'Producer';
        unit4.Animals__c = 'Chickens';
        unit4.Number_Of_Animals__c = 20000;
        unit4.Status__c = 'Certified';
        unit4.Rearing_System__c = 'Organic';
        insert unit4;

        PageReference pageRef = Page.NSFUKASCertification;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', site.Id);
        ApexPages.currentPage().getParameters().put('species', 'Trout');

        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getAllAnimalScheme();
        controller.getAllAnimals();
        controller.getAllAnimalRearingSystems();

        ApexPages.StandardController sc = new ApexPages.StandardController(site);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

        //Get Head Office Account for Bulk Certificates Download
        FObject siteObj1 = DataFactory.getDefHeadOfficeAccounts();
        siteObj1.insertRecords(true);
        Account headOffice = [SELECT Id, Name, Membership_Number__c, ParentId FROM Account WHERE Site = 'HeadOffice' LIMIT 1];
        
        site.ParentId = headOffice.Id;
        update site;

        ApexPages.StandardController sc1 = new ApexPages.StandardController(headOffice);
        BulkDownloadCertificatesController bulkDownloadCertificates = new BulkDownloadCertificatesController(sc1);
        
    }
    @isTest
    public static void loadData(){
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;
        
        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(42);
        insert site;
        
        Application__c newApplication = new Application__c();
        newApplication.Site__c = site.Id;
        newApplication.Head_Office__c = act.Id;
        newApplication.Assessment_Approved_By_Certifier_Date__c = System.today() + 2;
        newApplication.Assessment_Date__c = System.today() + 1;
        insert newApplication; 
        
        Checklist_Template__c ChecklistTemplateObj = new Checklist_Template__c();
        ChecklistTemplateObj.Name = 'Salmon Test';
        ChecklistTemplateObj.Species__c = 'Salmon';
        ChecklistTemplateObj.Animals_List__c = 'Salmon';
        ChecklistTemplateObj.Start_Date__c = System.Today();
        ChecklistTemplateObj.End_Date__c = System.Today() + 30;
        ChecklistTemplateObj.Scheme_Wording__c = 'Testing Salmon';
        insert ChecklistTemplateObj;
        
       
        List<Unit__c> units = new List<Unit__c>();
        // Create certified units
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = site.Id;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unit1.Status__c = 'Certified';
        units.add(unit1);
        
        Unit__c unit2 = new Unit__c();
        unit2.Account__c = site.Id;
        unit2.Name = '02';
        unit2.Business__c = 'Supply Chain';
        unit2.Ingredients__c = 'Beef';
        unit2.Production__c = 'Processor';
        unit2.Order_Sizes__C = 'Single';
        unit2.Status__c = 'Certified';
        units.add(unit2);
        
        Unit__c unit3 = new Unit__c();
        unit3.Account__c = site.Id;
        unit3.Name = '03';
        unit3.Business__c = 'Producer';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Salmon';
        units.add(unit3);
        
        
        
        Unit__c unit5 = new Unit__c();
        unit5.Account__c = site.Id;
        unit5.Name = '05';
        unit5.Business__c = 'Catching';
        unit5.Status__c = 'Certified';
        unit5.Animals__c = 'Ducks';
        units.add(unit5);
        
        Unit__c unit6 = new Unit__c();
        unit6.Account__c = site.Id;
        unit6.Name = '05';
        unit6.Business__c = 'Hatchery';
        unit6.Status__c = 'Certified';
        unit6.Animals__c = 'Salmon';
        units.add(unit6);
        
        Unit__c unit7 = new Unit__c();
        unit7.Account__c = site.Id;
        unit7.Name = '05';
        unit7.Business__c = 'Haulier';
        unit7.Status__c = 'Certified';
        unit7.Animals__c = 'Salmon';
        unit7.Vehicle_Type__c = 'Wellboat';
        units.add(unit7);
        
        Unit__c unit8 = new Unit__c();
        unit8.Account__c = site.Id;
        unit8.Name = '05';
        unit8.Business__c = 'Haulier';
        unit8.Status__c = 'Certified';
        unit8.Animals__c = 'Salmon';
        unit8.Vehicle_Type__c = 'Helicopter';
        units.add(unit8);
        insert units;
        
        Application_Unit__c newapp = new Application_Unit__c();
        newapp.Application__c = newApplication.Id;
        newapp.Unit__c = units[0].Id;
        Insert newapp;
        
        Application_Unit__c newapp1 = new Application_Unit__c();
        newapp1.Application__c = newApplication.Id;
        newapp1.Unit__c = units[1].Id;
        Insert newapp1;
        
        Application_Unit__c newapp2 = new Application_Unit__c();
        newapp2.Application__c = newApplication.Id;
        newapp2.Unit__c = units[2].Id;
        Insert newapp2;
        
        Application_Unit__c newapp3 = new Application_Unit__c();
        newapp3.Application__c = newApplication.Id;
        newapp3.Unit__c = units[3].Id;
        Insert newapp3;
        
        Application_Unit__c newapp4 = new Application_Unit__c();
        newapp4.Application__c = newApplication.Id;
        newapp4.Unit__c = units[4].Id;
        Insert newapp4;
        
        Application_Unit__c newapp5 = new Application_Unit__c();
        newapp5.Application__c = newApplication.Id;
        newapp5.Unit__c = units[5].Id;
        Insert newapp5;
        
        PageReference pageRef = Page.NSFUKASCertification;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', site.Id);
		ApexPages.currentPage().getParameters().put('species', 'Salmon');
        // Instantiate a new controller with all parameters in the page
        CertificatesController controller = new CertificatesController(); 
        controller.getAllAnimalScheme();
        controller.getAllAnimals();
        controller.getAllAnimalRearingSystems();

        ApexPages.StandardController sc = new ApexPages.StandardController(site);
        DownloadCertificatesController downloadCertificates = new DownloadCertificatesController(sc);

    }
}