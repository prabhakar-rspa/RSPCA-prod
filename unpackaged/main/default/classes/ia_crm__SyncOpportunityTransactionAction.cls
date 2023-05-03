/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SyncOpportunityTransactionAction {
    global SyncOpportunityTransactionAction() {

    }
    @InvocableMethod(label='Sync Opportunity Transaction' description='Creates Order Entry Transactions in Intacct.')
    global static void syncOpportunityTransaction(List<ia_crm.SyncOpportunityTransactionAction.SyncOpportunityTransactionRequest> recordIds) {

    }
global class SyncOpportunityTransactionRequest {
    @InvocableVariable(label='If Intacct Transaction is empty, the transaction will apply only to them.' required=false)
    global Boolean applyOnlyToEmptyTransactions;
    @InvocableVariable(label='Record ID' required=false)
    global Id recordId;
    @InvocableVariable(label='Transaction Name' required=false)
    global String transactionName;
    global SyncOpportunityTransactionRequest() {

    }
}
}
