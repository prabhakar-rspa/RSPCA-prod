public class NewApplicationTriggerHandler extends TriggerHandler{
    // setting the maximum loop count for this trigger
    public NewApplicationTriggerHandler(){
    }
    
    public override void afterInsert(){
        //Application Id set
        Set<String> appId = new Set<String>();
        
        //site account id set
        Set<String> siteId = new Set<String>(); 
        
        //Head office account Id set
        Set<String> headOfficeIdSet = new Set<String>();
        
        // pricebook ids
        Set<String> pricebookIds = new Set<String>();
        
        //Assign values to the appId set and siteId set
        for(Application__c app:(List<Application__c>)Trigger.new){
            appId.add(app.Id);
            siteId.add(app.Site__c);
            headOfficeIdSet.add(app.Head_Office__c);
            pricebookIds.add(app.Pricebook_Id__c);
        }
        
        // get Head Office Account Billing Country
        Map<Id, Account> headOfficeMap = new Map<Id, Account>([SELECT Id, BillingCountry FROM Account WHERE Id IN:headOfficeIdSet]);
        
        Set<String> productCodes = new Set<String>{
            'JOINFEE',
                'REVISIT',
                'LATEFEE'
                };
                    
                    //List of products
                    List<Product2> activeProducts = [SELECT Id, Name, ProductCode, IsActive From Product2 WHERE IsActive=true AND ProductCode IN :productCodes];
        //product map
        Map<String, Product2> productMap = new Map<String, Product2>();
        // Product Id Set
        Set<String> productIdSet = new Set<String>();
        
        for(Product2 p:activeProducts){
            productMap.put(p.ProductCode, p);
            productIdSet.add(p.Id);
        }
        System.debug('App Id Set => ' + appId);
        //Look for existing joining fee
        List<Application_Line_Item__c> existingJoinFee = new List<Application_Line_Item__c>();
        //Look for existing Revisit fee
        List<Application_Line_Item__c> existingRevisitFee = new List<Application_Line_Item__c>();
        //Look for existing Late renewal fee
        List<Application_Line_Item__c> existingLateRenewalFee = new List<Application_Line_Item__c>();
        
        for(Application_Line_Item__c ali : [SELECT Id, Application__c, Product__c, Product_Code__c FROM Application_Line_Item__c WHERE Application__c=:appId AND Product__c IN :productIdSet]){
            if(ali.Product__c == productMap.get('JOINFEE').Id){
                existingJoinFee.add(ali);
            }else if(ali.Product__c == productMap.get('REVISIT').Id){
                existingRevisitFee.add(ali);
            }else if(ali.Product__c == productMap.get('LATEFEE').Id){
                existingLateRenewalFee.add(ali);
            }
        }
        
        // query pricebook entries for the products
        List<PricebookEntry> priceEntries = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive FROM PricebookEntry WHERE IsActive = true AND Pricebook2Id IN :pricebookIds AND Product2Id IN :productIdSet ];
        
        // Map list of price book entries to product id
        Map<Id, List<PricebookEntry>> productIdToPriceBookEntries = new Map<Id, List<PricebookEntry>>();
        for(PricebookEntry pbe : priceEntries){
            if(productIdToPriceBookEntries.containsKey(pbe.Product2Id)){
                List<PricebookEntry> pbeList = productIdToPriceBookEntries.get(pbe.Product2Id);
                pbeList.add(pbe);
                productIdToPriceBookEntries.put(pbe.Product2Id, pbeList);
            }else{
                productIdToPriceBookEntries.put(pbe.Product2Id, new List<PricebookEntry>{pbe});
            }
        }
        
        //get record type
        Id renewalRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Id applicationRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Applications').getRecordTypeId();
        
        //create a application line item list to add products to insert
        List<Application_Line_Item__c> productsToAdd = new List<Application_Line_Item__c>();
        
        
        for(Application__c app:(List<Application__c>)Trigger.new){
            
            //add joining fee
            if((app.RecordTypeId==applicationRecordTypeId)&&(app.Existing_Member__c == 'No') &&(productMap.containsKey('JOINFEE'))&&(existingJoinFee.size() == 0) && app.Pricebook_Id__c != null){
                // get join fee price
                if(productIdToPriceBookEntries.containsKey(productMap.get('JOINFEE').Id)){
                    List<PricebookEntry> prices = productIdToPriceBookEntries.get(productMap.get('JOINFEE').Id);
                    PricebookEntry joinFeePBE;
                    for(PricebookEntry pbe : prices){
                        if(pbe.Pricebook2Id == app.Pricebook_Id__c){
                            joinFeePBE = pbe;
                        }
                    }
                    if(joinFeePBE != null){
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        appli.Application__c = app.Id;
                        appli.Product__c = joinFeePBE.Product2Id;
                        appli.List_Price__c = joinFeePBE.UnitPrice;
                        if(headOfficeMap.containsKey(app.Head_Office__c)){
                            Account headOffice = headOfficeMap.get(app.Head_Office__c);
                            if(headOffice.BillingCountry == 'United Kingdom'){
                                appli.List_Price_Inc_Vat__c = joinFeePBE.UnitPrice + (joinFeePBE.UnitPrice * 0.2);
                            }else{
                                appli.List_Price_Inc_Vat__c = joinFeePBE.UnitPrice;
                            }
                        }
                        appli.Quantity__c = 1;       
                        //add product to the list
                        productsToAdd.add(appli);
                    }
                }
            }
            // add revisit fee
            if((app.Application_Type__c == 'Update' || app.Application_Type__c == 'Transfer') && productMap.containsKey('REVISIT') && existingRevisitFee.size() == 0 && app.Pricebook_Id__c != null && app.Site_needs_assessment__c){
                if(productIdToPriceBookEntries.containsKey(productMap.get('REVISIT').Id)){
                    List<PricebookEntry> prices = productIdToPriceBookEntries.get(productMap.get('REVISIT').Id);
                    PricebookEntry revisitFeePBE;
                    for(PricebookEntry pbe : prices){
                        if(pbe.Pricebook2Id == app.Pricebook_Id__c){
                            revisitFeePBE = pbe;
                        }
                    }
                    if(revisitFeePBE != null){
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        appli.Application__c = app.Id;
                        appli.Product__c = revisitFeePBE.Product2Id;
                        appli.List_Price__c = revisitFeePBE.UnitPrice;
                        if(headOfficeMap.containsKey(app.Head_Office__c)){
                            Account headOffice = headOfficeMap.get(app.Head_Office__c);
                            if(headOffice.BillingCountry == 'United Kingdom'){
                                appli.List_Price_Inc_Vat__c = revisitFeePBE.UnitPrice + (revisitFeePBE.UnitPrice * 0.2);
                            }else{
                                appli.List_Price_Inc_Vat__c = revisitFeePBE.UnitPrice;
                            }
                        }
                        appli.Quantity__c = 1;
                        
                        //add product to the list
                        productsToAdd.add(appli);
                    }
                }
            }
            //add late renewal fee
            Date appCreatedDate = Date.newInstance(app.CreatedDate.year(), app.CreatedDate.month(), app.CreatedDate.day()); // Convert created date time to date
            Boolean disableLateRenewalFee = true;
            if( app.Application_Type__c == 'Renewal' && (app.RecordTypeId==renewalRecordTypeId)&&(productMap.containsKey('LATEFEE'))&&(existingLateRenewalFee.size() == 0)&&(appCreatedDate > app.Renewal_Date__c) && app.Pricebook_Id__c != null && disableLateRenewalFee == false){
                if(productIdToPriceBookEntries.containsKey(productMap.get('LATEFEE').Id)){
                    List<PricebookEntry> prices = productIdToPriceBookEntries.get(productMap.get('LATEFEE').Id);
                    PricebookEntry lateFeePBE;
                    for(PricebookEntry pbe : prices){
                        if(pbe.Pricebook2Id == app.Pricebook_Id__c){
                            lateFeePBE = pbe;
                        }
                    }
                    if(lateFeePBE != null){
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        appli.Application__c = app.Id;
                        appli.Product__c = lateFeePBE.Product2Id;
                        appli.List_Price__c = lateFeePBE.UnitPrice;
                        if(headOfficeMap.containsKey(app.Head_Office__c)){
                            Account headOffice = headOfficeMap.get(app.Head_Office__c);
                            if(headOffice.BillingCountry == 'United Kingdom'){
                                appli.List_Price_Inc_Vat__c = lateFeePBE.UnitPrice + (lateFeePBE.UnitPrice * 0.2);
                            }else{
                                appli.List_Price_Inc_Vat__c = lateFeePBE.UnitPrice;
                            }
                        }
                        appli.Quantity__c = 1;
                        
                        //add product to the list
                        productsToAdd.add(appli);
                    }
                }
            }
            
        }
        Database.insert(productsToAdd);
        
        //updateTotalOnBulkRenewal((Map<Id,Application__c>)Trigger.newMap,  (Map<Id,Application__c>)Trigger.oldMap);
    }
    
    public override void beforeUpdate(){
        TriggerHandler.bypass('ApplicationTriggerHandler');

        List<Application__c> sendAppConfirmationLog = new List<Application__c>();

        for(Application__c app: (List<Application__c>)Trigger.new){
            if(app.Send_Application_Confirmation_Email__c && !app.ApplicationConfirmationLogged__c && app.Applicant_Contact__c != null){
                sendAppConfirmationLog.add(app);
            }
        }
        
        if(sendAppConfirmationLog.size() > 0){
            //get emailtemplates
            EmailTemplate template1 = [SELECT Id, Subject, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName ='ApplicationConfirmation'];
            for(Application__c app: sendAppConfirmationLog){
                //log application confirmation email on record
                Contact con = new Contact(Id=app.Applicant_Contact__c);
                String salu;
                
                if(con.Salutation == null){
                    salu = '';
                }else{
                    salu = con.Salutation;
                }
                
                String body = template1.HtmlValue;
                String mergeSalutation = body.replace('{!Application__c.Applicant_Salutation__c}', salu);
                String mergeName = mergeSalutation.replace('{!Application__c.Applicant_Full_Name__c}', app.Applicant_Full_Name__c);
                body = mergeName;
                
                LogEmailMessage.logEmailSent(con.Id, con.Email, app.Id, template1.Subject, body);
                app.ApplicationConfirmationLogged__c = true;
            }
        }

        evidenceEmailCheckboxUpdates((Map<ID, Application__c>)Trigger.oldMap, (List<Application__c>)Trigger.new);
        TriggerHandler.clearBypass('ApplicationTriggerHandler');
    }
    
    public override void afterUpdate(){
        updateTotalOnBulkRenewal(
            (Map<Id,Application__c>)Trigger.newMap, 
            (Map<Id,Application__c>)Trigger.oldMap
            );

        sendExtensionEmail((Map<ID, Application__c>)Trigger.oldMap, (List<Application__c>)Trigger.new);

        sendAssessmentCompleteEmail((Map<ID, Application__c>)Trigger.oldMap, (List<Application__c>)Trigger.new);

        // Activated woa
        GenerateWOA.generate((Map<ID, Application__c>)Trigger.newMap, (Map<ID, Application__c>)Trigger.oldMap, false);

        // get Order Entry Record Type for opportunity
        Id orderEntryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OrderEntry').getRecordTypeId();
        
        
        Set<String> appIds = new Set<String>();
        for(Application__c app: (List<Application__c>)Trigger.new){
            if(app.Send_Invoice__c == true && app.InvoiceSent__c == false && app.Payment_Due_Date__c != null && app.Invoice_Date__c != null && app.Bulk_Renewal__c == null){
                appIds.add(app.Id);
            }
        }

        if(!appIds.isEmpty()){

            // query Application Line Item
            List<Application_Line_Item__c> lineItemsForApplications = [SELECT Id, Product__c, Product__r.Name, Application__c, Application_Unit__c, Item_Description__c, List_Price__c, List_Price_Inc_Vat__c, Quantity__c, Subtotal__c, Number_of_Animals__c, Line_Description__c FROM   Application_Line_Item__c WHERE Application__c IN :appIds];
            
            // Map Application Id to List of Line Items
            Map<String, List<Application_Line_Item__c>> appIdToLineItems = new Map<String, List<Application_Line_Item__c>>();
            for(Application_Line_Item__c ali : lineItemsForApplications){
                if(appIdToLineItems.containsKey(ali.Application__c)){
                    List<Application_Line_Item__c> items = appIdToLineItems.get(ali.Application__c);
                    items.add(ali);
                    appIdToLineItems.put(ali.Application__c, items);
                }else{
                    appIdToLineItems.put(ali.Application__c, new List<Application_Line_Item__c>{ali});
                }
            }
            
            Set<Id> appIdToUpdate = new Set<Id>();
            Map<Id, Id> appIdToOppId = new Map<Id, Id>();

            for(Application__c app: (List<Application__c>)Trigger.new){
                if(app.Send_Invoice__c == true && app.InvoiceSent__c == false && app.Payment_Due_Date__c != null && app.Invoice_Date__c != null && app.Bulk_Renewal__c == null){ 
                    
                    String appCreatedDate = app.CreatedDate.format('dd/MM/yyyy');
                    Opportunity invoiceOpp = new Opportunity();
                    invoiceOpp.Name = app.Site_Name__c + ' ' + app.Application_Type__c + ' ' + appCreatedDate;
                    invoiceOpp.CloseDate = Date.today();
                    invoiceOpp.AccountId = app.Head_Office__c;
                    invoiceOpp.StageName = 'Prospecting';
                    invoiceOpp.Pricebook2Id = app.Pricebook_Id__c;
                    invoiceOpp.Application__c = app.Id;
                    invoiceOpp.ia_crm__Intacct_Transaction__c = 'Sales Invoice';
                    invoiceOpp.RecordTypeId = orderEntryRecordTypeId;
                    invoiceOpp.Intacct_Application__c = app.Name;
                    if(app.Applicant_Contact__c != null){
                        invoiceOpp.ia_crm__Bill_to__c = app.Applicant_Contact__c;
                    }
                    
                    insert invoiceOpp;
                    appIdToOppId.put(app.Id, invoiceOpp.Id);
                    appIdToUpdate.add(app.Id);
                    
                    if(appIdToLineItems.containsKey(app.Id)){
                        List<OpportunityLineItem> oppProdToInsert = new List<OpportunityLineItem>();
                        for(Application_Line_Item__c item : appIdToLineItems.get(app.Id)){
                            OpportunityLineItem oppItem = new OpportunityLineItem(
                                OpportunityId = invoiceOpp.Id,
                                Site__c = app.Site__c,
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
            }

            // Update the sage invoice Id to the application
            List<Application__c> appToUpdateWithSageId = new List<Application__c>();
            for(Id i : appIdToUpdate){
                Application__c app = new Application__c(Id = i);
                if(appIdToOppId.containsKey(i)){
                    app.Sage_Invoice__c = appIdToOppId.get(i);
                }
                appToUpdateWithSageId.add(app);
            }
            TriggerHandler.bypass('ApplicationTriggerHandler');
            update appToUpdateWithSageId;
            TriggerHandler.clearBypass('ApplicationTriggerHandler');

            EmailTemplate invoiceTemplate = null;
            OrgWideEmailAddress[] owea = null;
            if(!appToUpdateWithSageId.isEmpty()){
                owea = [select Id from OrgWideEmailAddress where Address = 'help@rspcaassured.org.uk'];
                invoiceTemplate = [SELECT Id, Subject, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Invoice_Email_Template'];
            }

            for(Application__c application : appToUpdateWithSageId){

                Application__c app = (Application__c)Trigger.newMap.get(application.Id);
                    
                    // Send invoice email
                    System.debug('InvoiceTemplateId  => ' + invoiceTemplate.Id); // remove after debugging
                    System.debug('Org Wide Email Address Id => ' + owea.get(0).Id); // remove after debugging
                    System.debug('Application Contact Id => ' + app.Applicant_Contact__c); // remove after debugging
                    
                    List<Messaging.EmailFileAttachment> attachments = New List<Messaging.EmailFileAttachment>();
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setContentType('application/pdf');
                    attach.setFileName(app.Name);
                    attach.setInline(true);
                    String body=invoiceTemplate.HtmlValue;
                    attach.Body = Blob.toPDF(body);         
                    attachments.add(attach);
                
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
                	message.setFileAttachments(attachments);
                    message.setTargetObjectId(app.Applicant_Contact__c);
                    if(app.Alternative_Invoice_Sender_Email__c != null){
                        message.setReplyTo(app.Alternative_Invoice_Sender_Email__c);
                        message.setSenderDisplayName(app.Alternative_Invoice_Sender_Email__c);
                    }else{
                        message.setReplyTo('help@rspcaassured.org.uk');
                        message.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    message.setUseSignature(false);
                    message.setBccSender(false);
                    message.setSaveAsActivity(true);                  
                 //   message.setTemplateID(invoiceTemplate.Id);
                    message.setPlainTextBody('Please find your invoice attached below…');
                    message.setWhatId(app.Id);//This is important for the merge fields in template to work
                    system.debug('Accounts Email => ' + app.Accounts_Email__c );
                    if(app.Accounts_Email__c != null){
                        message.toAddresses = new String[] {app.Accounts_Email__c};
                            }
                    
                    system.debug('toAddresses '+message.toAddresses);
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                        appIdToUpdate.add(app.Id); // Add the application Id to update the InvoiceSent__c to true
                    } else {
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    }
            }
            
            List<Application__c> appToUpdateToSent = new List<Application__c>();
            
            for(Id i : appIdToUpdate){
                Application__c app = new Application__c(Id = i, InvoiceSent__c = true);
                appToUpdateToSent.add(app);
            }
            
            TriggerHandler.bypass('ApplicationTriggerHandler');
            update appToUpdateToSent;
            TriggerHandler.clearBypass('ApplicationTriggerHandler');
            
            
        }
        
    }
    
    
    // Method to roll up total amount inc vat to the bulk renewal record
    public static void updateTotalOnBulkRenewal(Map<Id,Application__c> newMap, Map<Id,Application__c> oldMap){ 
        TriggerHandler.bypass('ApplicationTriggerHandler');
        Map<Id, Bulk_Renewal__c> bulkRenewalUpdate = new Map<Id, Bulk_Renewal__c>();
        
        for(Application__c ap:newMap.values()){
            if(ap.Bulk_Renewal__c != null ){
                
                if(!bulkRenewalUpdate.containsKey(ap.Bulk_Renewal__c)){
                    bulkRenewalUpdate.put(ap.Bulk_Renewal__c, new Bulk_Renewal__c(Id = ap.Bulk_Renewal__c));
                }
                
            }
        }
        
        if(!bulkRenewalUpdate.isEmpty()){
            List<AggregateResult> aggResult = new List<AggregateResult>();
        
            aggResult = [SELECT Bulk_Renewal__c,  SUM(Total_Amount_Inc_VAT__c)totalIncVat, SUM(Amount_Ex_VAT__c)total, SUM(VAT__c)vat FROM Application__c WHERE Bulk_Renewal__c IN : bulkRenewalUpdate.keySet() Group By Bulk_Renewal__c];
            
            for(AggregateResult ar : aggResult){
                Id bulkRenewalId = (ID)ar.get('Bulk_Renewal__c');
                if(bulkRenewalUpdate.containsKey(bulkRenewalId)){
                    Bulk_Renewal__c br = bulkRenewalUpdate.get(bulkRenewalId);
                    br.Total_Amount_Inc_VAT__c = (Decimal)ar.get('totalIncVat');
                    br.Total_Amount__c = (Decimal)ar.get('total');
                    br.VAT__c = (Decimal)ar.get('vat');
                    bulkRenewalUpdate.put(bulkRenewalId , br);
                }
            }
            

            
            update bulkRenewalUpdate.values();
        }
        
        TriggerHandler.clearBypass('ApplicationTriggerHandler');
        
        
    }

    /** Send Extension Granted Email - If Extension fields are populated **/
    public static void sendExtensionEmail(Map<ID, Application__c> oldAppMap, List<Application__c> updatedApps){
        for(Application__c newApp : updatedApps){
            Application__c oldApp = oldAppMap.get(newApp.Id);
            if(oldApp.Extension_Granted__c != newApp.Extension_Granted__c && newApp.Extension_Granted__c == 'Yes' 
               && String.isNotBlank(newApp.Extension_Period__c) && newApp.Extension_Granted_On__c != null 
               && newApp.Extension_Deadline__c != null){
                EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'ExtensionGranted'];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(newApp.Applicant_Contact__c); 
                message.setSenderDisplayName('RSPCA Assured'); 
                message.setReplyTo('accounts@rspcaassured.org.uk');
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(true);
                message.setTemplateID(emailTemplate.Id); 
                message.setWhatId(newApp.Id);
                message.toAddresses = new String[] {newApp.Applicant_Email__c};
                System.debug('message '+message);
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    if(messages != null && messages.size() > 0){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        System.debug('results.size() '+results.size());
                        if (results != null && results.size() > 0 && results[0].success){
                            System.debug('The email was sent successfully.');
                        }else {
                            System.debug('The email failed to send: '+results[0].errors[0].message);
                        }
                    }
            }
        }
    }

    /** Send Application Assessment Complete email - Assessment stage is complete **/
    public static void sendAssessmentCompleteEmail(Map<ID, Application__c> oldAppMap, List<Application__c> updatedApps){
        for(Application__c newApp : updatedApps){
            Application__c oldApp = oldAppMap.get(newApp.Id);
            if((oldApp.Stage__c == 'Assessment' || oldApp.Renewal_Stage__c == 'Assessment') && (newApp.Stage__c == 'Compliance' || newApp.Renewal_Stage__c == 'Compliance')){
                EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'AssessmentComplete'];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(newApp.Applicant_Contact__c); 
                message.setSenderDisplayName('RSPCA Assured'); 
                message.setReplyTo('accounts@rspcaassured.org.uk');
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setTemplateID(emailTemplate.Id); 
                message.setWhatId(newApp.Id);
                //message.toAddresses = new String[] {newApp.Applicant_Email__c};
                System.debug('message '+message);
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    if(messages != null && messages.size() > 0){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        System.debug('results.size() '+results.size());
                        if (results != null && results.size() > 0 && results[0].success){
                            System.debug('The email was sent successfully.');
                        }else {
                            System.debug('The email failed to send: '+results[0].errors[0].message);
                        }
                    }
            }
        }
    }

    public static void evidenceEmailCheckboxUpdates(Map<ID, Application__c> oldAppMap, List<Application__c> updatedApps){
        for(Application__c newApp : updatedApps){
            Application__c oldApp = oldAppMap.get(newApp.Id);
            if(oldApp.Extension_Deadline__c != newApp.Extension_Deadline__c){
                newApp.Evidence_Email_Sent__c = false;
                newApp.Final_Evidence_Email_Sent__c = false;
            }
        }
    }
}