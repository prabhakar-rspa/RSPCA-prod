public without sharing class AdditionalApplicationController {

    // This method gets the Contact from the community users record or from the Site's primary contact
    @AuraEnabled
    public static Contact fetchCustomerContact(String siteId){
        Contact con = new Contact();
        String customerId = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
        Account site = [SELECT Id, Primary_Contact__c FROM Account WHERE Id=:siteId];

        if(customerId != null){
            con = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: customerId];

        } else if(site != null){
            con = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: site.Primary_contact__c];

        }
        return con;

    }


    // Create application with units
    @AuraEnabled
    public static SObject createAppWithUnits(Application__c app, List<Unit__c> units,boolean assessmentRequired,boolean createRevisitFee){

        System.debug(app);
        system.debug('Number of units to be created: ' + units.size());

        List<Unit__c> unitToCreate = new List<Unit__c>();
        List<Application_Unit__c> apuToCreate = new List<Application_Unit__c>();
        
        if(app != null){
            system.debug('assessmentRequired:::::'+assessmentRequired);
            system.debug('createRevisitFee:::::'+createRevisitFee);
            app.Assessment_Required__c = assessmentRequired;
            app.Re_visit_Fee_required__c = createRevisitFee;
            if(!assessmentRequired){
                String otherRT = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Other').getRecordTypeId();
                app.RecordTypeId = otherRT;
                app.Application_Type__c = 'Other';
                app.stage__c = 'Not Applicable';
                //app.Update_Type__c= '';
            }
            Insert app;
            if(units.size() != 0){
                // If new unit is selected as the update type
                if(app.Update_Type__c == 'New Unit'){
                    for(Unit__c u : units){
                        System.debug('Unit Production ==> ' + u.Production__c);
                        u.Account__c = app.Site__c;

                        if(u.Business__c == 'Supply Chain'){ // clear the animal field when business is supply chain to avoid invalid picklist value error
                            u.Animals__c = null;
                        }
                        if(u.Business__c == 'Abattoir'){
                            u.Production__c  = 'Abattoir';
                        }
                        if(u.Business__c  == 'Catching'){
                            u.Production__c  = 'Catching Team';
                        }
                        if(u.Business__c  == 'Cleaner Fish'){
                            u.Production__c  = 'Cleaner Fish';
                        }
                        if(u.Business__c  == 'Hatchery'){
                            u.Production__c  = 'Hatchery';
                        }
                        if(u.Business__c  == 'Haulier'){
                            u.Production__c  = 'Haulier';
                        }
                        if(u.Business__c == 'Producer' && u.Animals__c == 'Trout'){
                            u.Production__c = 'Freshwater';
                        }
                        if(u.Business__c == 'Producer' && (u.Animals__c == 'Chickens' || u.Animals__c == 'Ducks')){
                            u.Production__c = 'Producer';
                        }
                        if(u.Business__c == 'Producer' && u.Animals__c == 'Veal Calves'){
                            u.Production__c = 'Calves';
                        }
                        
                        unitToCreate.add(u);
                        system.debug('Unit: ' + u);
                    }
                    insert unitToCreate;
                    for(Unit__c u : unitToCreate){
                        Application_Unit__c apu = new Application_Unit__c(Unit__c = u.Id, Application__c = app.Id);
                        apuToCreate.add(apu);
                    }
                }
                // If update to flock size is selected as the update type
                else if(app.Update_Type__c == 'Update to flock size'){
                    for(Unit__c u : units){
                        Application_Unit__c apu = new Application_Unit__c(Unit__c = u.Id, Application__c = app.Id, Update_to_flock_size__c = u.Number_of_Animals__c);
                        apuToCreate.add(apu);
                    }

                }

                
                insert apuToCreate;
                if(createRevisitFee){
                    createRevisitFee(app);
                }
                app.Send_Application_Confirmation_Email__c = true;
                app.Send_Invoice__c = false; // prevent automatic sending of invoice to member
                update app;
                
                Application__c insertedApp = [SELECT Id, Site__c, Applicant_Contact__c, Total_Amount_Inc_VAT__c, Payment_Method__c, Payment_Reference__c FROM Application__c WHERE Id =:app.Id];
                system.debug('Total Amount Inc VAT ==> ' + insertedApp.Total_Amount_Inc_VAT__c);
                Application_Contact_Role__c apc = new Application_Contact_Role__c(Application__c = insertedApp.Id, Contact__c = insertedApp.Applicant_Contact__c);
                insert apc;
                
                if(insertedApp.Payment_Method__c == 'Card'){
                    //The code below has been commented out due to card payment not enabled. This allows test classes to meet code coverage.
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
                    return null;
                    
                }else{
                    return insertedApp;
                }      
            }else{
                return null;
            }   
        }else{
            return null;
        }
        
    }
    public static void createRevisitFee(Application__c app){
        Application__c application= [SELECT ID,Pricebook_Id__c FROM Application__c WHERE ID=:app.Id];
        List<Product2> activeProducts = [SELECT Id, Name, ProductCode, IsActive From Product2 WHERE IsActive=true AND ProductCode ='REVISIT'];
        system.debug('activeProducts:::'+activeProducts);
        system.debug('application:::'+application);

        if(activeProducts != null && activeProducts.size()>0 && application.Pricebook_Id__c != null){
            List<PricebookEntry> priceEntries = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive FROM PricebookEntry WHERE IsActive = true AND Pricebook2Id =:application.Pricebook_Id__c AND Product2Id =:activeProducts[0].Id ];
            Account headOffice = [SELECT Id, BillingCountry FROM Account WHERE Id =:app.Head_Office__c];
            if(priceEntries != null && priceEntries.size()>0){
                PricebookEntry revisitFeePBE = priceEntries[0];
                if(revisitFeePBE != null){
                    Application_Line_Item__c appli = new Application_Line_Item__c();
                    appli.Application__c = app.Id;
                    appli.Product__c = revisitFeePBE.Product2Id;
                    appli.List_Price__c = revisitFeePBE.UnitPrice;
                    if(headOffice.BillingCountry == 'United Kingdom'){
                        appli.List_Price_Inc_Vat__c = revisitFeePBE.UnitPrice + (revisitFeePBE.UnitPrice * 0.2);
                    }else{
                        appli.List_Price_Inc_Vat__c = revisitFeePBE.UnitPrice;
                    }
                    appli.Quantity__c = 1;
                    insert appli;
                }
            }
        }
    }
    @AuraEnabled
    public static List<Unit__c> getPoultryUnits(String siteId){

        Set<String> poultryAnimals = new Set<String>();
        poultryAnimals.add('Laying Hens');
        poultryAnimals.add('Pullets');
        poultryAnimals.add('Chickens');
        poultryAnimals.add('Ducks');
        poultryAnimals.add('Turkeys');

        if(siteId != null){
            List<Unit__c> poultryUnits = [SELECT id, name, Status__c, Account__c, Animals__c, Business__c, Production__c,Rearing_System__c, Number_of_Animals__c FROM Unit__c WHERE Status__c ='Certified' AND Account__c=:siteId AND Animals__c IN :poultryAnimals ];
            return poultryUnits;

        }else{
            return null;
        }
        
    }

    

    @AuraEnabled
    public static Integer getNewUnitNumber(String siteId){
        List<Integer> unitNumberInt = new List<Integer>();
        if(siteId != null){
            for(Unit__c u : [SELECT Id, Name, Account__c FROM Unit__c WHERE Account__c =:siteId ORDER BY Name ASC]){
                if(u != null){
                    Integer un = Integer.valueOf(u.Name);
                    unitNumberInt.add(un);

                }
            }
        }
        Integer lastNumberInList = unitNumberInt.size() -1;
        Integer highestNumber = unitNumberInt[lastNumberInList];
        Integer newUnitNumber = highestNumber +1;

        return newUnitNumber;
    }


}