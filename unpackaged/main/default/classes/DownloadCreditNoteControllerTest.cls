@isTest
public class DownloadCreditNoteControllerTest {
	@testSetup
    static void loadData(){
         Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.AccountId = act.Id;
        opp.ia_crm__Intacct_Transaction__c = 'Sales Credit Note';
        insert opp;
    }
    @isTest
    static void testMetho1(){
        Opportunity opp = [SELECT Id FROM Opportunity limit 2];
        ApexPages.currentPage().getParameters().put('id',opp.Id);
        DownloadCreditNoteController controller = new DownloadCreditNoteController();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        controller = new DownloadCreditNoteController(sc);
        system.Assert(controller.allowedToDownload);

    }
}