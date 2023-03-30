public class OpportunityTriggerHandler {

    public static Id orderEntryRecordTypeId;

    public static void onBeforeInsert(List<Opportunity> newOpps) {
        // get Order Entry Record Type for opportunity
        orderEntryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OrderEntry').getRecordTypeId();

        // identify if there are invoices or credit notes created and add them to a list
        List<Opportunity> invoicesCreated = new List<Opportunity>();
        List<Opportunity> creditNotesCreated = new List<Opportunity>();
        for(Opportunity opp : newOpps){
            // check if the record type is 'OrderEntry'
            if(opp.RecordTypeId == orderEntryRecordTypeId){
                // check if opp created is an invoice
                if(opp.ia_crm__Intacct_Transaction__c == 'Sales Invoice'){
                    invoicesCreated.add(opp);
                }
                // check if opp created is a credit note
                if(opp.ia_crm__Intacct_Transaction__c == 'Sales Credit Note'){
                    creditNotesCreated.add(opp);
                }
            }
        }
        // if there are invoices created, pass them into the generateInvoiceNumbers method
        if(invoicesCreated.size() > 0){
            generateInvoiceNumbers(invoicesCreated);
        }
        // if there are credit notes created, pass them into the generateCreditNoteNumbers method
        if(creditNotesCreated.size() > 0){
            generateCreditNoteNumbers(creditNotesCreated);
        }
    }

    private static void generateInvoiceNumbers(List<Opportunity> invoicesCreated){
        // query the highest invoice number opportunity
        List<Opportunity> highestInvoceNumberOpp = [
            SELECT 
            Id, 
            Invoice_Number__c 
            FROM Opportunity 
            WHERE RecordTypeId =:orderEntryRecordTypeId 
            AND ia_crm__Intacct_Transaction__c = 'Sales Invoice'
            AND Invoice_Number__c != null
            ORDER BY Invoice_Number__c DESC
            LIMIT 1];
        
        // conert the invoice number text to a number field
        Integer invoiceNumber;
        if(highestInvoceNumberOpp.size() > 0){
            // remove all invalid number characters from string 
            String invalidNumbers = '[^0-9]';  
            String invoiceNumberString = highestInvoceNumberOpp[0].Invoice_Number__c.replaceAll(invalidNumbers, '');
            invoiceNumber = Integer.valueOf(invoiceNumberString);
        }else{
            // if there is no invoice number found then set the invoiceNumber as 0 so the first invoice can increase by 1 to get the first invoice number
            invoiceNumber = 0;
        }
        // iterate through the invoice opps created to generate numbers for all
        for(Opportunity opp :invoicesCreated){
            Integer invoiceNumberForThisOpp = invoiceNumber + 1;
            // convert the invoice number to text format
            opp.Invoice_Number__c = 'INV' + String.valueOf(invoiceNumberForThisOpp).leftPad(6, '0');
            opp.ia_crm__Intacct_Transaction_ID__c = 'INV' + String.valueOf(invoiceNumberForThisOpp).leftPad(6, '0');
        }

    }

    private static void generateCreditNoteNumbers(List<Opportunity> creditNotesCreated){
        // query the highest credit note number opportunity
        List<Opportunity> highestCreditNoteNumberOpp = [
            SELECT 
            Id, 
            Credit_Note_Number__c 
            FROM Opportunity 
            WHERE RecordTypeId =:orderEntryRecordTypeId 
            AND ia_crm__Intacct_Transaction__c = 'Sales Credit Note'
            AND Credit_Note_Number__c != null
            ORDER BY Credit_Note_Number__c DESC
            LIMIT 1];
        
        // conert the credit note number text to a number field
        Integer creditNoteNumber;
        if(highestCreditNoteNumberOpp.size() > 0){
            // remove all invalid number characters from string 
            String invalidNumbers = '[^0-9]';  
            String creditNoteNumberString = highestCreditNoteNumberOpp[0].Credit_Note_Number__c.replaceAll(invalidNumbers, '');
            creditNoteNumber = Integer.valueOf(creditNoteNumberString);
        }else{
            // if there is no credit note number found then set the creditNoteNumber as 0 so the first credit note can increase by 1 to get the first credit note number
            creditNoteNumber = 0;
        }
        // iterate through the credit note opps created to generate numbers for all
        for(Opportunity opp :creditNotesCreated){
            Integer creditNoteNumberForThisOpp = creditNoteNumber + 1;
            // convert the credit note number to text format
            opp.Credit_Note_Number__c = 'CN' + String.valueOf(creditNoteNumberForThisOpp).leftPad(6, '0');
            opp.ia_crm__Intacct_Transaction_ID__c = 'CN' + String.valueOf(creditNoteNumberForThisOpp).leftPad(6, '0'); // Populate the Sage Intacct Transaction Id
        }
    }
}