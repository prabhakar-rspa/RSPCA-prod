@isTest
public class CreateCreditNoteControllerTest {

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
       revisitFee.setDefinition('Standard_Price__c','static value(114.24)');
       revisitFee.insertRecords(true);

       // Create Application
       FObject application = DataFactory.getDefNewApplications();
       application.setDefinition('Existing_Member__c', 'static value(No)');
       application.insertRecords(true);
    }

    @isTest
    static void getApplication(){
        // get application record
        List<Application__c> appList = [SELECT Id FROM Application__c];

        // run controller method
        Test.startTest();
        CreateCreditNoteController.getApplication(appList[0].Id);
        Test.stopTest();
    }

    @isTest
    static void getCreditLines(){
        // get application record
        List<Application__c> appList = [SELECT Id FROM Application__c];
        List<Application_Line_Item__c> appLineItems = [SELECT Id, Application__c, Product_Name__c, Quantity__c,List_Price__c, List_Price_Inc_Vat__c, Subtotal__c FROM Application_Line_Item__c];
        List<String> appLineIds = new List<String>();
        for(Application_Line_Item__c ali : appLineItems){
            appLineIds.add(ali.Id);
        }

        // run controller method
        Test.startTest();
        CreateCreditNoteController.getCreditLines(appLineIds);
        Test.stopTest();
    }
    /*
    @isTest
    static void createCreditNote(){
        // get application record
        List<Application__c> appList = [SELECT Id, Site_Name__c, Application_Type__c,Pricebook_Id__c, Applicant_Contact__c, Head_Office__c, Head_Office__r.BillingCountry FROM Application__c];
        List<Application_Line_Item__c> appLineItems = [SELECT Id, Application__c, Product_Name__c, Quantity__c,List_Price__c, List_Price_Inc_Vat__c, Subtotal__c FROM Application_Line_Item__c];
        List<String> appLineIds = new List<String>();
        for(Application_Line_Item__c ali : appLineItems){
            appLineIds.add(ali.Id);
        }

        // Get credit note line wrapper
        List<CreateCreditNoteController.CreditNoteLineWrapper> creditNoteLinesWrapper = CreateCreditNoteController.getCreditLines(appLineIds);

        // run controller method
        Test.startTest();
        CreateCreditNoteController.createCreditNote(appList[0], creditNoteLinesWrapper, 'Cancellation', 'ponumber', 'orderdetails');
        Test.stopTest();
    }*/
}