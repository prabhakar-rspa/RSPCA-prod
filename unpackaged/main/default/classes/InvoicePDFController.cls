public class InvoicePDFController {
    public Application__c currentRecord{get;set;}
    public Date EndDate{get;set;}
    public Date startDate{get;set;}
    public InvoicePDFController(ApexPages.StandardController controller) {
        currentRecord = [
            SELECT Id, Name, Applicant_Full_Name__c, Site_Name__c, Head_Office__r.Name, 
            Head_Office__r.BillingStreet, Head_Office__r.BillingCity, Head_Office__r.County__c, 
            Head_Office__r.BillingCountry, Head_Office__r.BillingPostalcode, Invoice_Date__c, 
            Payment_Due_Date__c, Payment_Reference__c, VAT_Registration_Number__c, 
            Head_Office__r.ia_crm__IntacctID__c, PO_Number__c,Membership_Number__c,Site__r.Name,
            Membership_Expiry_Date__c,Application_Type__c,Custom_Invoice_Message__c,Site__c,
            RecordType.DeveloperName,Calculated_Stage__c,Site__r.Certificate_Issue_Date__c
            FROM Application__c 
            WHERE Id = :ApexPages.currentPage().getParameters().get('id')
        ];
        System.debug('====currentRecord==='+ currentRecord);
        if(currentRecord.Membership_Expiry_Date__c != null && currentRecord.RecordType.DeveloperName == 'Renewal'){
            if(currentRecord.Calculated_Stage__c == 'Renewal'){
                startDate = currentRecord.Membership_Expiry_Date__c;
                EndDate = currentRecord.Membership_Expiry_Date__c.addMonths(12);
            }else if(currentRecord.Site__c != null){//if(currentRecord.Calculated_Stage__c == 'Certification')
                startDate = currentRecord.Site__r.Certificate_Issue_Date__c;
                EndDate = currentRecord.Membership_Expiry_Date__c;
            }
            
        }
    }
    /*public InvoicePDFController() {
        
    }*/
}