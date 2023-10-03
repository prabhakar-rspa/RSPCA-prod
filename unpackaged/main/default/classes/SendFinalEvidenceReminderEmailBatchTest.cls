@isTest
public class SendFinalEvidenceReminderEmailBatchTest {

    @isTest
    static void FinalEvidenceReminderEmailTest(){
		Account act = TestDataFactory.createHeadOfficeAccount();
        Contact cnt = TestDataFactory.createContact(act.Id);
        act.Primary_Contact__c = cnt.Id;
        update act;
        Account site = TestDataFactory.createSiteAccount(act.Id);
        Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
		Application__c app = TestDataFactory.createApplication(recordTypeId, act.Id, act.Id, cnt.Id, true); 
        
        Test.startTest();
        SendFinalEvidenceReminderEmailBatch obj = new SendFinalEvidenceReminderEmailBatch();
        obj.execute(null);
        Test.stopTest();
         app =[SELECT Id,Final_Evidence_Email_Sent__c FROM Application__c WHERE Id=:app.Id];
        system.assert(app.Final_Evidence_Email_Sent__c);
    }
}