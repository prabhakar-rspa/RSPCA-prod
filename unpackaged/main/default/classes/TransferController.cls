global without sharing class TransferController {
	@AuraEnabled
    public static Account getHeadOffice(String accId, String headOfficeNumber){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Head_Office').getRecordTypeId();
        Account acc = [SELECT Id, Name, Head_Office_Number__c FROM Account WHERE Head_Office_Number__c =:headOfficeNumber AND Id !=:accId AND RecordTypeId=:recordTypeId LIMIT 1];
        System.debug(acc);
        return acc;
    }

    // This method gets the Contact from the community users record or from the Site's primary contact
    @AuraEnabled
    public static Contact fetchCustomerContact(String siteId){
        Contact con = new Contact();
        String customerId = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
        Account site = [SELECT Id, Primary_Contact__c FROM Account WHERE Id=:siteId];

        if(customerId != null){
            con = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: customerId];
            return con;
        } else if(site != null){
            con = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: site.Primary_contact__c];
            return con;
        }
        return null;

    }

    // Create Transfer Application
    @AuraEnabled
    public static SObject createTransferApplication(Application__c app, String transferType, Account transferToAccount, Account oldSite){
        System.debug('Application ==> ' + app);
        System.debug('Transfer Type ==>' + transferType);
        System.debug('Transfer to Group Account ==> ' + transferToAccount);
        System.debug('Old Site Account ==> ' + oldSite);

        
        List<Unit__c> unitToCreate = new List<Unit__c>();
        List<Application_Unit__c> apuToCreate = new List<Application_Unit__c>();

        Id siteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
        Id headOfficeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Head_Office').getRecordTypeId();
        Id renewalAppRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();

        if(app != null){
            // Create a new Account with all of the fields from the old account
            Account newSite = oldSite.clone(false,false,false,false);
            newSite.Active__c = false;
            newSite.Status__c = null; 
            newSite.Previous_Membership__c = oldSite.Id;
            newSite.Site_Number__c = null;
            newSite.Generate_Site_Number__c = false;
            newSite.Membership_Expiry_Date__c = null;
            newSite.Head_Office_Number__c = null;
            newSite.Generate_Head_Office_Number__c = false;
            newSite.RecordTypeId = siteRecordTypeId;

            if(transferType == 'Group' && transferToAccount != null){
                newSite.ParentId = transferToAccount.Id;
            }else{
                //Create new head office account when transfer type is independant
                Account newHeadOffice = oldSite.clone(false,false,false,false);
                newHeadOffice.Active__c = false;
                newHeadOffice.Status__c = null;
                newHeadOffice.Previous_Membership__c = null;
                newHeadOffice.Site_Number__c = null;
                newHeadOffice.Generate_Site_Number__c = false;
                newHeadOffice.Membership_Expiry_Date__c = null;
                newHeadOffice.Head_Office_Number__c = null;
                newHeadOffice.Generate_Head_Office_Number__c = false;
                newHeadOffice.Previous_Assessor__c = null;
                newHeadOffice.RecordTypeId = headOfficeRecordTypeId;
                newHeadOffice.ParentId = null;
                
                insert newHeadOffice;

                newSite.ParentId = newHeadOffice.Id;    
            }
            insert newSite;

            //Disable old site account
            oldSite.Active__c = false;
            oldSite.Status__c = 'CANCELLED';
            oldsite.Transferred_Account__c = true;

            update oldSite;

            // Copy over the units from the old site
            for(Unit__c u : [SELECT Id, Account__c, Animals__c, Business__c, Chassis_Number__c, Description__c, Ingredients__c, Number_of_Animals__c, Order_Sizes__c, Own_Catching__c, Own_Transport__c, Production__c, Rearing_System__c, Status__c, Name, Vehicle_Registration__c, Vehicle_Type__c FROM Unit__c WHERE Account__c =:oldSite.Id]){
                if(u != null){
                    Unit__c newUnit = u.clone(false,false,false,false);
                    newUnit.Account__c = newSite.Id;
                    newUnit.Status__c = 'Applying';

                    unitToCreate.add(newUnit);
                }
            }

            if(unitToCreate.size() != 0){
                insert unitToCreate;
            }

            app.Site__c = newSite.Id;
            app.Head_Office__c = newSite.ParentId;
            app.RecordTypeId = renewalAppRecordTypeId;
            app.Stage__c = null;
            insert app;


            // Create application units for the Units added
            if(unitToCreate.size() != 0){
                for(Unit__c u : unitToCreate){
                    Application_Unit__c apu = new Application_Unit__c(Unit__c = u.Id, Application__c = app.Id);
                    apuToCreate.add(apu);
                }
            }
            insert apuToCreate;

            //Transfer the contacts from old site to new site
            List<Contact> contactToUpdate = new List<Contact>();
            for(Contact c: [SELECT Id, AccountId FROM Contact WHERE AccountId =:oldSite.Id]){
                if(c != null){
                    c.AccountId = newSite.Id;
                    contactToUpdate.add(c);
                }
            }
            if(contactToUpdate.size() != 0){
                update contactToUpdate;
            }

            

            Application__c insertedApp = [SELECT Id, Site__c, Applicant_Contact__c, Total_Amount_Inc_VAT__c, Payment_Method__c, Payment_Reference__c FROM Application__c WHERE Id =:app.Id];
            system.debug('Total Amount Inc VAT ==> ' + insertedApp.Total_Amount_Inc_VAT__c);
            Application_Contact_Role__c apc = new Application_Contact_Role__c(Application__c = insertedApp.Id, Contact__c = insertedApp.Applicant_Contact__c);
            insert apc;

            // Send invoice email using future method
            sendInvoiceForTransfer(insertedApp.Id);

            if(insertedApp.Payment_Method__c == 'Card'){
                // Code is commented out due to Card Payment not yet enabled
                /*
                Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id =:insertedApp.Applicant_Contact__c];

                Account acc = [SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingCountry FROM Account WHERE Id =: insertedApp.Site__c];
                
                asp04__Payment__c payment = new asp04__Payment__c();
                payment.Application__c = insertedApp.Id;
                payment.asp04__Amount__c = insertedApp.Total_Amount_Inc_VAT__c;
                payment.asp04__Payment_Route_Options__c = 'Card';
                payment.asp04__First_Name__c = con.FirstName;
                payment.asp04__Last_Name__c = con.LastName;
                payment.asp04__Email__c = con.Email;
                payment.asp04__Company_Name__c = acc.Name;
                payment.asp04__Billing_Address_Street__c = acc.BillingStreet;
                payment.asp04__Billing_Address_City__c = acc.BillingCity;
                payment.asp04__Billing_Address_PostalCode__c = acc.BillingPostalCode;
                payment.asp04__Billing_Address_Country__c = acc.BillingCountry;
                
                insert payment;

                asp04__Payment__c insertedPayment = [SELECT Id, Application__c, asp04__Amount__c, Payment_Link__c FROM asp04__Payment__c WHERE Id=:payment.Id];

                insertedPayment.asp04__Success_Endpoint_Long__c = URL.getOrgDomainUrl().toExternalForm() + '/'+ insertedPayment.id;

                update insertedPayment;
                system.debug('Success Link ==> '+ insertedPayment.asp04__Success_Endpoint_Long__c);

                system.debug('Payment Link ==> '+ insertedPayment.Payment_Link__c);

                return insertedPayment;
                */
                // return null can be removed when Card Payment has been enabled and the code has been uncommented.
                return null;
            }else{
                return insertedApp;
            } 
        } else{
            return null;
        }

    }

    @future
    public static void sendInvoiceForTransfer(String applicationId){
        Application__c insertedApp = [SELECT Id, Site__c, Applicant_Contact__c, Send_Application_Confirmation_Email__c, Send_Invoice__c, Payment_Reference__c FROM Application__c WHERE Id =:applicationId];
        //insertedApp.Send_Application_Confirmation_Email__c = true;
        insertedApp.Send_Invoice__c = false; // prevent automatic sending of invoice to members
        update insertedApp;
    }
}