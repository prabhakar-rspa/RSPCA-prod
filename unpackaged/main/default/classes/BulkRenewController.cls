public without sharing class BulkRenewController {

    // This method gets the Contact from the community users record or from the Site's primary contact
    @AuraEnabled
    public static Contact fetchCustomerContact(String accId){
        Contact con = new Contact();
        String customerId = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
        Account site = [SELECT Id, Primary_Contact__c FROM Account WHERE Id=:accId];

        if(customerId != null){
            con = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: customerId];
            
        } else if(site != null){
            con = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: site.Primary_contact__c];
           
        }
        return con;

    }

    @AuraEnabled
    public static List<Account> getSites(Id accId) {
  	  List<Account> accList = new List<Account>();
      	for(Account a : [SELECT Id, Name, Status__c, Membership_Number__c, Membership_Expiry_Date__c, ParentId FROM Account WHERE ParentId=:accId AND Status__c != 'CANCELLED' AND (Membership_Expiry_Date__c = LAST_N_DAYS:14 OR Membership_Expiry_Date__c = TODAY OR Membership_Expiry_Date__c = NEXT_N_DAYS:70)]){
          accList.add(a);
          system.debug('Account Id ==> '+a.Id);
      	}
          
      return accList;
    }

    @AuraEnabled
    public static SObject createBulkRenewal(Id accId, boolean agreement, boolean noOffences, String payMethod , List<String> lstOfSiteIds, String poNumber){

        // Change so that all sites renew the same way
        //if(lstOfSiteIds.size() > 20){
        if(lstOfSiteIds.size() > 0){
            BulkRenewQueuable brq = new BulkRenewQueuable(accId,  agreement,  noOffences,  payMethod ,lstOfSiteIds,  poNumber);
            brq.run();
            return null;
        }else{

        
            
            // Parameeters passed from the lightning component
            System.debug('AccountId ==> ' + accId);
            System.debug('Agreeement ==> ' + agreement);
            System.debug('No Offences ==> ' + noOffences);
            System.debug('Payment Method ==> ' + payMethod);
            System.debug('List of Sites to Renew ==> ' + lstOfSiteIds);

            // Create a set to assign site account ids
            Set<String> siteIds = new Set<String>(lstOfSiteIds);

            // Create a list of site accounts to be able to iterate through
            List<Account> siteList = [SELECT Id, ParentId, Name, Primary_Contact__c, Previous_Assessor__c FROM Account WHERE Id=:siteIds];

            // Create a map variable to map the list of certified units to each site for the head office account
            Map<Id, List<Unit__c>> siteUnitMap = new Map<Id, List<Unit__c>>();

            // Create bulk renewal record to assign all of the renewal applications to
            Bulk_Renewal__c bulkRenewal = new Bulk_Renewal__c();
            bulkRenewal.Head_Office__c = accId;
            bulkRenewal.PO_Number__c = poNumber;
            
            // Insert the bulk renewal inside a try and catch
            try {
                insert bulkRenewal;
            }
            catch(Exception e) {
                system.debug('Error Exception happend'+ e.getMessage());
                throw new AuraHandledException('Error Exception happend'+ e.getMessage());
            }
            


            // Iterate through the list of units for these sites and map them to the correct site account ids
            for(Unit__c u : [SELECT Id, Account__c, Name, Business__c, Production__c, Rearing_System__c, Status__c  FROM Unit__c WHERE Account__c =:siteIds AND Status__c IN ('Lapsed', 'Certified')]){
                if(siteUnitMap.containsKey(u.Account__c)){
                    List<Unit__c> units = siteUnitMap.get(u.Account__c);
                    units.add(u);
                    siteUnitMap.put(u.Account__c, units);
                }else{
                    siteUnitMap.put(u.Account__c, new List<Unit__c>{u});
                }
            }

            // Renewal Application Record Type ID
            Id renewalRecordType = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();

            // List of renewal applications to create
            List<Application__c> renewalAppList = new List<Application__c>();

            // Iterate through the list of sites to create a renewal application
            for(Account a : siteList){
                Application__c newApp = new Application__c();
                newApp.RecordTypeId = renewalRecordType;
                newApp.Site__c = a.Id;
                newApp.Head_Office__c = a.ParentId;
                newApp.Agreement__c = agreement;
                newApp.No_Offences__c = noOffences;
                newApp.Payment_Method__c = payMethod;
                newApp.Existing_Member__c = 'Yes';
                newApp.Application_Type__c = 'Renewal';
                newApp.Bulk_Renewal__c = bulkRenewal.Id;

                if(a.Primary_Contact__c != null){
                    newApp.Applicant_Contact__c = a.Primary_Contact__c;
                    newApp.Signatory_Contact__c = a.Primary_Contact__c;
                    newApp.Agreement_Date__c = Date.today();
                }
                if(a.Previous_Assessor__c != null){
                    newApp.Assessor__c = a.Previous_Assessor__c;

                }

                // Add the application objec to the application list
                renewalAppList.add(newApp);
            }

            // Insert the list of applications in a try and catch
            try {
                insert renewalAppList;
            }
            catch(Exception e) {
                system.debug('Error Exception happend'+ e.getMessage());
                throw new AuraHandledException('Error Exception happend'+ e.getMessage());
            }

            // List of Application units to create for the renewal application
            List<Application_Unit__c> appUnitList = new List<Application_Unit__c>();

            // Iterate through the inserted list of applications and create application unit records
            for(Application__c app : renewalAppList){
                if(siteUnitMap.containsKey(app.Site__c)){
                    // Get the list of units for the account this application is for
                    List<Unit__c> siteUnits = siteUnitMap.get(app.Site__c);

                    //now create application unit and attach it to application
                    for(Unit__c u: siteUnits){
                        Application_Unit__c appUnit = new Application_Unit__c();
                        appUnit.Application__c = app.Id;
                        appUnit.Unit__c = u.Id;
                        appUnitList.add(appUnit);
                    }

                }
                
            }
            
            // Insert the list of application unit inside a try and catch
            try{
                insert appUnitList;
            }catch(Exception e) {
                system.debug('Error Exception happend'+ e.getMessage());
                throw new AuraHandledException('Error Exception happend'+ e.getMessage());
            }

            // Query Bulk Renewal Record from database
            Bulk_Renewal__c br = [SELECT Id, Name, Head_Office__c, Payment_Reference__c, Total_Amount_Inc_VAT__c, Create_Sage_Invoice__c, Application_Contact__c FROM Bulk_Renewal__c WHERE Id =: bulkRenewal.Id];
            
            // Query Head Office Account from database
            Account headOffice = [SELECT Id, Name,Primary_Contact__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry FROM Account WHERE Id =: accId];
            
            // Query Primary Contact From database
            Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id =: headOffice.Primary_Contact__c];

            br.Create_Sage_Invoice__c = false; // turn off auto creation of Sage Invoice
            if(con != null){
                br.Application_Contact__c = con.Id;
            }
            update br;

            
            
            
            if(payMethod == 'Card'){
                // The code below has been commented out due to card payment not being enabled. This ensures that the test classes pass. uncomment the code when card payments are enabled.
                /*
                // Create a payment record when Card is the chosen payment method
                asp04__Payment__c payment = new asp04__Payment__c();
                payment.Bulk_Renewal__c = br.Id;
                payment.asp04__Amount__c = br.Total_Amount_Inc_VAT__c;
                payment.asp04__Payment_Route_Options__c = 'Card';
                payment.asp04__First_Name__c = con.FirstName;
                payment.asp04__Last_Name__c = con.LastName;
                payment.asp04__Email__c = con.Email;
                payment.asp04__Company_Name__c = headOffice.Name;
                payment.asp04__Billing_Address_Street__c = headOffice.BillingStreet;
                payment.asp04__Billing_Address_City__c = headOffice.BillingCity;
                payment.asp04__Billing_Address_PostalCode__c = headOffice.BillingPostalCode;
                payment.asp04__Billing_Address_Country__c = headOffice.BillingCountry;
                
                // Insert the payment record inside a try and catch
                try{
                    insert payment;
                }catch(Exception e) {
                    system.debug('Error Exception happend'+ e.getMessage());
                    throw new AuraHandledException('Error Exception happend'+ e.getMessage());
                }
                
                asp04__Payment__c insertedPayment = [SELECT Id, Application__c, asp04__Amount__c, Payment_Link__c FROM asp04__Payment__c WHERE Id=:payment.Id];

                insertedPayment.asp04__Success_Endpoint_Long__c = URL.getOrgDomainUrl().toExternalForm() + '/'+ insertedPayment.id;

                // Update the payment record inside a try and catch
                try{
                    update insertedPayment;
                }catch(Exception e) {
                    system.debug('Error Exception happend'+ e.getMessage());
                    throw new AuraHandledException('Error Exception happend'+ e.getMessage());
                }
                
                system.debug('Success Link ==> '+ insertedPayment.asp04__Success_Endpoint_Long__c);
                system.debug('Payment Link ==> '+ insertedPayment.Payment_Link__c);

                // Return the payment record
                return insertedPayment;
                
                */
                return null;
                
            }else{
                // Return the bulk renewal record
                return br;
            }      
        }
    }
    
}