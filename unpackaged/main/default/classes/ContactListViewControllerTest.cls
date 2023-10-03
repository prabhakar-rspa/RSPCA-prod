@isTest
public class ContactListViewControllerTest {
	@testSetup
    static void loadData(){
        Account act = TestDataFactory.createHeadOfficeAccount();
        Contact cnt = TestDataFactory.createContact(act.Id);
        act.Primary_Contact__c = cnt.Id;
        update act;
        
        Id p = [select id from profile where name Like '%RSPCA Assured Community User Head Office%' limit 1].id;
        User community = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = cnt.Id,CompanyName = 'Test',
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        try{
        	insert community;
        }catch(exception ex){
            
        }
        Account site = TestDataFactory.createSiteAccount(act.Id);
    }
    @isTest
    static void testMethod1(){
        List<Contact> cnts = [SELECT Id,Name,AccountId FROM Contact limit 1];
        User community = [SELECT Id FROM User where contactId=:cnts[0].Id];
        Account site =  [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Site'];
        system.runAs(community) {
            String contacts = ContactListViewController.getContacts();
            ContactListViewController.updateContacts(JSON.serialize(cnts));
            ContactListViewController.getSiteAccounts(cnts[0].AccountId);
            Contact newContact = new Contact(LastName='Test contact',AccountId=site.Id);
            String newContactStr = ContactListViewController.createContact(JSON.serialize(newContact));
            newContact = (Contact)JSON.deserialize(newContactStr, Contact.class);
            system.assert(newContact.Id != null);
            ContactListViewController.deleteContacts(new List<String>{newContact.Id});
            ContactListViewController.getContactsToDelete(new List<String>{newContact.Id});
        }
    }
    @isTest
    static void testMethod1Error(){
        List<Contact> cnts = [SELECT Id,Name,AccountId FROM Contact limit 1];
        User community = [SELECT Id FROM User where contactId=:cnts[0].Id];
        Account site =  [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Site'];
        try{
            String contacts = ContactListViewController.getContacts();
        }catch(exception e){
            
        }
        system.runAs(community) {
            String contacts = ContactListViewController.getContacts();
            try{
            	ContactListViewController.updateContacts(contacts);
            }catch(exception e){
                
            }
            try{
            	ContactListViewController.getSiteAccounts('&&&');
            }catch(exception e){
                
            }
            Contact newContact = new Contact();
            try{
            	String newContactStr = ContactListViewController.createContact(JSON.serialize(newContact));
            }catch(exception e){
                
            }
            try{
            	ContactListViewController.deleteContacts(new List<String>{newContact.Id});
            }catch(exception e){
                
            }
        }
    }
}