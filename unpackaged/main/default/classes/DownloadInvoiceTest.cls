@isTest
public class DownloadInvoiceTest {

    @isTest
    public static void DownloadInvoiceTest() {
        // Create joinFee product
        FObject joinFee = new FObject('Product2', 1);
        joinFee.setDefinition('Name','static value(Joining Fee)');
        joinFee.setDefinition('ProductCode','static value(JOINFEE)');
        joinFee.setDefinition('IsActive','static value(true)');
        joinFee.setDefinition('Standard_Price__c','static value(28.80)');
        joinFee.insertRecords(true);
        
        // Create revisitFee product
        FObject revisitFee = new FObject('Product2', 1);
        revisitFee.setDefinition('Name','static value(Revisit)');
        revisitFee.setDefinition('ProductCode','static value(REVISIT)');
        revisitFee.setDefinition('IsActive','static value(true)');
        revisitFee.setDefinition('Standard_Price__c','static value(114.24)');
        revisitFee.insertRecords(true);

        // Create Application
        FObject application = DataFactory.getDefNewApplications();
        application.setDefinition('Existing_Member__c', 'static value(No)');
        application.insertRecords(true);

        // do assertions
        List<Account> insertedAccounts = FObject.getInsertedRecords('Account');
        List<Contact> insertedCon = FObject.getInsertedRecords('Contact');
        List<Application__c> insertedApp = FObject.getInsertedRecords('Application__c');
        System.debug('Acc Size => ' + insertedAccounts.size());
        System.debug('Con Size => ' + insertedCon.size());
        System.debug('App Size => ' + insertedApp.size());
        System.assert(insertedAccounts.size() == 2);
        System.assert(insertedCon.size() == 1);
        System.assert(insertedApp.size() == 1);

        PageReference pageRef = Page.InvoicePDF;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Id', insertedApp[0].Id);

        // Instantiate a new controller with all parameters in the page
        //InvoicePDFController controller = new InvoicePDFController(); 

        ApexPages.StandardController sc = new ApexPages.StandardController(insertedApp[0]);
        DownloadInvoiceController downloadInvoice = new DownloadInvoiceController(sc);
    }
}