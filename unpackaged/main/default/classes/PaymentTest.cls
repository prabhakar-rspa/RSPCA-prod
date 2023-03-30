@isTest
public class PaymentTest {
    @isTest
    public static void PaymentTest() {
        // Create Application
        FObject application = DataFactory.getDefNewApplications();
        application.setDefinition('Existing_Member__c', 'static value(No)');
        application.insertRecords(true);

        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        List<Contact> insertedCon = FObject.getInsertedRecords('Contact');
        List<Application__c> insertedApp = FObject.getInsertedRecords('Application__c');
        System.debug('Acc Size => ' + insertedAccounts.size());
        System.debug('Con Size => ' + insertedCon.size());
        System.debug('App Size => ' + insertedApp.size());
        System.assert(insertedAccounts.size() == 2);
        System.assert(insertedCon.size() == 1);
        System.assert(insertedApp.size() == 1);

        asp04__Payment__c payment = new asp04__Payment__c();
        payment.Application__c = insertedApp[0].Id;
        payment.asp04__Amount__c = 1000;
        payment.asp04__Payment_Route_Selected__c = 'Card';
        payment.asp04__Payment_Stage__c = 'Awaiting submission';
        insert payment;
        payment.asp04__Payment_Stage__c = 'Collected from customer';
        update payment;
    }
}