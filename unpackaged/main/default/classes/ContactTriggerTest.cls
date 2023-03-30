@isTest
public class ContactTriggerTest {
    @isTest
    public static void leadConvertTest() {
        Lead l = new Lead();
        l.FirstName = 'first';
        l.LastName = 'last';
        l.Email = 'test@test.com';
        l.Company = 'TEST';

        insert l;

        l.LogEnquiryConfirmation__c = true;

        update l;

        Standard__c s = new Standard__c(Name = 'Test', Standard_Link__c = 'test.com');
        insert s;

        Enquiry_Standard__c es = new Enquiry_Standard__c(Standard__c = s.Id, Lead__c = l.Id);
        insert es;

        Contact c = new Contact();
        c.FirstName = 'first';
        c.LastName = 'last';
        c.Email = 'test@test.com';
        c.ConvertedLeadID__c = l.Id;

        insert c;
    }
}