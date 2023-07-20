/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CreateSalesDocumentGlobalAction {
    global CreateSalesDocumentGlobalAction() {

    }
    @InvocableMethod(label='Create Sales Document' description='Creates Sales Documents from process builder and flows.')
    global static void createSalesDocumentInvocable(List<ia_crm.CreateSalesDocumentGlobalAction.CreateSalesDocumentRequest> recordIds) {

    }
    global static void createSalesDocument(List<Id> recordIds, String mappingName) {

    }
global class CreateSalesDocumentRequest {
    @InvocableVariable(label='Configuration Mapping Name' required=true)
    global String mappingName;
    @InvocableVariable(label='Record ID' required=true)
    global Id recordId;
    global CreateSalesDocumentRequest() {

    }
}
}
