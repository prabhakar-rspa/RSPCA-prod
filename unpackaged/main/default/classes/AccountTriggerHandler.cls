global class AccountTriggerHandler extends TriggerHandler{
    public AccountTriggerHandler(){
    }

    public override void beforeUpdate(){
        AccountTriggerHandler.createSiteNumber((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.newMap);
        AccountTriggerHandler.createHeadOfficeNumber((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.newMap);
        //firstRunBeforeUpdate = false;
        updateAccountStatus((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap); 
    }

    public override void afterUpdate(){
        createRenewalPriceReport((List<Account>)Trigger.new, (Map<Id,Account>)Trigger.oldMap);
    }


    // Method to create the 4 digit site number for the site account
    public static void createSiteNumber(List<Account> newAccounts, Map<Id, Account> newAccountsMap){
        
        // Site Account Record type
        String siteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId();
        
        // List to store only the site accounts
        List<Account> siteAccounts = new List<Account>();
        
        // Set of head office number for the site accounts
        Set<String> headOfficeNumberSet = new Set<String>();
        
        // iterate through the new accounts and filter only the site record type accounts
        for(Account a : newAccounts){
            if(a.RecordTypeId == siteRecordTypeId && a.ParentId != null && a.Head_Office_Number_of_Parent_Account__c != null && a.Site_Number__c == null && a.Generate_Site_Number__c){
                siteAccounts.add(a);
                headOfficeNumberSet.add(a.Head_Office_Number_of_Parent_Account__c);
            }
            system.debug('Generate Site Number ==> ' + a.Generate_Site_Number__c);
        }
        
        // Only execute the following actions if there are site records where site number needs to be generated
        if(!siteAccounts.isEmpty()){
            // Map of head office number to list of site numbers
            Map<String, List<String>> headOfficeSiteNumberMap = new Map<String, List<String>>();
            
            // Iterate through the new accounts and map the site numbers to the head office number for that account.
            for(Account a : [SELECT Id, Head_Office_Number_of_Parent_Account__c, Site_Number__c FROM Account WHERE Head_Office_Number_of_Parent_Account__c =:headOfficeNumberSet]){
                if(headOfficeSiteNumberMap.containsKey(a.Head_Office_Number_of_Parent_Account__c)) {
                    List<String> siteNumbers = headOfficeSiteNumberMap.get(a.Head_Office_Number_of_Parent_Account__c);
                    siteNumbers.add(a.Site_Number__c);
                    headOfficeSiteNumberMap.put(a.Head_Office_Number_of_Parent_Account__c, siteNumbers);
                } else {
                    headOfficeSiteNumberMap.put(a.Head_Office_Number_of_Parent_Account__c, new List<String> {a.Site_Number__c});
                }
            }
            
            // Iterate through the new accounts and assign the next number from the highest site number to the Site Number field
            for(Account a : siteAccounts){
                if(headOfficeSiteNumberMap.containsKey(a.Head_Office_Number_of_Parent_Account__c)) {
                    List<String> siteNumbersForParent = headOfficeSiteNumberMap.get(a.Head_Office_Number_of_Parent_Account__c);
                    System.debug(siteNumbersForParent);
                    System.debug('List size ==> ' + siteNumbersForParent.size());
                    Integer highestValue;
                    for(String siteNumber : siteNumbersForParent){
                        String textValue = siteNumber;
                        // Set the text value to '0' if the string is null to avoid null pointer exception when converting text to integer
                        if(textValue == null){
                            textValue = '0';
                        }
                        Integer intValue = Integer.valueOf(textValue);
                        
                        if(highestValue == null || intValue > highestValue){
                            highestValue = intValue;
                        }
                    }
                    system.debug('Generate Site Number ==> ' + a.Generate_Site_Number__c);
                    if(a.Generate_Site_Number__c == true){
                        a.Site_Number__c = String.valueOf(++highestValue).leftPad(4, '0');
                    }
                    
                }
            }
            System.debug('New Accounts ==> ' + siteAccounts.size());
        }
        
    }
    
    // Method to create the 4 digit head office number for the head office account
    public static void createHeadOfficeNumber(List<Account> newAccounts, Map<Id, Account> newAccountsMap){
        
        // Head Office Account Record type
        String headOfficeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Head_Office').getRecordTypeId();
        
        // List to store only the head Office accounts
        List<Account> headOfficeAccounts = new List<Account>();
        
        // Iterate through the new accounts and filter only the head office record type accounts
        for(Account a : newAccounts){
            if(a.RecordTypeId == headOfficeRecordTypeId && a.Head_Office_Number__c == null && a.Generate_Head_Office_Number__c){
                headOfficeAccounts.add(a);
            }
        }

        // Only execute the following actions if there are head office records where head office number needs to be generated
        if(!headOfficeAccounts.isEmpty()){
            Integer highestValue = 0;
            
            for(Account a : [SELECT Id, Head_Office_Number__c FROM Account WHERE Head_Office_Number__c != null ORDER BY Head_Office_Number__c DESC NULLS LAST LIMIT 1]) {
                String textValue = a.Head_Office_Number__c;
                if(textValue == null){
                    textValue = '0';
                }
                // convert string to integer
                Integer intValue = Integer.valueOf(textValue);

                if(intValue > highestValue){
                    highestValue = intValue;
                }  

            }
            
            // Iterate through the head office acounts from trigger new that was filterd into headOfficeAccounts list
            for(Account a : headOfficeAccounts){
                if(a.Generate_Head_Office_Number__c == true){
                    a.Head_Office_Number__c = String.valueOf(++highestValue).leftPad(4, '0');
                }  
            }
        }
    }

    /** This method updates the Account status based on Outcome field **/
    public static void updateAccountStatus(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        for(Account act : newAccounts){
            Account oldAct = oldAccountsMap.get(act.Id);
            if(act.Outcome_Approved_By_Certifier__c != null && act.Outcome__c != null && act.Outcome_Approved_By_Certifier__c != oldAct.Outcome_Approved_By_Certifier__c){
                if(act.Outcome__c == 'Reinstate'){
                    act.Status__c = 'MEMBER';
                }else if(act.Outcome__c == 'Withdraw'){
                    act.Status__c = 'WITHDRAWN';
                }
            }
        }
    }

    public static void createRenewalPriceReport(List<Account> newAccounts, Map<Id,Account> oldAccounts){
        Set<Id> accIds = new Set<Id>();
        
        for(Account act : newAccounts){
            if(act.Create_Renewal_Price_Report__c == true && oldAccounts.get(act.Id).Create_Renewal_Price_Report__c == false){
                RenewalPriceChecker rpc = new RenewalPriceChecker();
                rpc.createRenewalPriceReport(act.Id);
                accIds.add(act.Id);
            }
        }
        List<Account> accToUpdate = new List<Account>();
        for(Id i : accIds){
            Account a = new Account(Id=i, Create_Renewal_Price_Report__c = false);
            accToUpdate.add(a);
        }
        TriggerHandler.bypass('AccountTriggerHandler');
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
        TriggerHandler.clearBypass('AccountTriggerHandler');
    }
}