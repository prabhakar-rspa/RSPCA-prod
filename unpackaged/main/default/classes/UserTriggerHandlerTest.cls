@isTest(SeeAllData = true)
public class UserTriggerHandlerTest {

    static testmethod void SendCommunityInviteEmailTest(){
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Account';
        act.Status__c = 'ENQUIRY';
        insert act;

        Contact cnt = new Contact();
        cnt.AccountId = act.Id;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='RSPCA Assured Community User Head Office']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com', ContactId=cnt.Id);
        test.startTest();
        insert u;
        test.stopTest();
    }
}