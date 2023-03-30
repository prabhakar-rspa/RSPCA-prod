@isTest
public class OpportunityTriggerTest {
    @isTest
    public static void createOppTrigger() {
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
        insert opp;
    }
}