public with sharing class MemberCheckerController {
    @AuraEnabled
    public static Account getStatus (String membershipNumber) { //change the method
        System.debug(membershipNumber);
        Account a=null;
        List<Account> accounts = [Select Id, Status__c, Membership_Number__c from Account where Active__c=TRUE and Membership_Number__c=:membershipNumber and Status__c='MEMBER' limit 1];
        if(!accounts.isEmpty()){
            a=accounts[0];
        }
        return a;
    } 
}