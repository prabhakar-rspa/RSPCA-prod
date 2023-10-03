public with sharing class SendBulkRenewalInvoiceController {
    @AuraEnabled
    public static string getContacts(String recordId){
        try {
            Bulk_Renewal__c bulkRenewal = [
                SELECT Id,Head_Office__c FROM Bulk_Renewal__c WHERE Id=:recordId
            ];
            List<Contact> contacts = [
                SELECT Id,Name,Email From Contact WHERE AccountId=:bulkRenewal.Head_Office__c AND Roles__c includes ('Invoice Contact')
            ];
            return JSON.serialize(contacts);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string createInvoice(String recordId){
        try {
            Id orderEntryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OrderEntry').getRecordTypeId();

            Bulk_Renewal__c bulkRenewal = [
                SELECT Id,Head_Office__c,Head_Office__r.Name,CreatedDate,Create_Sage_Invoice__c,Sage_Invoice__c,Application_Contact__c
                FROM Bulk_Renewal__c WHERE Id=:recordId
            ];
            bulkRenewal.Create_Sage_Invoice__c = true;
            List<Application_Line_Item__c> renewalAppLineItems = [
                SELECT Id, Product__c, Product__r.Name, Application__c, Application__r.Pricebook_Id__c, 
                Application__r.Site__c, Application__r.Bulk_Renewal__c, Application_Unit__c, Item_Description__c,
                    List_Price__c, List_Price_Inc_Vat__c, Quantity__c, Subtotal__c, Number_of_Animals__c 
                    FROM   Application_Line_Item__c WHERE Application__r.Bulk_Renewal__c = :recordId
            ];
            system.debug('renewalAppLineItems:::'+renewalAppLineItems);
            if(bulkRenewal.Create_Sage_Invoice__c ){
                if(bulkRenewal.Sage_Invoice__c == null && renewalAppLineItems != null && renewalAppLineItems.size()>0){
                    String pricebookId = renewalAppLineItems[0].Application__r.Pricebook_Id__c;
                    String bulkRenewalCreatedDate = bulkRenewal.CreatedDate.format('dd/MM/yyyy');
                    Opportunity invoiceOpp = new Opportunity();
                    invoiceOpp.Name = bulkRenewal.Head_Office__r.Name + ' Bulk Renewal ' + bulkRenewalCreatedDate;
                    invoiceOpp.CloseDate = Date.today();
                    invoiceOpp.AccountId = bulkRenewal.Head_Office__c;
                    invoiceOpp.StageName = 'Prospecting';
                    invoiceOpp.Pricebook2Id = pricebookId;
                    invoiceOpp.Bulk_Renewal__c = bulkRenewal.Id;
                    invoiceOpp.ia_crm__Intacct_Transaction__c = 'Sales Invoice';
                    invoiceOpp.RecordTypeId = orderEntryRecordTypeId;
                    if(bulkRenewal.Application_Contact__c != null){
                        invoiceOpp.ia_crm__Bill_to__c = bulkRenewal.Application_Contact__c;
                    }

                    insert invoiceOpp;

                    List<OpportunityLineItem> oppProdToInsert = new List<OpportunityLineItem>();
                    for(Application_Line_Item__c item : renewalAppLineItems){
                        OpportunityLineItem oppItem = new OpportunityLineItem(
                            OpportunityId = invoiceOpp.Id,
                            Site__c = item.Application__r.Site__c,
                            Product2Id = item.Product__c,
                            Quantity = item.Quantity__c,
                            UnitPrice = item.List_Price__c
                        );
                        oppProdToInsert.add(oppItem);
                    }
                    if(oppProdToInsert.size() > 0){
                        insert oppProdToInsert;
                        invoiceOpp.StageName = 'Closed Won';
                        invoiceOpp.ia_crm__Sync_With_Intacct__c = true;
                        update invoiceOpp;
                    }
                    bulkRenewal.Sage_Invoice__c = invoiceOpp.id;
                    TriggerHandler.bypass('BulkRenewalTriggerHandler');
                    update bulkRenewal;
                    TriggerHandler.clearBypass('BulkRenewalTriggerHandler');
                }
                
            }
            return JSON.serialize(bulkRenewal);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string sendMultipleInvoices(List<String> contactId,String message,String recordId){
        Id orderEntryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OrderEntry').getRecordTypeId();

        Bulk_Renewal__c bulkRenewal = [
            SELECT Id,Head_Office__c,Head_Office__r.Name,CreatedDate,Create_Sage_Invoice__c,Sage_Invoice__c,Application_Contact__c
            FROM Bulk_Renewal__c WHERE Id=:recordId
        ];
        if(bulkRenewal.Sage_Invoice__c != null){
            sendBulkRenewalInvoice(recordId,contactId);
        }
        return JSON.serialize(bulkRenewal);
    }
    public static void sendBulkRenewalInvoice(String bulkRenewalId,List<String> contactIds){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'Bulk Renewal Invoice Email'];
        Bulk_Renewal__c br = [SELECT Id,Payment_Reference__c,Head_Office__r.Membership_Number__c,  Application_Contact__c, Invoice_Email_Sent__c,Name,Custom_Invoice_Message__c FROM Bulk_Renewal__c WHERE Id =:bulkRenewalId];
        PageReference reportPage = new PageReference('/apex/BulkRenewalInvoicePDF');
        reportPage.getParameters().put('id', br.Id);
        Blob reportPdf;
        if(!Test.isRunningTest()){
          reportPdf = reportPage.getContentAsPDF();
        }else{
            reportPdf = Blob.valueOf('Test');
        }
        ContentVersion cv = new ContentVersion();
        cv.VersionData = reportPdf;
        cv.Title = br.Name;
        cv.PathOnClient = br.Name+'.pdf';
        cv.Description = br.Name;
        cv.isMajorVersion = true;
        insert cv;
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(String contactId:contactIds){
            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, contactId, br.Id);
            message.setSenderDisplayName('RSPCA Assured'); 
            message.setReplyTo('accounts@rspcaassured.org.uk');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(true);
            message.setSubject('Invoice for your Bulk Renewal: '+br.Payment_Reference__c);//+br.Head_Office__r.Membership_Number__c
            message.setEntityAttachments(new list<Id> {cv.Id});
            messages.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success){
            System.debug('The email was sent successfully.');
            br.Invoice_Email_Sent__c = true;
            update br;
        }else {
            System.debug('The email failed to send: '+results[0].errors[0].message);
        }
    }
}