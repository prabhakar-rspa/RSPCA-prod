public class DownloadInvoiceController {
    // current record of from the current page
    public Application__c currentRecord{get;set;}

    // Invoice Visualforce URL's with currentRecord.Id passed to it
    public String invoiceURL{get;set;}

    public DownloadInvoiceController(ApexPages.StandardController controller) {
        currentRecord = [SELECT Id, Name FROM Application__c WHERE Id = :controller.getRecord().Id];
         
        // Generating the URL's for the certificates
        invoiceURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/InvoicePDF'+'?id='+currentRecord.Id;
    }
}