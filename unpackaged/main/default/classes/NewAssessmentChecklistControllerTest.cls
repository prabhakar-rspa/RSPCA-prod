@isTest
public class NewAssessmentChecklistControllerTest {
    @testSetup static void setup() {
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

         // Create processor/packer product
         FObject chickens = new FObject('Product2', 1);
         chickens.setDefinition('Name','static value(Chickens)');
         chickens.setDefinition('ProductCode','static value(CHICKEN)');
         chickens.setDefinition('IsActive','static value(true)');
         chickens.setDefinition('Standard_Price__c','static value(111.24)');
         chickens.setDefinition('Family','static value(Poultry)');
         chickens.setDefinition('Business__c', 'static value(Producer)');
         chickens.setDefinition('Animal__c','static value(Chickens)');
         chickens.setDefinition('Production__c', 'static value(Producer)');
         chickens.setDefinition('Pricing_Method__c', 'static value(Additional Quantity Price)');
         chickens.setDefinition('Quantity_Threshold__c', 'static value(30000)');
         chickens.setDefinition('Additional_Quantity_Price__c', 'static value(54.72)');
         chickens.insertRecords(true);
         
        // Create Application
        FObject application = DataFactory.getDefNewApplications();
        application.setDefinition('Existing_Member__c', 'static value(No)');
        application.insertRecords(true);
 
         // Create Units
         FObject unitObj = new FObject('Unit__c', 1);
         unitObj.setDefinition('Account__c', 'static lookup(Account) field(Site) value(Site) source(forceea)');
         unitObj.setDefinition('Name', 'static value(01)');
         unitObj.setDefinition('Business__c', 'static value(Producer)');
         unitObj.setDefinition('Production__c', 'static value(Producer)');
         unitObj.setDefinition('Animals__c', 'static value(Chickens)');
         unitObj.setDefinition('Rearing_System__c', 'static value(Free Range)');
         unitObj.setDefinition('Number_of_Animals__c', 'static value(25000)');
         unitObj.insertRecords(true);
 
         // Application Unit
         FObject appUnit = new FObject('Application_Unit__c', 1);
         appUnit.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
         appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
         appUnit.insertRecords(true);

         // Create Checklist Template Standard
        FObject ctsFobject = new FObject('Checklist_Template_Standard__c', 10);
        ctsFobject.insertRecords(true);

        List<Checklist_Template__c> ctList = FObject.getInsertedRecords('Checklist_Template__c');
        for(Checklist_Template__c ct : ctList){
            ct.Species__c = 'Chickens';
            ct.Status__c = 'Active';
        }
        update ctList;
    }

    @isTest
    static void getChecklistTemplates(){
        List<Application__c> appList = [SELECT Id FROM Application__c];
        Test.startTest();
        NewAssessmentChecklistController.getChecklistTemplates(appList[0].Id);
        Test.stopTest();
    }

    @isTest
    static void createAssessmentChecklist(){
        List<Application__c> appList = [SELECT Id FROM Application__c];
        List<Checklist_Template__c> ctList = [SELECT Id FROM Checklist_Template__c];
        List<String> checklistIds = new List<String>();
        for(Checklist_Template__c ct : ctList){
            checklistIds.add(ct.Id);
        }
        
        Test.startTest();
        NewAssessmentChecklistController.ChecklistDetail ChecklistDetail = NewAssessmentChecklistController.checkPreviousAssessmentChecklist(appList[0].Id,checklistIds);
        NewAssessmentChecklistController.createAssessmentChecklist(appList[0].Id,checklistIds,JSON.serialize(ChecklistDetail.AssessmentChecklistDetails));
        List<Assessments__c> assessments = [SELECT ID FROM Assessments__c];
        assessments[0].Status__c = 'Completed';
        update assessments[0];
        system.assert(assessments.size()>0);
        ChecklistDetail = NewAssessmentChecklistController.checkPreviousAssessmentChecklist(appList[0].Id,checklistIds);
        NewAssessmentChecklistController.createAssessmentChecklist(appList[0].Id,checklistIds,JSON.serialize(ChecklistDetail.AssessmentChecklistDetails));
        Test.stopTest();
    }
    
    @isTest
    static void nonComplianceCreationTest(){

		FObject application = DataFactory.getDefNewApplications();
        application.setDefinition('Existing_Member__c', 'static value(No)');
        application.insertRecords(true);

		// Application Unit
        FObject assessments = new FObject('Assessments__c', 1);
        assessments.setDefinition('Application__c', 'random lookup(Application__c) source(forceea)');
        //appUnit.setDefinition('Unit__c', 'random lookup(Unit__c) source(forceea)');
        assessments.setDefinition('Status__c', 'static value(Completed)');
        assessments.insertRecords(true);
        
        
            
		FObject acq = new FObject('Assessment_Checklist_Question__c', 1);
        acq.setDefinition('Assessment_Checklist__c', 'random lookup(Assessments__c) source(forceea)');
        acq.setDefinition('Compliant__c', 'static value(No)');
        acq.setDefinition('Evidence_Required__c', 'static value(Invoice )');
        acq.insertRecords(true);
        
        
        List<Assessments__c> assessmentsList = [SELECT Id, Status__c, Non_Compliances_Created__c, Application__c, Application_Assessor__c FROM Assessments__c];
        
        Test.startTest();
        NonComplianceCreation.createNonCompliance(assessmentsList);
        Test.stopTest();
    }
}