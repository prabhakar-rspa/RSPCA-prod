/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DeleteErrorLogBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Datetime deleteFromDate;
    global String query;
    global DeleteErrorLogBatch() {

    }
    global void execute(Database.BatchableContext BC, List<ia_crm__Error_Log__c> scope) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
