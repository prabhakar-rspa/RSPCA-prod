public without sharing class RenewMembership {
    
    @AuraEnabled
    public static Account getAccount(String accId){
        Account acc = [SELECT Id, Name, Status__C FROM Account WHERE Id=:accId LIMIT 1];
        return acc;
    }
	
    @AuraEnabled
    public static Id getAppRecordTypeId(String recordTypeName){
        return Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    @AuraEnabled
    public static string getContactName(String accId){

        Contact con = new Contact();
        String customerId = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
        Account site = [SELECT Id, Primary_Contact__c FROM Account WHERE Id=:accId];

        if(customerId != null){
            con = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: customerId];
            String name = con.FirstName + ' ' + con.LastName;
            return name;
        } else if(site != null){
            con = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: site.Primary_contact__c];
            String name = con.FirstName + ' ' + con.LastName;
            return name;
        }
        return null;
    }

    @AuraEnabled
    public static List<Unit__c> getUnits(Id accId) {
  	  List<Unit__c> totalList = new List<Unit__c>();
      	for(Unit__c u : [SELECT id, name, Description__c, Number_of_Animals__c, Account__c FROM Unit__c WHERE Account__c=:accId AND Status__c IN ('Lapsed','Certified')]){
          totalList.add(u);
      	}	
      return totalList;
    }

    
    @AuraEnabled
    public static string createRenewalApplication(Id accId, boolean agreement, boolean noOffences, String payMethod , List<String> lstOfUnitIds){
        Account acc = [SELECT Id, ParentId, Name, Primary_Contact__c, Previous_Assessor__c FROM Account WHERE Id=:accId];
        
        Id renewalAppId;
        Id renewalRecordType = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Application__c newApp = new Application__c();
        newApp.RecordTypeId = renewalRecordType;
        newApp.Site__c = accId;
        newApp.Head_Office__c = acc.ParentId;
        newApp.Agreement__c = agreement;
        newApp.No_Offences__c = noOffences;
        newApp.Payment_Method__c = payMethod;
        newApp.Existing_Member__c = 'Yes';
        newApp.Application_Type__c = 'Renewal';

        if(acc.Primary_Contact__c != null){
            newApp.Applicant_Contact__c = acc.Primary_Contact__c;
            newApp.Signatory_Contact__c = acc.Primary_Contact__c;
            newApp.Agreement_Date__c = Date.today();
        }
        if(acc.Previous_Assessor__c != null){
            newApp.Assessor__c = acc.Previous_Assessor__c;

        }



        try {
            // Inserting the application
            insert newApp;
            renewalAppId = newApp.Id;
   
        }
        catch(Exception e) {
            System.debug('Error Exception happend'+ e.getMessage());
            throw new AuraHandledException('Error Exception happend'+ e.getMessage());
        }

        List<Application_Unit__c> appUnitList = new List<Application_Unit__c>();
        system.debug('RenewalAppId ==> '+ renewalAppId);
        //now create application unit and attach it to application
        if(renewalAppId != null){
            System.debug('lstOfUnitIds => ' + lstOfUnitIds);
            for(String unitId:lstOfUnitIds){
                Application_Unit__c appUnit = new Application_Unit__c();
                appUnit.Application__c = renewalAppId;
                appUnit.Unit__c = unitId;
                appUnitList.add(appUnit);

        	}
   
        }
		System.debug('appUnit list size => ' + appUnitList.size());
        try{
            insert appUnitList;
        }catch(Exception e) {
            throw new AuraHandledException('Error Exception happend'+ e.getMessage());
        }

        
        Application__c app1 = new Application__c(Id=renewalAppId);
        app1.Send_Invoice__c = false; // prevent automatic invoice pdf to member
        update app1;
        
        // Returning the new ID
        return renewalAppId;
        
    }
}