/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CreateJournalEntryGlobalAction {
    global CreateJournalEntryGlobalAction() {

    }
    @InvocableMethod(label='Create Journal Entry' description='Creates Journal entries from process builder.')
    global static void createJournalEntryInvocable(List<ia_crm.CreateJournalEntryGlobalAction.CreateJournalEntryRequest> recordIds) {

    }
    global static void createJournalEntry(List<Id> recordIds, String mappingName) {

    }
global class CreateJournalEntryRequest {
    @InvocableVariable(label='Configuration Mapping Name' required=true)
    global String mappingName;
    @InvocableVariable(label='Record ID' required=true)
    global Id recordId;
    global CreateJournalEntryRequest() {

    }
}
}
