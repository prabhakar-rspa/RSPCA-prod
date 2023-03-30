public class BulkRenewalTriggerHandler {
    public static void OnAfterUpdate(List<Bulk_Renewal__c> newBulkRenewals){
        Set<Id> createInvoicesForBRIds = new Set<Id>();
        for(Bulk_Renewal__c br : newBulkRenewals){
            if(br.Create_Sage_Invoice__c && br.Sage_Invoice__c == null){
                createInvoicesForBRIds.add(br.Id);
            }
        }

        if(!createInvoicesForBRIds.isEmpty()){
            // get Order Entry Record Type for opportunity
            Id orderEntryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OrderEntry').getRecordTypeId();

            // get bulk renewal record ids in a set
            Set<Id> bulkRenewalIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            for(Bulk_Renewal__c br : newBulkRenewals){
                bulkRenewalIds.add(br.Id);
                accountIds.add(br.Head_Office__c);
            }

            // query head office accounts and place it in a map
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN:accountIds]);

            // get application line items for bulk renewal apps
            List<Application_Line_Item__c> renewalAppLineItems = [SELECT Id, Product__c, Product__r.Name, Application__c, Application__r.Pricebook_Id__c, Application__r.Site__c, Application__r.Bulk_Renewal__c, Application_Unit__c, Item_Description__c, List_Price__c, List_Price_Inc_Vat__c, Quantity__c, Subtotal__c, Number_of_Animals__c FROM   Application_Line_Item__c WHERE Application__r.Bulk_Renewal__c IN :bulkRenewalIds];
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
        
                        insert invoiceOpp;
                        brToOppId.put(br.Id, invoiceOpp.Id);
        
                        List<OpportunityLineItem> oppProdToInsert = new List<OpportunityLineItem>();
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
                        if(oppProdToInsert.size() > 0){
                            insert oppProdToInsert;
                            invoiceOpp.StageName = 'Closed Won';
                            invoiceOpp.ia_crm__Sync_With_Intacct__c = true;
                            update invoiceOpp;
                        }
                        
                    }
                }
            }

            List<Bulk_Renewal__c> bulkRenewalsUpdate = new List<Bulk_Renewal__c>();
            
            for(Id i : brToOppId.keySet()){
                if(brToOppId.containsKey(i)){
                    Bulk_Renewal__c br = new Bulk_Renewal__c(Id = i, Sage_Invoice__c = brToOppId.get(i));
                    bulkRenewalsUpdate.add(br);
                }
            }
            if(bulkRenewalsUpdate.size() > 0){
                update bulkRenewalsUpdate;
            }

            // Send bulk renewal to members
            for(Id i : brToOppId.keySet()){
                sendBulkRenewalInvoice(i);
            }
        }
        
    }

    @future
    public static void sendBulkRenewalInvoice(String bulkRenewalId){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'BulkRenewalInvoiceEmail'];
        Bulk_Renewal__c br = [SELECT Id,  Application_Contact__c, Invoice_Email_Sent__c FROM Bulk_Renewal__c WHERE Id =:bulkRenewalId];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(br.Application_Contact__c); 
        message.setSenderDisplayName('RSPCA Assured'); 
        message.setReplyTo('accounts@rspcaassured.org.uk');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(true);
        message.setTemplateID(emailTemplate.Id); 
        message.setWhatId(br.Id);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success){
            System.debug('The email was sent successfully.');
            br.Invoice_Email_Sent__c = true;
        }else {
            System.debug('The email failed to send: '+results[0].errors[0].message);
        }
        update br;
    }
}