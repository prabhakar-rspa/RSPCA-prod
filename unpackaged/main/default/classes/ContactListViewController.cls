public without sharing class ContactListViewController {
    @AuraEnabled
    public static string getContacts(){
        try {
            String userId = userInfo.getUserId();
            User currentUser = [SELECT Id,ContactId,CompanyName FROM User WHERE Id =:userId];
            Contact currentContact = [
                SELECT Id,Name,AccountId,Account.RecordTypeId,Account.RecordType.DeveloperName,Account.ParentId FROM Contact WHERE Id = :currentUser.ContactId
            ];
            
            Contacts contactDetail = new Contacts();
            contactDetail.headOfficeAccountId = '';
            contactDetail.siteAccountId = '';
            if(currentContact.Account.RecordType.DeveloperName == 'Site'){
                contactDetail.headOfficeAccountId = currentContact.Account.ParentId;
                contactDetail.siteAccountId = currentContact.AccountId;
            }else{
                contactDetail.headOfficeAccountId = currentContact.AccountId;
            }
            contactDetail.headOfficeContacts = [SELECT Id,Name,Email,Title,Phone,FirstName,LastName,Roles__c,MobilePhone,Primary_Contact__c,Account.Membership_Number__c,Preferred_Phone__c FROM Contact WHERE AccountId=:contactDetail.headOfficeAccountId ORDER BY Name];
            if(String.isNotBlank(contactDetail.siteAccountId)){
                contactDetail.siteContacts = [SELECT Id,Name,Email,Title,Phone,FirstName,LastName,Roles__c,MobilePhone,Primary_Contact__c,Account.Membership_Number__c,Preferred_Phone__c FROM Contact WHERE AccountId=:contactDetail.siteAccountId ORDER BY Name];
            }else{
                contactDetail.siteContacts = [SELECT Id,Name,Email,Title,Phone,FirstName,LastName,Roles__c,MobilePhone,Primary_Contact__c,Account.Membership_Number__c,Preferred_Phone__c FROM Contact WHERE Account.ParentId=:contactDetail.headOfficeAccountId ORDER BY Name];
            }
            Account headOfficeAccount = [SELECT Id,Primary_Contact__c from Account WHERE Id=:contactDetail.headOfficeAccountId];
            if(headOfficeAccount.Primary_Contact__c != null){
                contactDetail.primaryContact = [SELECT Id,Name,Email,Title,Phone,FirstName,LastName,Roles__c,MobilePhone,Primary_Contact__c,Account.Membership_Number__c,Preferred_Phone__c FROM Contact WHERE Id=:headOfficeAccount.Primary_Contact__c];
            }
            return JSON.serialize(contactDetail);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string updateContacts(String contacts){
        try {
            List<Contact> contactList = (List<Contact>)JSON.deserialize(contacts,List<Contact>.class);
            update contactList;
            return JSON.serialize(contactList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string createContact(String contactStr){
        try {
            Contact contact = (contact)JSON.deserialize(contactStr,Contact.Class);
            insert contact;
            return JSON.serialize(contact);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getContactsToDelete(List<String> contactIds){
        try {
            List<Contact> contactsToDelete = [SELECT Id,Name FROM Contact WHERE Id IN:contactIds];
            return JSON.serialize(contactsToDelete);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteContacts(List<String> contactIds){
        try {
            List<Contact> contactsToDelete = new List<Contact>();
            for(String contactId:contactIds){
                contactsToDelete.add(new Contact(Id=contactId));
            }
            delete contactsToDelete;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getSiteAccounts(String parentAccountId){
        try {
            List<Account> acccountList = [SELECT ID,NAME,Membership_Number__c FROM Account WHERE ParentId=:parentAccountId ORDER BY NAME];
            return JSON.serialize(acccountList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues() {
       List<String> listOfRolePicklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Roles__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry role : picklistValues) {
            listOfRolePicklistValues.add( role.getLabel());
        }
        return listOfRolePicklistValues;
    }

    // @AuraEnabled(cacheable=true)
    // public static AccountContactRelation getCurrentContact(){
    //     try {
    //         String userId = userInfo.getUserId();
    //         String currentContactId = [SELECT Id,ContactId,CompanyName FROM User WHERE Id =:userId].ContactId;

    //         AccountContactRelation contactinfo = [SELECT ContactId, Contact.Name , Account.Head_Office_Number__c FROM AccountContactRelation WHERE ContactId =: currentContactId AND Account.Head_Office_Number__c != null LIMIT 1];
    //         return contactinfo;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }


    public class Contacts{
        @AuraEnabled
        public List<Contact> headOfficeContacts;
        @AuraEnabled
        public List<Contact> siteContacts;
        @AuraEnabled
        public string headOfficeAccountId;
        @AuraEnabled
        public string siteAccountId;
        @AuraEnabled
        public Contact primaryContact;


    }
}