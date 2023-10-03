public with sharing class SendInvoiceController {
    //public class InvoiceException extends Exception {}
    @AuraEnabled
    public static string getContacts(String recordId){
        try {
            Application__c application = [
                SELECT Id,Head_Office__c FROM Application__c WHERE Id=:recordId
            ];
            List<Contact> contacts = [
                SELECT Id,Name,Email From Contact WHERE AccountId=:application.Head_Office__c AND Roles__c includes ('Invoice Contact')
            ];
            return JSON.serialize(contacts);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string updateApplication(String recordId,String message){
        try {
            Application__c application = [
                SELECT Id,Name,Payment_Due_Date__c,Invoice_Date__c,Bulk_Renewal__c ,CreatedDate,Site__c,
                Site_Name__c,Application_Type__c,Head_Office__c,Pricebook_Id__c,Applicant_Contact__c,
                Sage_Invoice__c
                FROM Application__c WHERE Id=:recordId
            ];
            application.Send_Invoice__c = true ;
            application.Custom_Invoice_Message__c = message;
            application.Invoice_Date__c = system.today();
            if(application.Payment_Due_Date__c == null){
                application.Payment_Due_Date__c = system.today().addDays(14);
            }
            //update application;
            List<Application_Line_Item__c> lineItemsForApplications = [
                SELECT Id, Product__c, Product__r.Name, Application__c, Application_Unit__c, 
                Item_Description__c, List_Price__c, List_Price_Inc_Vat__c, Quantity__c,
                 Subtotal__c, Number_of_Animals__c, Line_Description__c 
                 FROM   Application_Line_Item__c WHERE Application__c =:recordId
            ];            
            //application.Payment_Due_Date__c != null && application.Invoice_Date__c != null && 
            if(application.Bulk_Renewal__c == null){ 
                if(application.Sage_Invoice__c == null){
                    Id orderEntryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OrderEntry').getRecordTypeId();
                    String appCreatedDate = application.CreatedDate.format('dd/MM/yyyy');
                    Opportunity invoiceOpp = new Opportunity();
                    invoiceOpp.Name = application.Site_Name__c + ' ' + application.Application_Type__c + ' ' + appCreatedDate;
                    invoiceOpp.CloseDate = Date.today();
                    invoiceOpp.AccountId = application.Head_Office__c;
                    invoiceOpp.StageName = 'Prospecting';
                    invoiceOpp.Pricebook2Id = application.Pricebook_Id__c;
                    invoiceOpp.Application__c = application.Id;
                    invoiceOpp.ia_crm__Intacct_Transaction__c = 'Sales Invoice';
                    invoiceOpp.RecordTypeId = orderEntryRecordTypeId;
                    invoiceOpp.Intacct_Application__c = application.Name;
                    if(application.Applicant_Contact__c != null){
                        invoiceOpp.ia_crm__Bill_to__c = application.Applicant_Contact__c;
                    }
                    
                    insert invoiceOpp;
                    application.Sage_Invoice__c = invoiceOpp.Id;
                    TriggerHandler.bypass('ApplicationTriggerHandler');
                    update application;
                    TriggerHandler.clearBypass('ApplicationTriggerHandler');
                    List<OpportunityLineItem> oppProdToInsert = new List<OpportunityLineItem>();
                    for(Application_Line_Item__c item : lineItemsForApplications){
                        OpportunityLineItem oppItem = new OpportunityLineItem(
                            OpportunityId = invoiceOpp.Id,
                            Site__c = application.Site__c,
                            Product2Id = item.Product__c,
                            Quantity = item.Quantity__c,
                            UnitPrice = item.List_Price__c,
                            Description = item.Line_Description__c
                        );
                        oppProdToInsert.add(oppItem);
                    }
                    if(oppProdToInsert.size() > 0){
                        insert oppProdToInsert;
                        invoiceOpp.StageName = 'Closed Won';
                        invoiceOpp.ia_crm__Sync_With_Intacct__c = true;
                        update invoiceOpp;
                    }
                }
            }
            return JSON.serialize(application);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string sendMultipleInvoices(List<String> contactId,String message,String recordId){
        try {
            Application__c application = [
                SELECT Id,Name,Payment_Due_Date__c,Invoice_Date__c,Bulk_Renewal__c ,CreatedDate,Site__c,
                Site_Name__c,Application_Type__c,Head_Office__c,Pricebook_Id__c,Applicant_Contact__c,
                Sage_Invoice__c
                FROM Application__c WHERE Id=:recordId
            ];
            
            if(application.Bulk_Renewal__c == null && application.Sage_Invoice__c != null){ 
                sendEmail(application.Id,contactId);
            }
            return JSON.serialize(application);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void sendEmail(String applicationId,List<String> contactIds){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'Application Invoice Email'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help@rspcaassured.org.uk'];
        Application__c app = [SELECT Id,Name,Applicant_Contact__c,Custom_Invoice_Message__c,Alternative_Invoice_Sender_Email__c,Accounts_Email__c,Membership_Number__c,Payment_Reference__c FROM Application__c WHERE Id=:applicationId];
        system.debug('message:::'+app.Custom_Invoice_Message__c);
        PageReference reportPage = new PageReference('/apex/InvoicePDF');
        reportPage.getParameters().put('id', app.Id);
        
        Blob reportPdf;
        if(!Test.isRunningTest()){
          reportPdf = reportPage.getContentAsPDF();
        }else{
            reportPdf = Blob.valueOf('Test');
        }
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = reportPdf;
        cv.Title = app.Name;
        cv.PathOnClient = app.Name+'.pdf';
        cv.Description = app.Name;
        cv.isMajorVersion = true;
        insert cv;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(String contactId:contactIds){
            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, contactId, app.Id);
            message.setEntityAttachments(new list<Id> {cv.Id});
            if(app.Alternative_Invoice_Sender_Email__c != null){
                message.setReplyTo(app.Alternative_Invoice_Sender_Email__c);
                message.setSenderDisplayName(app.Alternative_Invoice_Sender_Email__c);
            }else{
                message.setReplyTo('help@rspcaassured.org.uk');
                message.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            message.setSubject('Invoice For membership number: '+app.Membership_Number__c);
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(true);   
            if(app.Accounts_Email__c != null){
                message.toAddresses = new String[] {app.Accounts_Email__c};
            }
            system.debug('toAddresses '+message.toAddresses);
            messages.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        app.InvoiceSent__c = true;
        TriggerHandler.bypass('ApplicationTriggerHandler');
        update app;
        TriggerHandler.clearBypass('ApplicationTriggerHandler');
    }
}