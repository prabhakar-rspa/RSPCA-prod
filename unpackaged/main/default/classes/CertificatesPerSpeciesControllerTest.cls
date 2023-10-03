@isTest
public class CertificatesPerSpeciesControllerTest {
    @isTest
    static void loadData(){
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
        
        Unit__c unit4 = new Unit__c();
        unit4.Account__c = site.Id;
        unit4.Name = '04';
        unit4.Business__c = 'Abattoir';
        unit4.Status__c = 'Certified';
        unit4.Animals__c = 'Salmon';
        units.add(unit4);
        
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
        
        Unit__c unit9 = new Unit__c();
        unit9.Account__c = site.Id;
        unit9.Name = '05';
        unit9.Business__c = 'Hatchery';
        unit6.Status__c = 'Certified';
        unit9.Animals__c = 'List';
        Unit9.Animals_List__c = 'Turkey Poults';
        Unit9.Own_Transport__c = true;
        units.add(unit9);
        
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
        newapp5.Unit__c = units[6].Id;
        Insert newapp5;
        
        Application_Unit__c newapp6 = new Application_Unit__c();
        newapp6.Application__c = newApplication.Id;
        newapp6.Unit__c = units[7].Id;
        Insert newapp6;
         
        Application_Unit__c newapp7 = new Application_Unit__c();
        newapp7.Application__c = newApplication.Id;
        newapp7.Unit__c = units[8].Id;
        Insert newapp7;
        
       
        List<Application_Unit__c> obj = [SELECT Id,Name,Application__c,Application__r.Name,Application__r.Stage__c,Application__r.Assessment_Approved_By_Assessor_Date__c,Application__r.Assessment_Date__c, Application__r.Previous_Assessment_Date__c,Application__r.Site__c, Application__r.Site__r.Name,Application__r.Status__c,Animals__c FROM Application_Unit__c WHERE Application__r.Site__c =:site.Id AND Application__r.Assessment_Approved_By_Certifier_Date__c != NULL AND Animals__c ='Turkeys' ORDER BY Application__r.Name DESC LIMIT 1];
        System.debug('obj '+obj);
        
        PageReference pageRef = Page.SupplyChainCertificateSpecies;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', site.Id);
        ApexPages.currentPage().getParameters().put('species', 'Salmon');
        
        // Instantiate a new controller with all parameters in the page
        CertificatesPerSpeciesController controller = new CertificatesPerSpeciesController(); 
        controller.getSupplyChainUnits();
        controller.getTroutAnimalScheme();
        controller.getTroutAnimals();
        controller.getTroutRearingSystems();
        controller.getAllAnimalScheme();
        controller.getAllAnimals();
        controller.getAllAnimalRearingSystems();
        controller.getSCISchemeTexts();
        controller.getSCISchemeTitle();
        system.assert(controller.currentRecord != null && controller.currentRecord.Id == site.Id);
    }
}