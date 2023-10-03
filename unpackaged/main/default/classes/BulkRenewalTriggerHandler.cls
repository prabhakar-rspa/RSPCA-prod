public class BulkRenewalTriggerHandler extends TriggerHandler{
    
    public override void afterUpdate(){
        List<Bulk_Renewal__c> newBulkRenewals = (List<Bulk_Renewal__c>)Trigger.new;
        List<Bulk_Renewal__c> createInvoicesForBR = new List<Bulk_Renewal__c>();
        Set<Id> accountIds = new Set<Id>();
        for(Bulk_Renewal__c br : newBulkRenewals){
            system.debug('br::::'+br);
            if(br.Create_Sage_Invoice__c && !br.Invoice_Email_Sent__c){
                createInvoicesForBR.add(br);
                accountIds.add(br.Head_Office__c);
            }
        }

        if(!createInvoicesForBR.isEmpty()){
            // get Order Entry Record Type for opportunity
            Id orderEntryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OrderEntry').getRecordTypeId();

            // get bulk renewal record ids in a set
           /* Set<Id> bulkRenewalIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            for(Bulk_Renewal__c br : newBulkRenewals){
                bulkRenewalIds.add(br.Id);
                accountIds.add(br.Head_Office__c);
            }*/

            // query head office accounts and place it in a map
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN:accountIds]);

            // get application line items for bulk renewal apps
            List<Application_Line_Item__c> renewalAppLineItems = [
                SELECT Id, Product__c, Product__r.Name, Application__c, Application__r.Pricebook_Id__c, 
                Application__r.Site__c, Application__r.Bulk_Renewal__c, Application_Unit__c, 
                Item_Description__c, List_Price__c, List_Price_Inc_Vat__c, Quantity__c, 
                Subtotal__c, Number_of_Animals__c FROM   Application_Line_Item__c
                WHERE Application__r.Bulk_Renewal__c IN :createInvoicesForBR
            ];
            system.debug('renewalAppLineItems:::'+renewalAppLineItems);
            Map<Id, List<Application_Line_Item__c>> bulkIdToAppLineItems = new Map<Id, List<Application_Line_Item__c>>();
            for(Application_Line_Item__c ali : renewalAppLineItems){
                if(bulkIdToAppLineItems.containsKey(ali.Application__r.Bulk_Renewal__c)){
                    List<Application_Line_Item__c> lineItems = bulkIdToAppLineItems.get(ali.Application__r.Bulk_Renewal__c);
                    lineItems.add(ali);
                    bulkIdToAppLineItems.put(ali.Application__r.Bulk_Renewal__c, lineItems);
                }else{
                    bulkIdToAppLineItems.put(ali.Application__r.Bulk_Renewal__c, new List<Application_Line_Item__c>{ali});
                }
            }

            // bulk renewals to update
            Map<Id, Id> brToOppId = new Map<Id, Id>();
            Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
            for(Bulk_Renewal__c br : newBulkRenewals){
                // if there are any line items
                if(bulkIdToAppLineItems.containsKey(br.Id)){
                    List<Application_Line_Item__c> brLineItems = bulkIdToAppLineItems.get(br.Id);
                    String pricebookId = brLineItems[0].Application__r.Pricebook_Id__c;
                    if(br.Create_Sage_Invoice__c && br.Sage_Invoice__c == null){
                        String bulkRenewalCreatedDate = br.CreatedDate.format('dd/MM/yyyy');
                        Opportunity invoiceOpp = new Opportunity();
                        invoiceOpp.Name = accountMap.get(br.Head_Office__c).Name + ' Bulk Renewal ' + bulkRenewalCreatedDate;
                        invoiceOpp.CloseDate = Date.today();
                        invoiceOpp.AccountId = br.Head_Office__c;
                        invoiceOpp.StageName = 'Prospecting';
                        invoiceOpp.Pricebook2Id = pricebookId;
                        invoiceOpp.Bulk_Renewal__c = br.Id;
                        invoiceOpp.ia_crm__Intacct_Transaction__c = 'Sales Invoice';
                        invoiceOpp.RecordTypeId = orderEntryRecordTypeId;
                        if(br.Application_Contact__c != null){
                            invoiceOpp.ia_crm__Bill_to__c = br.Application_Contact__c;
                        }
                        opportunityMap.put(br.Id,invoiceOpp);
                        
                    }
                }
            }
            if(!opportunityMap.isEmpty()){
                insert opportunityMap.values();
                List<OpportunityLineItem> oppProdToInsert = new List<OpportunityLineItem>();
                for(Id brId:opportunityMap.keySet()){
                    if(bulkIdToAppLineItems.containsKey(brId)){
                        List<Application_Line_Item__c> brLineItems = bulkIdToAppLineItems.get(brId);
                        Opportunity invoiceOpp = opportunityMap.get(brId);
                        for(Application_Line_Item__c item : brLineItems){
                            OpportunityLineItem oppItem = new OpportunityLineItem(
                                OpportunityId = invoiceOpp.Id,
                                Site__c = item.Application__r.Site__c,
                                Product2Id = item.Product__c,
                                Quantity = item.Quantity__c,
                                UnitPrice = item.List_Price__c
                            );
                            oppProdToInsert.add(oppItem);
                        }
                        invoiceOpp.StageName = 'Closed Won';
                        invoiceOpp.ia_crm__Sync_With_Intacct__c = true;
                        opportunityMap.put(brId,invoiceOpp);
                    }
                }
                
                if(oppProdToInsert.size() > 0){
                    insert oppProdToInsert;
                    update opportunityMap.values();
                }
                List<Bulk_Renewal__c> bulkRenewalsUpdate = new List<Bulk_Renewal__c>();
                
                for(Id i : opportunityMap.keySet()){
                    if(opportunityMap.containsKey(i)){
                        Bulk_Renewal__c br = new Bulk_Renewal__c(Id = i, Sage_Invoice__c = opportunityMap.get(i).Id);
                        bulkRenewalsUpdate.add(br);
                    }
                }
                if(bulkRenewalsUpdate.size() > 0){
                    TriggerHandler.bypass('BulkRenewalTriggerHandler');
                    update bulkRenewalsUpdate;
                    TriggerHandler.clearBypass('BulkRenewalTriggerHandler');
                }
            }
            // Send bulk renewal to members
            for(Bulk_Renewal__c br : createInvoicesForBR){
                sendBulkRenewalInvoice(br.Id);
            }
        }
        
    }

    @future(callout=true)
    public static void sendBulkRenewalInvoice(String bulkRenewalId){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'Bulk Renewal Invoice Email'];
        Bulk_Renewal__c br = [SELECT Id,  Application_Contact__c, Invoice_Email_Sent__c,Name,Custom_Invoice_Message__c,Head_Office__r.Membership_Number__c FROM Bulk_Renewal__c WHERE Id =:bulkRenewalId];
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, br.Application_Contact__c, br.Id);
        //-message.setTargetObjectId(br.Application_Contact__c); 
        message.setSenderDisplayName('RSPCA Assured'); 
        message.setReplyTo('accounts@rspcaassured.org.uk');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(true);
        message.setSubject('Invoice for your Bulk Renewal');//+br.Head_Office__r.Membership_Number__c
        //message.setTemplateID(emailTemplate.Id); 
        //message.setPlainTextBody('Please find your invoice attached below…');
        /*if(!String.isBlank(br.Custom_Invoice_Message__c)){
             message.setPlainTextBody(br.Custom_Invoice_Message__c);
        }else{
             message.setPlainTextBody('Please find your invoice attached below…');
        }*/
        //-message.setWhatId(br.Id);
        PageReference reportPage = new PageReference('/apex/BulkRenewalInvoicePDF');
        reportPage.getParameters().put('id', br.Id);
        Blob reportPdf;
        try {
            system.debug('reportPage:::'+reportPage);
            reportPdf = reportPage.getContentAsPDF();
        }
        catch (Exception e) {
            system.debug('going catch:::'+e);
            reportPdf = Blob.valueOf(e.getMessage());
        }
    	//commented this to create attachments under email message record
        /*List<Messaging.EmailFileAttachment> attachments = New List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName(br.Name+'.pdf');
        attach.setInline(true);
        attach.Body = reportPdf;         
        attachments.add(attach);
        message.setFileAttachments(attachments);*/
		ContentVersion cv = new ContentVersion();
        cv.VersionData = reportPdf;
        cv.Title = br.Name;
        cv.PathOnClient = br.Name+'.pdf';
        cv.Description = br.Name;
        cv.isMajorVersion = true;
        insert cv;
        message.setEntityAttachments(new list<Id> {cv.Id});
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
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