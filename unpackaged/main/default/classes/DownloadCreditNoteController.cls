public with sharing class DownloadCreditNoteController {
  public Opportunity currentRecord { get; set; }
  public Boolean allowedToDownload { get; set; }
  public String downloadCreditNotePdfUrl { get; set; }
  public String todaysDate { get; set; }
  public DownloadCreditNoteController() {
    currentRecord = [
      SELECT Id, Name, ia_crm__Intacct_Transaction__c, Credit_Note_Number__c,Credit_Note_Approver__r.Name,
      Application__r.Membership_Number__c,Purchase_Order_Number__c,Amount,Vat__c,Amount_Inc_VAT__c,
      Account.Name,Account.BillingStreet,Account.BillingState,Account.BillingCity,Account.BillingCountry,
      Account.BillingPostalCode,Application__r.Sage_Invoice__r.Invoice_Number__c,Account.Sage_Intacct_Customer_Number__c
      FROM Opportunity
      WHERE Id = :ApexPages.currentPage().getParameters().get('id')
    ];
    todaysDate = String.valueOf(system.today());
  }
  public DownloadCreditNoteController(ApexPages.StandardController controller) {
    currentRecord = [
      SELECT Id, Name, ia_crm__Intacct_Transaction__c, Credit_Note_Number__c
      FROM Opportunity
      WHERE Id = :controller.getRecord().Id
    ];
    if (currentRecord.ia_crm__Intacct_Transaction__c == 'Sales Credit Note') {
      allowedToDownload = true;
      downloadCreditNotePdfUrl =
        System.URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/DownloadCreditNotePdf' +
        '?id=' +
        currentRecord.Id;
    } else {
      allowedToDownload = false;
    }
  }
}