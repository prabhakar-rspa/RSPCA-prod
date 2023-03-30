@isTest
public class LeadTest {
    @isTest
    public static void logEnquiryConfirmation() {
        Lead l = new Lead();
        l.FirstName = 'first';
        l.LastName = 'last';
        l.Email = 'test@test.com';
        l.Company = 'TEST';

        insert l;

        l.LogEnquiryConfirmation__c = true;

        update l;
    }
}