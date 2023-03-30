public class InvoicePDFController {
    public Application__c currentRecord{get;set;}

    public InvoicePDFController() {
        currentRecord = [SELECT Id, Name, Applicant_Full_Name__c, Site_Name__c, Head_Office__r.Name, Head_Office__r.BillingStreet, Head_Office__r.BillingCity, Head_Office__r.County__c, Head_Office__r.BillingCountry, Head_Office__r.BillingPostalcode, Invoice_Date__c, Payment_Due_Date__c, Payment_Reference__c, VAT_Registration_Number__c, Head_Office__r.ia_crm__IntacctID__c, PO_Number__c FROM Application__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
}