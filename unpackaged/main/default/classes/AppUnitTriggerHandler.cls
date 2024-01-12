public class AppUnitTriggerHandler extends AppUnitHelper{
    
    public static void OnBeforeInsert(List<Application_Unit__c> newUnits) {

    }

    public static void OnAfterInsert(List<Application_Unit__c> newUnits) {

        Id applicationRecordType = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Applications').getRecordTypeId();

        Set<String> unitId = new Set<String>();
        Set<String> appId = new Set<String>();

        Boolean additionalVehiclePrice = false;
        
        for(Application_Unit__c au:newUnits){
            if(au.Unit__c != null){
                unitId.add(au.Unit__c);
                appId.add(au.Application__c);
            }            
        }

        Set<String> siteIds = new Set<String>();

        Set<String> pricebookIds = new Set<String>();

        Map<Id, Application__c> appMap = new Map<Id, Application__c>();
        for(Application__c app : [SELECT Id,Assessment_Required__c,Re_visit_Fee_required__c, RecordTypeId, Site__c, Head_Office__r.BillingCountry, Existing_Member__c, Application_Type__c, Update_Type__c, Pricebook_Id__c, Site__r.Pig_Discount_Eligibility__c,RecordType.DeveloperName FROM Application__c WHERE Id =:appId]){
            appMap.put(app.Id, app);
            siteIds.add(app.Site__c);
            pricebookIds.add(app.Pricebook_Id__c);
        }
        
        getAllSiteUnits(siteIds);

        // get units for the application units created
        Map<Id, Unit__c> unitMap = getUnitsForCreatedAppUnit(unitId);
        system.debug('unitMap >>'+ unitMap);

        // method to get list of all products
        getProductList();

        // query all existing lines for applications
        getAllExistingLines(appId);

        // query pricebook entries for the pricebook on the application
        getAllPricebookEntries(pricebookIds);

        // query all app units for application
        getAllAppUnits(appId);
        
        Set<Id> renewalApplicationIdSet = new Set<Id>(); // Set of renewal applications to iterate through when calcualtion amounts for poultry units
        Map<Id,Decimal> numberOfChickensMap = new Map<Id,Decimal>(); // Map of Renewal Application Id to Number of Chickens on site
        Map<Id,Product2> chickensProductMap = new Map<Id,Product2>(); // Map of Renewal Application Id to Chicken Product

        Map<Id,Decimal> numberOfLayingHensMap = new Map<Id,Decimal>(); // Map of Renewal Application Id to Number of Laying Hens on site
        Map<Id,Product2> layingHensProductMap = new Map<Id,Product2>(); // Map of Renewal Application Id to Laying Hens Product

        Map<Id,Decimal> numberOfPulletsMap = new Map<Id,Decimal>(); // Map of Renewal Application Id to Number of Pullets on site
        Map<Id,Product2> pulletsProductMap = new Map<Id,Product2>(); // Map of Renewal Application Id to Pullet Product

        Map<Id,Decimal> numberOfTurkeysMap = new Map<Id,Decimal>(); // Map of Renewal Application Id to Number of Turkeys on site
        Map<Id,Product2> turkeysProductMap = new Map<Id,Product2>(); // Map of Renewal Application Id to Turkeys Product

        Map<Id,Decimal> numberOfDucksMap = new Map<Id,Decimal>(); // Map of Renewal Application Id to Number of Ducks on site
        Map<Id,Product2> ducksProductMap = new Map<Id,Product2>(); // Map of Renewal Application Id to Duck Product

        Set<Application__c> pigDiscountApplications = new Set<Application__c>(); // set of applications requiring pig discounts
        String pigDiscountStage = '';


        /*********************************************************************************
        List of application line item records to create.
        ***********************************************************************************/ 
        List<Application_Line_Item__c> productsToAdd = new List<Application_Line_Item__c>();
        
        /*********************************************************************************
        When units are created, check that the application is not blank and depending on 
        unit added, add the correct line item with the correct price which is defined in
        the product record.
        ***********************************************************************************/ 
        system.debug('newUnits >>'+ newUnits);
        for(Application_Unit__c u:newUnits){
            if(u.Application__c != null && u.Unit__c != null){
                Application__c app = appMap.get(u.Application__c);
                system.debug('u.Unit__c >>'+ u.Unit__c);
                system.debug('unitMap.get(u.Unit__c) >>'+ unitMap.get(u.Unit__c));
                Unit__c unitAdded = unitMap.get(u.Unit__c);
                system.debug('unitAdded >>'+ unitAdded);
                /*********************************************************************************
                Products    : Supply Chain
                Description : Checks to see if the business picklist value is supply chain. If it
                              is, check to see if there is an existing line item on the
                              application. Create line item if there is not.
                ***********************************************************************************/  
                if(unitAdded != null && unitAdded.Business__c =='Supply Chain'){
                    //find the supply chain product
                    Product2 unitProduct = AppUnitHelper.getProduct(unitAdded.Business__c, unitAdded.Production__c);
                    if(unitProduct != null){
                        //if product is found, check to see if this is already existing on line item
                        Boolean existingLineItem = AppUnitHelper.checkExistingLineItem(unitProduct.Id , u.Application__c);
                        Application_Line_Item__c appli = new Application_Line_Item__c();

                        if(!existingLineItem){ // As this product fee should only be applied once, only create line item for this if there are no existing line items
                            if(app.Application_Type__c == 'New'){
                                //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                                appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                insert appli;
                                //productsToAdd.add(appli);
                            }
                            if(app.Application_Type__c == 'Update' && app.Update_Type__c == 'New Unit'){
                                // Check if unit exists for the unitProduct for this site
                                Boolean existingSupplyChainUnit = AppUnitHelper.existingSupplyChainUnit(App.Site__c, unitProduct, unitAdded.Id);
                                System.debug('existingSupplyChainUnit => ' + existingSupplyChainUnit);
                                if(!existingSupplyChainUnit){ // If no unit exists for the site, add the line item fee
                                    //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                                    appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                    //productsToAdd.add(appli);
                                    insert appli;
                                }
                            }
                            if(app.Application_Type__c == 'Renewal' || app.Application_Type__c == 'Transfer'){
                                //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                                appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                //productsToAdd.add(appli);
                                insert appli;
                            }
                        }
                    }
                    
                    
                }
                /*********************************************************************************
                Products    : 
                Description : Checks to see if the correct product is found based on the criteria. 
                              If it is, check to see if there is an existing line item on the
                              application. Create line item if there is not.
                ***********************************************************************************/  
                
                if(app.RecordType.DeveloperName != 'Additional_Visit' && unitAdded != null && (unitAdded.Business__c != null) && (unitAdded.Animals__c != null) && (unitAdded.Production__c != null) ){

                    String vehicleType = unitAdded.Vehicle_Type__c;
                    // if business is haulier then do not fiiter the getProduct method by vehicle type
                    unitAdded.Animals_List__c = unitAdded.Animals_List__c != null?unitAdded.Animals_List__c:'';
                    if(unitAdded.Business__c == 'Haulier' && unitAdded.Animals__c != 'Salmon' && unitAdded.Animals__c != 'Trout' && !unitAdded.Animals_List__c.contains('Salmon') && !unitAdded.Animals_List__c.contains('Trout') ){
                        vehicleType = null;
                    }

                    //find product with matching fields
                    Product2 unitProduct = AppUnitHelper.getProduct(unitAdded.Business__c,unitAdded.Animals__c,unitAdded.Production__c, vehicleType,unitAdded.Animals_List__c);
                    system.debug('Unit Product ==> ' + unitProduct);
                    Boolean existingLineItem;
                    //if product is found, check to see if this is already existing on line item
                    if(unitProduct != null){
                        existingLineItem = AppUnitHelper.checkExistingLineItem(unitProduct.Id , u.Application__c);  
					}
                    system.debug('Unit Product ==> ' + unitProduct);
                    Application_Line_Item__c appli = new Application_Line_Item__c();
                    Application_Line_Item__c appli1 = new Application_Line_Item__c();
                    //if it is not existing on line item the create the product
                    system.debug('Existing Line Item ==> '+ existingLineItem);
                    system.debug('Unit Product ==> ' + unitProduct);
                    
                    if(unitProduct != null){
                        /*********************************************************************************
                        Pricing Model: Per Site
                        Description  : Static price and only charged once per site(account) regardless of 
                                       however many of the same units added.
                        ***********************************************************************************/ 
                        if(unitProduct.Pricing_Method__c == 'Per Site'){
                            if(!existingLineItem){
                                if(app.Application_Type__c == 'New'){
                                    appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                    insert appli;
                                }
                                if(app.Application_Type__c == 'Update' && app.Update_Type__c == 'New Unit'){
                                    // Check if unit exists for the unitProduct for this site
                                    Boolean existingPerSiteUnit = AppUnitHelper.existingPerSiteUnit(App.Site__c, unitProduct, unitAdded.Id);
                                    System.debug('existingPerSiteUnit => ' + existingPerSiteUnit);
                                    if(!existingPerSiteUnit){
                                        appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                        insert appli;
                                    }
                                }
                                if(app.Application_Type__c == 'Renewal' || app.Application_Type__c == 'Transfer'){
                                    appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                    insert appli;
                                }
                                AppUnitHelper.allExistingLines.add(appli);
                            }
                            // pig discount
                            if(unitAdded.Animals__c == 'Pigs' && !app.Re_visit_Fee_required__c){
                                Set<Id> certifiedPigBreedingFinishingRearingIds = new Set<Id>();
                                for(Unit__c pigUnits : AppUnitHelper.getPigBreedingRearingFinishingUnitCount(app.Site__c)){
                                    certifiedPigBreedingFinishingRearingIds.add(pigUnits.Id);
                                }
                                Integer countOfPigsBreedingFinishingRearingApplication = AppUnitHelper.getPigBreedingRearingFinishingAppCount(app.Id, certifiedPigBreedingFinishingRearingIds);

                                Integer pigBreedingFinishingRearingOverallCount = certifiedPigBreedingFinishingRearingIds.size() + countOfPigsBreedingFinishingRearingApplication;
                                
                                if(pigBreedingFinishingRearingOverallCount > 0 && app.Site__r.Pig_Discount_Eligibility__c){
                                    if(pigBreedingFinishingRearingOverallCount == 1) { 
                                        // Stage 1 discount
                                        System.debug('Stage 1 pig discount'); // -80 with VAT
                                        pigDiscountStage = 'Stage 1';
                                        pigDiscountApplications.add(app);
                                        
                                    }
                                    else if(pigBreedingFinishingRearingOverallCount == 2){
                                        // Stage 2 discount
                                        System.debug('Stage 2 pig discount'); // -40 with VAT
                                        pigDiscountStage = 'Stage 2';
                                        pigDiscountApplications.add(app);
                                        
                                    }
                                    else if(pigBreedingFinishingRearingOverallCount >= 3){ 
                                        // Stage 3 no discount
                                        System.debug('Stage 3 pig discount'); // -80 with VAT
                                        pigDiscountStage = 'Stage 3';
                                        pigDiscountApplications.add(app);
                                        
                                    }
                                }
                            }
                        }
                        /*********************************************************************************
                        Pricing Model: Dynamic Quantity Price
                        Description  : This pricing model selects the correct price depending on the number
                                       of animals for a specific unit. Standard price and any additional
                                       price for additional number of animals above the initial threshold.
                        ***********************************************************************************/ 
                        if(unitProduct.Pricing_Method__c == 'Dynamic Quantity Price'){
                            Product2 dynamicQuantityProduct = getDynamicQuantityProduct(unitProduct);
                            System.debug('Test 1 Product => ' + dynamicQuantityProduct);
                            // Roll up the number of animal 
                            Boolean existingLivestock = AppUnitHelper.existingLivestockUnit(app.Site__c, unitProduct, unitAdded.Id);
                            if(!existingLivestock || app.Application_Type__c == 'Renewal' || app.Application_Type__c == 'Transfer'){
                                if(!existingLineItem){
                                    //if the number of animals is less than or equal to the quantity threshold
                                    if(unitAdded.Number_of_Animals__c <= unitProduct.Quantity_Threshold__c){
                                        //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                                        appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                        appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                        insert appli;
                                        
                                    }else{
                                        //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Dynamic_Quantity_Price__c, 1, app.Head_Office__r.BillingCountry);
                                        appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, dynamicQuantityProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                        appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                        insert appli;
                                    }
                                }
                            }
                        }
                        /*********************************************************************************
                        Pricing Model: Additional Quantity Price
                        Description  : This pricing model selects has a standard price for the first unit 
                                       and an additional price for any additional unit. This does not look
                                       at the number of animals. It looks for the number of unit records.
                        ***********************************************************************************/
                        if(unitProduct.Pricing_Method__c == 'Additional Quantity Price'){
                            Product2 additionalQuantityProduct = getAdditionalQuantityProduct(unitProduct);
                            // Calculations for Vehicle Units and Catching Units
                            if((unitProduct.Family == 'Vehicle') || (unitProduct.Business__c =='Catching')){
                                Boolean existingVehicleOrCatching = AppUnitHelper.existingVehicleOrCatching(app.Site__c, unitProduct, unitAdded.Id);
                                if(!existingVehicleOrCatching || app.Application_Type__c == 'Renewal' || app.Application_Type__c == 'Transfer'){
                                    if(!existingLineItem){ // If line item does not exist on application, then standard price is applied
                                        if((unitProduct.Family == 'Vehicle') && (!unitAdded.Own_Transport__c) ){
                                            //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                                            appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                            appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                            insert appli;
                                            AppUnitHelper.allExistingLines.add(appli);
                                            existingLineItem = true;
                                        }
                                        if((!unitAdded.Own_Catching__c) && (unitProduct.Business__c =='Catching') ){
                                            //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                                            appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                            appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                            insert appli;
                                            AppUnitHelper.allExistingLines.add(appli);
                                            existingLineItem = true;
                                        }
                                    }else { // If line item does exist on application, then Additional quantity price is applied
                                        if((unitProduct.Family == 'Vehicle') && (!unitAdded.Own_Transport__c) ){
                                            //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Additional_Quantity_Price__c, 1, app.Head_Office__r.BillingCountry);
                                            appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, additionalQuantityProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                            appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                            appli.Additional__c = true;
                                            productsToAdd.add(appli);
                                        }
                                        if((!unitAdded.Own_Catching__c) && (unitProduct.Business__c =='Catching') ){
                                            //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Additional_Quantity_Price__c, 1, app.Head_Office__r.BillingCountry);
                                            appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, additionalQuantityProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                            appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                            appli.Additional__c = true;
                                            productsToAdd.add(appli);
                                        }
                                    }
                                }else{
                                    if((unitProduct.Family == 'Vehicle') && (!unitAdded.Own_Transport__c) ){
                                        //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Additional_Quantity_Price__c, 1, app.Head_Office__r.BillingCountry);
                                        appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, additionalQuantityProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                        appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                        appli.Additional__c = true;
                                        productsToAdd.add(appli);
                                    }
                                    if((!unitAdded.Own_Catching__c) && (unitProduct.Business__c =='Catching') ){
                                        //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Additional_Quantity_Price__c, 1, app.Head_Office__r.BillingCountry);
                                        appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, additionalQuantityProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                        appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                        appli.Additional__c = true;
                                        productsToAdd.add(appli);
                                    }
                                } 
                            }else{
                                if(unitProduct.Family == 'Poultry'){
                                    // Check Existing Poultry Units
                                    /*
                                    Decimal existingPoultry = AppUnitHelper.existingPoultryUnit(app.Site__c, unitProduct, unitAdded.Id);
                                    // If no other poultry unit exist on the site
                                    if(existingPoultry == 0){
                                        // if no poultry fee exists on the application
                                        if(!existingLineItem){
                                            //if the number of animals is less than or equal to the quantity threshold
                                            if(unitAdded.Number_of_Animals__c <= unitProduct.Quantity_Threshold__c){
                                                //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                                                appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                                appli.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                                insert appli;
                                            }else{
                                                // add 1 standard price fee and then 1 additional membership fee with quantity from the variable
                                                List<Application_Line_Item__c> initialUnits = new List<Application_Line_Item__c>();
                                                double q = Math.ceil(unitAdded.Number_of_Animals__c / unitProduct.Quantity_Threshold__c);
                                                //appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                                                appli = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, 1, app.Head_Office__r.BillingCountry);
                                                appli.Number_of_Animals__c = unitProduct.Quantity_Threshold__c;
                                                //appli1 = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Additional_Quantity_Price__c, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                                                appli1 = AppUnitHelper.createLineItem(u.Id, u.Application__c, additionalQuantityProduct.Id, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                                                appli1.Additional__c = true;
                                                double additionalAnimals = unitAdded.Number_of_Animals__c - unitProduct.Quantity_Threshold__c;
                                                appli1.Number_of_Animals__c = additionalAnimals;
                                                initialUnits.add(appli);
                                                initialUnits.add(appli1);
                                                insert initialUnits;
                                            } 
                                        }
                                        // if poultry fee already exists on the application
                                        else{
                                            // Add membership fee by dividing the number of animals by the threshold to add 1 additional membership fee with quantity from the variable
                                            double q = Math.ceil(unitAdded.Number_of_Animals__c / unitProduct.Quantity_Threshold__c);
                                            //appli1 = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Additional_Quantity_Price__c, q, app.Head_Office__r.BillingCountry); 
                                            appli1 = AppUnitHelper.createLineItem(u.Id, u.Application__c, additionalQuantityProduct.Id, q, app.Head_Office__r.BillingCountry); 
                                            appli1.Additional__c = true;
                                            appli1.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                            productsToAdd.add(appli1);
                                        }
                                    }
                                    // if other poultry unit does exist on the site
                                    */
                                    //else{
                                        //if(app.Application_Type__c != 'Renewal' || app.Application_Type__c != 'Transfer'){

                                            //renewalApplicationId = u.Application__c;
                                            renewalApplicationIdSet.add(u.Application__c);
                                            
                                            if(unitAdded.Animals__c == 'Chickens'){
                                                //numberOfChickens = numberOfChickens + unitAdded.Number_Of_Animals__c;
                                                //chickensProduct = unitProduct;
                                                
                                                Decimal numOfAnimals = 0;
                                                if(numberOfChickensMap.containsKey(u.Application__c)){
                                                    numOfAnimals = numberOfChickensMap.get(u.Application__c);
                                                }
                                                numberOfChickensMap.put(u.Application__c, numOfAnimals + unitAdded.Number_Of_Animals__c);
                                                chickensProductMap.put(u.Application__c, unitProduct);

                                            }
                                            if(unitAdded.Animals__c == 'Laying Hens'){
                                                //numberOfLayingHens = numberOfLayingHens + unitAdded.Number_Of_Animals__c;
                                                //layingHensProduct = unitProduct;
                                                Decimal numOfAnimals = 0;
                                                if(numberOfLayingHensMap.containsKey(u.Application__c)){
                                                    numOfAnimals = numberOfLayingHensMap.get(u.Application__c);
                                                }
                                                numberOfLayingHensMap.put(u.Application__c, numOfAnimals + unitAdded.Number_Of_Animals__c);
                                                layingHensProductMap.put(u.Application__c, unitProduct);

                                            }
                                            if(unitAdded.Animals__c == 'Pullets'){
                                                //numberOfPullets = numberOfPullets + unitAdded.Number_Of_Animals__c;
                                                //pulletsProduct = unitProduct;
                                                Decimal numOfAnimals = 0;
                                                if(numberOfPulletsMap.containsKey(u.Application__c)){
                                                    numOfAnimals = numberOfPulletsMap.get(u.Application__c);
                                                }
                                                numberOfPulletsMap.put(u.Application__c, numOfAnimals + unitAdded.Number_Of_Animals__c);
                                                pulletsProductMap.put(u.Application__c, unitProduct);
                                            }
                                            if(unitAdded.Animals__c == 'Turkeys'){
                                                //numberOfTurkeys = numberOfTurkeys + unitAdded.Number_Of_Animals__c;
                                                //turkeysProduct = unitProduct;
                                                Decimal numOfAnimals = 0;
                                                if(numberOfTurkeysMap.containsKey(u.Application__c)){
                                                    numOfAnimals = numberOfTurkeysMap.get(u.Application__c);
                                                }
                                                numberOfTurkeysMap.put(u.Application__c, numOfAnimals + unitAdded.Number_Of_Animals__c);
                                                turkeysProductMap.put(u.Application__c, unitProduct);
                                            }
                                            if(unitAdded.Animals__c == 'Ducks'){
                                                //numberOfDucks = numberOfDucks + unitAdded.Number_Of_Animals__c;
                                                //ducksProduct = unitProduct;
                                                Decimal numOfAnimals = 0;
                                                if(numberOfDucksMap.containsKey(u.Application__c)){
                                                    numOfAnimals = numberOfDucksMap.get(u.Application__c);
                                                }
                                                numberOfDucksMap.put(u.Application__c, numOfAnimals + unitAdded.Number_Of_Animals__c);
                                                ducksProductMap.put(u.Application__c, unitProduct);
                                            }
                                        /*}else{
                                            // Add membership fee by dividing the number of animals by the threshold to add 1 additional membership fee with quantity from the variable
                                            double q = Math.ceil(unitAdded.Number_of_Animals__c / unitProduct.Quantity_Threshold__c);
                                            //appli1 = AppUnitHelper.createLineItem(u.Id, u.Application__c, unitProduct.Id, unitProduct.Additional_Quantity_Price__c, q, app.Head_Office__r.BillingCountry); 
                                            appli1 = AppUnitHelper.createLineItem(u.Id, u.Application__c, additionalQuantityProduct.Id, q, app.Head_Office__r.BillingCountry); 
                                            appli1.Additional__c = true;
                                            appli1.Number_of_Animals__c = unitAdded.Number_of_Animals__c;
                                            productsToAdd.add(appli1);
                                        }*/
                                        
                                    //}
                                }
                            }    
                        }
                    }
                }
            }
        }

        // create pig discount for application
        if(!pigDiscountApplications.isEmpty()){
            List<Application_Line_Item__c> appLiToCreate = new List<Application_Line_Item__c>();
            List<Application_Line_Item__c> deleteAppli = new List<Application_Line_Item__c>();
            for(Application__c app : pigDiscountApplications){
                Boolean existingPigDiscount1 = checkExistingPigDiscount1(app.Id);
                Boolean existingPigDiscount2 = checkExistingPigDiscount2(app.Id);
                Application_Line_Item__c appli = new Application_Line_Item__c();
                if (pigDiscountStage == 'Stage 1'){
                    if(!existingPigDiscount1){
                        appli = AppUnitHelper.createPigStage1DiscountLine(null, app.Id, 1, app.Head_Office__r.BillingCountry);
                        appLiToCreate.add(appli);
                    }
                    if(existingPigDiscount2){
                        // if there are existing pig stage 2 then delete it
                        deleteAppli.add(getExistingPigDiscount2LineItem(app.Id));
                    }
                }
                else if(pigDiscountStage == 'Stage 2'){
                    if(!existingPigDiscount2){
                        appli = AppUnitHelper.createPigStage2DiscountLine(null, app.Id, 1, app.Head_Office__r.BillingCountry);
                        appLiToCreate.add(appli);
                    }
                    if(existingPigDiscount1){
                        // if there are existing pig stage 1 then delete it
                        deleteAppli.add(getExistingPigDiscount1LineItem(app.Id));
                    }
                }
                else if(pigDiscountStage == 'Stage 3'){
                    // if stage 3 then no discount is applied. delete any existing stage discounts
                    if(existingPigDiscount1){
                        // if there are existing pig stage 1 then delete it
                        deleteAppli.add(getExistingPigDiscount1LineItem(app.Id));
                    }
                    if(existingPigDiscount2){
                        // if there are existing pig stage 2 then delete it
                        deleteAppli.add(getExistingPigDiscount2LineItem(app.Id));
                    }
                }
                
            }
            if(!appLiToCreate.isEmpty()){
                insert appLiToCreate;
            }
            if(!deleteAppli.isEmpty()){
                delete deleteAppli;
            }
        }
        // Start poultry calcualtion using the NumberOf<Animals> variable
        if(renewalApplicationIdSet.size() > 0){
            List<Application_Line_Item__c> deleteAppli = new List<Application_Line_Item__c>();
            for(Id renewalApplicationId : renewalApplicationIdSet){
                Application__c app = appMap.get(renewalApplicationId);
                //retrieve chicken numbers for this renewal application
                Decimal numberOfChickens = 0;
                if(numberOfChickensMap.containsKey(renewalApplicationId)){
                    //numberOfChickens = numberOfChickensMap.get(renewalApplicationId);
                    numberOfChickens = AppUnitHelper.getTotalAnimalNumbersForSpecies('Chickens', renewalApplicationId);
                    deleteAppli.addAll(getExistingPoultryLineItems(app.Id, 'Chickens'));
                }
                Product2 chickensProduct;
                if(chickensProductMap.containsKey(renewalApplicationId)){
                    chickensProduct = chickensProductMap.get(renewalApplicationId);
                }

                //retrieve laying hen numbers for this renewal application
                Decimal numberOfLayingHens = 0;
                if(numberOfLayingHensMap.containsKey(renewalApplicationId)){
                    //numberOfLayingHens = numberOfLayingHensMap.get(renewalApplicationId);
                    numberOfLayingHens = AppUnitHelper.getTotalAnimalNumbersForSpecies('Laying Hens', renewalApplicationId);
                    deleteAppli.addAll(getExistingPoultryLineItems(app.Id, 'Laying Hens'));
                }
                Product2 layingHensProduct;
                if(layingHensProductMap.containsKey(renewalApplicationId)){
                    layingHensProduct = layingHensProductMap.get(renewalApplicationId);
                }

                //retrieve pullet numbers for this renewal application
                Decimal numberOfPullets = 0;
                if(numberOfPulletsMap.containsKey(renewalApplicationId)){
                    //numberOfPullets = numberOfPulletsMap.get(renewalApplicationId);
                    numberOfPullets = AppUnitHelper.getTotalAnimalNumbersForSpecies('Pullets', renewalApplicationId);
                    deleteAppli.addAll(getExistingPoultryLineItems(app.Id, 'Pullets'));
                }
                Product2 pulletsProduct;
                if(pulletsProductMap.containsKey(renewalApplicationId)){
                    pulletsProduct = pulletsProductMap.get(renewalApplicationId);
                }

                //retrieve turkey numbers for this renewal application
                Decimal numberOfTurkeys = 0;
                if(numberOfTurkeysMap.containsKey(renewalApplicationId)){
                    //numberOfTurkeys = numberOfTurkeysMap.get(renewalApplicationId);
                    numberOfTurkeys = AppUnitHelper.getTotalAnimalNumbersForSpecies('Turkeys', renewalApplicationId);
                    deleteAppli.addAll(getExistingPoultryLineItems(app.Id, 'Turkeys'));
                }
                Product2 turkeysProduct;
                if(turkeysProductMap.containsKey(renewalApplicationId)){
                    turkeysProduct = turkeysProductMap.get(renewalApplicationId);
                }

                //retrieve duck numbers for this renewal application
                Decimal numberOfDucks = 0;
                if(numberOfDucksMap.containsKey(renewalApplicationId)){
                    //numberOfDucks = numberOfDucksMap.get(renewalApplicationId);
                    numberOfDucks = AppUnitHelper.getTotalAnimalNumbersForSpecies('Ducks', renewalApplicationId);
                    deleteAppli.addAll(getExistingPoultryLineItems(app.Id, 'Ducks'));
                }
                Product2 ducksProduct;
                if(ducksProductMap.containsKey(renewalApplicationId)){
                    ducksProduct = ducksProductMap.get(renewalApplicationId);
                }
                
                // Start the calculation for each of the animals for each renewal application
                if(numberOfChickens > 0){
                    if(numberOfChickens <= chickensProduct.Quantity_Threshold__c){
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, chickensProduct.Id, chickensProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, chickensProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = numberOfChickens;
                        productsToAdd.add(appli);
                    }else{
                        Product2 chickensAdditionalProduct = getAdditionalQuantityProduct(chickensProduct);
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        Application_Line_Item__c appli1 = new Application_Line_Item__c();
                        double q = Math.ceil(numberOfChickens / chickensProduct.Quantity_Threshold__c);
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, chickensProduct.Id, chickensProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, chickensProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = chickensProduct.Quantity_Threshold__c;
                        //appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, chickensProduct.Id, chickensProduct.Additional_Quantity_Price__c, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, chickensAdditionalProduct.Id, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1.Additional__c = true;
                        double additionalAnimals = numberOfChickens - chickensProduct.Quantity_Threshold__c;
                        appli1.Number_of_Animals__c = additionalAnimals;
                        productsToAdd.add(appli);
                        productsToAdd.add(appli1);
                    } 
                }
                if(numberOfLayingHens > 0){
                    if(numberOfLayingHens <= layingHensProduct.Quantity_Threshold__c){
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, layingHensProduct.Id, layingHensProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, layingHensProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = numberOfLayingHens;
                        productsToAdd.add(appli);
                    }else{
                        Product2 layingHensAdditionalProduct = getAdditionalQuantityProduct(layingHensProduct);
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        Application_Line_Item__c appli1 = new Application_Line_Item__c();
                        double q = Math.ceil(numberOfLayingHens / layingHensProduct.Quantity_Threshold__c);
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, layingHensProduct.Id, layingHensProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, layingHensProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = layingHensProduct.Quantity_Threshold__c;
                        //appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, layingHensProduct.Id, layingHensProduct.Additional_Quantity_Price__c, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, layingHensAdditionalProduct.Id, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1.Additional__c = true;
                        double additionalAnimals = numberOfLayingHens - layingHensProduct.Quantity_Threshold__c;
                        appli1.Number_of_Animals__c = additionalAnimals;
                        productsToAdd.add(appli);
                        productsToAdd.add(appli1);
                    } 
                }
                if(numberOfPullets > 0){
                    if(numberOfPullets <= pulletsProduct.Quantity_Threshold__c){
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, pulletsProduct.Id, pulletsProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, pulletsProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = numberOfPullets;
                        productsToAdd.add(appli);
                    }else{
                        Product2 pulletAdditionalProduct = getAdditionalQuantityProduct(pulletsProduct);
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        Application_Line_Item__c appli1 = new Application_Line_Item__c();
                        double q = Math.ceil(numberOfPullets / pulletsProduct.Quantity_Threshold__c);
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, pulletsProduct.Id, pulletsProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, pulletsProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = pulletsProduct.Quantity_Threshold__c;
                        //appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, pulletsProduct.Id, pulletsProduct.Additional_Quantity_Price__c, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, pulletAdditionalProduct.Id, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1.Additional__c = true;
                        double additionalAnimals = numberOfPullets - pulletsProduct.Quantity_Threshold__c;
                        appli1.Number_of_Animals__c = additionalAnimals;
                        productsToAdd.add(appli);
                        productsToAdd.add(appli1);
                    } 
                }
                if(numberOfTurkeys > 0){
                    if(numberOfTurkeys <= turkeysProduct.Quantity_Threshold__c){
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, turkeysProduct.Id, turkeysProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, turkeysProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = numberOfTurkeys;
                        productsToAdd.add(appli);
                    }else{
                        Product2 turkeysAdditionalProduct = getAdditionalQuantityProduct(turkeysProduct);
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        Application_Line_Item__c appli1 = new Application_Line_Item__c();
                        double q = Math.ceil(numberOfTurkeys / turkeysProduct.Quantity_Threshold__c);
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, turkeysProduct.Id, turkeysProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, turkeysProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = turkeysProduct.Quantity_Threshold__c;
                        //appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, turkeysProduct.Id, turkeysProduct.Additional_Quantity_Price__c, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, turkeysAdditionalProduct.Id, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1.Additional__c = true;
                        double additionalAnimals = numberOfTurkeys - turkeysProduct.Quantity_Threshold__c;
                        appli1.Number_of_Animals__c = additionalAnimals;
                        productsToAdd.add(appli);
                        productsToAdd.add(appli1);
                    } 
                }
                if(numberOfDucks > 0){
                    if(numberOfDucks <= ducksProduct.Quantity_Threshold__c){
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, ducksProduct.Id, ducksProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, ducksProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = numberOfDucks;
                        productsToAdd.add(appli);
                    }else{
                        Product2 ducksAdditionalProduct = getAdditionalQuantityProduct(ducksProduct);
                        Application_Line_Item__c appli = new Application_Line_Item__c();
                        Application_Line_Item__c appli1 = new Application_Line_Item__c();
                        double q = Math.ceil(numberOfDucks / ducksProduct.Quantity_Threshold__c);
                        //appli = AppUnitHelper.createLineItem(null, renewalApplicationId, ducksProduct.Id, ducksProduct.Standard_Price__c, 1, app.Head_Office__r.BillingCountry);
                        appli = AppUnitHelper.createLineItem(null, renewalApplicationId, ducksProduct.Id, 1, app.Head_Office__r.BillingCountry);
                        appli.Number_of_Animals__c = ducksProduct.Quantity_Threshold__c;
                        //appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, ducksProduct.Id, ducksProduct.Additional_Quantity_Price__c, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1 = AppUnitHelper.createLineItem(null, renewalApplicationId, ducksAdditionalProduct.Id, q-1, app.Head_Office__r.BillingCountry); // q is minus by 1 as the first line items will add the first price
                        appli1.Additional__c = true;
                        double additionalAnimals = numberOfDucks - ducksProduct.Quantity_Threshold__c;
                        appli1.Number_of_Animals__c = additionalAnimals;
                        productsToAdd.add(appli);
                        productsToAdd.add(appli1);
                    } 
                }
            }
            if(!deleteAppli.isEmpty()){
                Set<Application_Line_Item__c> uniqueAppLine = new Set<Application_Line_Item__c>();
                uniqueAppLine.addAll(deleteAppli);
                deleteAppli = new List<Application_Line_Item__c>();
                deleteAppli.addAll(uniqueAppLine);
                delete deleteAppli;
            }
        }
        Database.insert(productsToAdd);
        
    }
}