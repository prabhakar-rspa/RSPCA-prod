public class CreateCreditNoteController {

    @AuraEnabled
    public static Application__c getApplication(String recordId){
        Application__c application = [SELECT Id, Site__c, Site_Name__c, Head_Office__c, Applicant_Contact__c,  Application_Type__c, Sage_Invoice__c, Pricebook_Id__c FROM Application__c WHERE Id =:recordId];

        return application;
    }

    // replace AccountNumber with Sage_Intacct_Customer_Number__c
    @AuraEnabled
    public static Opportunity getInvoice(String recordId){
        Opportunity opp = [SELECT Id, Name, Amount, Amount_Inc_VAT__c, VAT__c, Invoice_Number__c, Account.Sage_Intacct_Customer_Number__c, Application__r.Membership_Number__c, Account.BillingCountry FROM Opportunity WHERE Id =:recordId];
        return opp;
    }

    @AuraEnabled
    public static List<OpportunityLineItem> getInvoiceLineItems(String recordId){
        List<OpportunityLineItem> oppLines = [SELECT Id,Opportunity.Application__r.Name, OpportunityId, Product2.Name, Quantity, UnitPrice, TotalPrice, Total_Price_Inc_VAT__c FROM OpportunityLineItem WHERE OpportunityId = :recordId];
        return oppLines;
    }

    @AuraEnabled
    public static List<CreditNoteLineWrapper> getCreditLines(List<String> oppLineIds){
        List<OpportunityLineItem> oppLines = [SELECT Id, OpportunityId, Product2Id, Product2.Name, Quantity, UnitPrice, TotalPrice, Total_Price_Inc_VAT__c FROM OpportunityLineItem WHERE Id IN:oppLineIds];
        
        List<CreditNoteLineWrapper> creditNoteLines = new List<CreditNoteLineWrapper>();
        for(OpportunityLineItem lineItem : oppLines){
            CreditNoteLineWrapper cnl = new CreditNoteLineWrapper();
            cnl.productName = lineItem.Product2.Name;
            cnl.oppLineId = lineItem.Id;
            cnl.listPrice = lineItem.UnitPrice;
            cnl.maxListPrice = lineItem.UnitPrice;
            cnl.quantity = lineItem.Quantity;
            cnl.maxQuantity = lineItem.Quantity;
            cnl.productId = lineItem.Product2Id;
            creditNoteLines.add(cnl);
        }

        return creditNoteLines;
    }

    @AuraEnabled
    public static Opportunity createCreditNote(Application__c application, List<CreditNoteLineWrapper> creditNoteLinesWrapper, String creditNoteReason, String purchaseOrder, String creditNoteDetails){
        if(application != null && creditNoteLinesWrapper != null && creditNoteReason != null){
            // get Order Entry Record Type for opportunity
            Id orderEntryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OrderEntry').getRecordTypeId();
            
            String creditNoteDate = Datetime.now().format('dd/MM/yyyy');
            Opportunity creditNoteOpp = new Opportunity();
            creditNoteOpp.Name = application.Site_Name__c + ' ' + application.Application_Type__c + ' ' + creditNoteDate + ' Credit Note';
            creditNoteOpp.CloseDate = Date.today();
            creditNoteOpp.AccountId = application.Head_Office__c;
            creditNoteOpp.StageName = 'Prospecting';
            creditNoteOpp.Pricebook2Id = application.Pricebook_Id__c;
            creditNoteOpp.Application__c = application.Id;
            creditNoteOpp.ia_crm__Intacct_Transaction__c = 'Sales Credit Note';
            creditNoteOpp.RecordTypeId = orderEntryRecordTypeId;
            creditNoteOpp.Credit_Reason__c = creditNoteReason;
            creditNoteOpp.Tax_Point_Date__c = Date.today();
            creditNoteOpp.Purchase_Order_Number__c = purchaseOrder;
            creditNoteOpp.Credit_Note_Details__c = creditNoteDetails;
            if(application.Applicant_Contact__c != null){
                creditNoteOpp.ia_crm__Bill_to__c = application.Applicant_Contact__c;
            }

            insert creditNoteOpp;

            
            List<OpportunityLineItem> oppProdToInsert = new List<OpportunityLineItem>();
            for(CreditNoteLineWrapper cnlw : creditNoteLinesWrapper){
                OpportunityLineItem oppItem = new OpportunityLineItem(
                    OpportunityId = creditNoteOpp.Id,
                    Site__c = application.Site__c,
                    Product2Id = cnlw.productId,
                    Quantity = cnlw.quantity,
                    UnitPrice = cnlw.listPrice
                );
                oppProdToInsert.add(oppItem);
            }
            if(oppProdToInsert.size() > 0){
                insert oppProdToInsert;
                creditNoteOpp.StageName = 'Closed Won';
                creditNoteOpp.ia_crm__Sync_With_Intacct__c = true;
                update creditNoteOpp;
            }
            
            Opportunity creditNoteCreated = [SELECT Id, Name, Credit_Note_Number__c, Credit_Reason__c, Amount, VAT__c, Amount_Inc_VAT__c FROM Opportunity WHERE Id =:creditNoteOpp.Id];
            return creditNoteCreated;
        }else{
            return null;
        }
    }

    public class CreditNoteLineWrapper{
        @AuraEnabled public String oppLineId {get;set;}
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public Decimal listPrice {get;set;}
        @AuraEnabled public Decimal maxListPrice {get;set;}
        @AuraEnabled public Decimal quantity {get;set;}
        @AuraEnabled public Decimal maxQuantity {get;set;}
        @AuraEnabled public String productId {get;set;}
    }
}