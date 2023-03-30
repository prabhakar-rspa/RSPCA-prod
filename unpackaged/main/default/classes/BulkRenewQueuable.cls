public class BulkRenewQueuable {
    Id accId;
    Boolean agreement;
    Boolean noOffences;
    String payMethod;
    List<String> lstOfSiteIds;
    String poNumber;
    public BulkRenewQueuable(Id accId, boolean agreement, boolean noOffences, String payMethod , List<String> lstOfSiteIds, String poNumber) {
        this.accId = accId;
        this.agreement = agreement;
        this.noOffences = noOffences;
        this.payMethod = payMethod;
        this.lstOfSiteIds = lstOfSiteIds;
        this.poNumber = poNumber;
    }
    public void run() { 
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
        Database.executeBatch(new AppUnitInsertBatch(appUnitList),1);

        // Query Bulk Renewal Record from database
        Bulk_Renewal__c br = [SELECT Id, Name, Head_Office__c, Payment_Reference__c, Total_Amount_Inc_VAT__c, Create_Sage_Invoice__c, Application_Contact__c FROM Bulk_Renewal__c WHERE Id =: bulkRenewal.Id];
        
        // Query Head Office Account from database
        Account headOffice = [SELECT Id, Name,Primary_Contact__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry FROM Account WHERE Id =: accId];
        

        br.Create_Sage_Invoice__c = false; // turn off auto creation of Sage Invoice
        if(headOffice.Primary_Contact__c != null){
            br.Application_Contact__c = headOffice.Primary_Contact__c;
        }

        update br;

    }
}