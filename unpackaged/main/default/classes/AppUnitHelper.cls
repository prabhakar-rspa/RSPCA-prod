public virtual class AppUnitHelper {

    public static List<Product2> productList;
    public static List<Unit__c> allSiteUnits;
    public static List<Application_Line_Item__c> allExistingLines;
    public static List<PricebookEntry> allPricebookEntires;
    public static List<Application_Unit__c> allApplicationUnits;

    // gets list of all products available for pricing calculation
    public static void getProductList(){
        productList = [
            SELECT 
            Id, 
            Name,
            Business__c,
            Animal__c,
            ProductCode,
            Production__c, 
            IsActive,
            Pricing_Method__c,
            Quantity_Threshold__c,  
            Family,
            Additional_Quantity_Pricing_Component__c,
            Dynamic_Quantity_Pricing_Component__c,
            Additional_Quantity_Product__c,
            Dynamic_Quantity_Product__c,
            Vehicle_Type__c
            FROM   Product2 
            WHERE  IsActive=true
        ];
    }

    // get pricebook entries for pricebook ids passed from application
    public static void getAllPricebookEntries(Set<String> pricebookIds){
        Set<String> productIdSet = new Set<String>();
        for(Product2 p :productList){
            productIdSet.add(p.Id);
        }
        allPricebookEntires = [
            SELECT 
            Id, 
            UnitPrice, 
            Product2Id, 
            Pricebook2Id, 
            IsActive 
            FROM PricebookEntry 
            WHERE 
            IsActive = true 
            AND Pricebook2Id IN :pricebookIds 
            AND Product2Id IN :productIdSet
        ];
    }

    // get price for a product from pricebook
    public static Decimal getPriceForProduct(String productId){
        Decimal price = 0;
        for(PricebookEntry pbe : allPricebookEntires){
            if(pbe.Product2Id == productId){
                price = pbe.UnitPrice;
                break;
            }
        }
        return price;
    }

    // get list of all sites units for the accounts
    public static void getAllSiteUnits(Set<String> siteIds){
        allSiteUnits = [
            SELECT 
            Id,
            Name, 
            Account__c,
            Business__c, 
            Animals__c, 
            Production__c, 
            Own_Transport__c, 
            Own_Catching__c, 
            Number_of_Animals__c,
            Status__c,
            Vehicle_Type__c
            FROM Unit__c 
            WHERE 
            Account__c IN :siteIds
        ];
    }

    // get all existing lines for applications
    public static void getAllExistingLines(Set<String> appIds){
        allExistingLines = [
            SELECT 
            Id,
            Product__c,
            Application__c
            FROM   Application_Line_Item__c
            WHERE  
            Application__c IN :appIds
        ];
    }

    // get all application units for application
    public static void getAllAppUnits(Set<String> appIds){
        allApplicationUnits = [
            SELECT 
            Id,
            Application__c,
            Unit__c,
            Business__c,
            Animals__c,
            Number_of_Animals__c,
            Production__c
            FROM Application_Unit__c
            WHERE
            Application__c =:appIds
        ];
    }

    // get units for the created application units only
    public static Map<Id, Unit__c> getUnitsForCreatedAppUnit(Set<String> unitIds){
        Map<Id, Unit__c> unitMap = new Map<Id, Unit__c>();
        for(Unit__c u: allSiteUnits){
            if(unitIds.contains(u.Id)){
                unitMap.put(u.Id,u);
            }
        }
        return unitMap;
    }

    //find products with business and production
    public static Product2 getProduct(string business, string production){
        Product2 productResult = null;
        for(Product2 p : productList){
            // ensure products returned are not additional quantity pricing component or dynamic quantity pricing component
            if(p.Additional_Quantity_Pricing_Component__c == false && p.Dynamic_Quantity_Pricing_Component__c == false){
                if(p.Business__c == business && p.Production__c.contains(production)){
                    productResult = p;
                }
            }  
        }
        return productResult;
    }
    
    //find products with business, animals and production
    public static Product2 getProduct(string business, string animals, string production, string vehicleType){
        Product2 productResult = null;
        for(Product2 p : productList){
            // ensure products returned are not additional quantity pricing component or dynamic quantity pricing component
            if(p.Additional_Quantity_Pricing_Component__c == false && p.Dynamic_Quantity_Pricing_Component__c == false){
                if(
                    p.Business__c == business && 
                    p.Production__c.contains(production) && 
                    p.Animal__c.contains(animals) &&
                    p.Vehicle_Type__c == vehicleType
                    ){
                        productResult = p;
                }
            }
        }
        return productResult;
    }

    // get additional quantity product
    public static Product2 getAdditionalQuantityProduct(Product2 product){
        Product2 productResult = null;
        for(Product2 p : productList){
            if(p.Id == product.Additional_Quantity_Product__c && p.Additional_Quantity_Pricing_Component__c){
                productResult = p;
            }
        }
        return productResult;
    }

    // get dynamic quantity product
    public static Product2 getDynamicQuantityProduct(Product2 product){
        Product2 productResult = null;
        for(Product2 p : productList){
            if(p.Id == product.Dynamic_Quantity_Product__c && p.Dynamic_Quantity_Pricing_Component__c){
                productResult = p;
            }
        }
        return productResult;
    }

    // check for existing supply chain unit on the site
    public static boolean existingSupplyChainUnit(String siteId, Product2 product, String unitAdded){
        Boolean existingUnit = false;
        for(Unit__c u : allSiteUnits){
            if( 
                u.Business__c == 'Supply Chain' && 
                u.Account__c == siteId && 
                u.Id != unitAdded && 
                u.Status__c == 'Certified' 
            ){
                    existingUnit = true;
            }
        }
        return existingUnit;
    }

    // check for existing units that are price on a per site basis
    public static Boolean existingPerSiteUnit(String siteId, Product2 product, String unitAdded){
        Boolean existingUnit = false;
        for(Unit__c u : allSiteUnits){
            if(
                u.Business__c == product.Business__c &&
                product.Animal__c.contains(u.Animals__c) &&
                product.Production__c.contains(u.Production__c) &&
                u.Account__c == siteId &&
                u.Id != unitAdded &&
                u.Status__c == 'Certified'
            ){
                existingUnit = true;
            }
        }
        return existingUnit;
    }

    // check for existing vehicle, catching 
    public static Boolean existingVehicleOrCatching(String siteId, Product2 product, String unitAdded){
        Boolean existingUnit = false;
        for(Unit__c u : allSiteUnits){
            if(
                u.Business__c == product.Business__c &&
                product.Animal__c.contains(u.Animals__c) &&
                product.Production__c.contains(u.Production__c) &&
                u.Account__c == siteId &&
                u.Id != unitAdded &&
                u.Status__c == 'Certified'
            ){
                existingUnit = true;
            }
        }
        return existingUnit;
    }

    public static Boolean existingLivestockUnit(String siteId, Product2 product, String unitAdded){
        Boolean existingUnit = false;
        for(Unit__c u : allSiteUnits){
            if(
                u.Business__c == product.Business__c &&
                product.Animal__c.contains(u.Animals__c) &&
                product.Production__c.contains(u.Production__c) &&
                u.Account__c == siteId &&
                u.Id != unitAdded &&
                u.Status__c == 'Certified'
            ){
                existingUnit = true;
            }
        }
        return existingUnit;
    }
    public static Decimal existingPoultryUnit(String siteId, Product2 product, String unitAdded){
        Decimal existingUnit = 0;
        for(Unit__c u : allSiteUnits){
            String unitProduction = '';
            if(u.Production__c != null){
                unitProduction = u.Production__c;
            }
            if(
                u.Business__c == product.Business__c &&
                product.Animal__c.contains(u.Animals__c) &&
                product.Production__c.contains(unitProduction) &&
                u.Account__c == siteId &&
                u.Id != unitAdded &&
                u.Status__c == 'Certified'
            ){
                existingUnit = existingUnit + u.Number_Of_Animals__c;
            }
        }
        return existingUnit;
    }
    
    public static Boolean checkExistingLineItem(Id productId, Id appId){
        Boolean existingLineItem = false;
        for(Application_Line_Item__c li : allExistingLines){
            if(
                li.Application__c == appId &&
                li.Product__c == productId
            ){
                existingLineItem = true;
                break;
            }
        }
        return existingLineItem;
    }

    public static boolean checkExistingPigDiscount1(Id appId){
        Boolean existingPigDiscount = false;
        String pigStage1DiscountId = null;
        for(Product2 p : productList){
            if(p.ProductCode == 'PIGSTAGE1DISCOUNT'){
                pigStage1DiscountId = p.Id;
                break;
            }
        }
        if(pigStage1DiscountId != null){
            existingPigDiscount = checkExistingLineItem(pigStage1DiscountId, appId);
        }
        return existingPigDiscount;
    }

    public static boolean checkExistingPigDiscount2(Id appId){
        Boolean existingPigDiscount = false;
        String pigStage2DiscountId = null;
        for(Product2 p : productList){
            if(p.ProductCode == 'PIGSTAGE2DISCOUNT'){
                pigStage2DiscountId = p.Id;
                break;
            }
        }
        if(pigStage2DiscountId != null){
            existingPigDiscount = checkExistingLineItem(pigStage2DiscountId, appId);
        }
        return existingPigDiscount;
    }

    public static Application_Line_Item__c getExistingPigDiscount1LineItem(Id appId){
        String pigStage1DiscountId = null;
        for(Product2 p : productList){
            if(p.ProductCode == 'PIGSTAGE1DISCOUNT'){
                pigStage1DiscountId = p.Id;
                break;
            }
        }
        Application_Line_Item__c existingLineItem = null;
        for(Application_Line_Item__c li : allExistingLines){
            if(
                li.Application__c == appId &&
                li.Product__c == pigStage1DiscountId
            ){
                existingLineItem = li;
                break;
            }
        }
        return existingLineItem;
    }

    public static Application_Line_Item__c getExistingPigDiscount2LineItem(Id appId){
        String pigStage2DiscountId = null;
        for(Product2 p : productList){
            if(p.ProductCode == 'PIGSTAGE2DISCOUNT'){
                pigStage2DiscountId = p.Id;
                break;
            }
        }
        Application_Line_Item__c existingLineItem = null;
        for(Application_Line_Item__c li : allExistingLines){
            if(
                li.Application__c == appId &&
                li.Product__c == pigStage2DiscountId
            ){
                existingLineItem = li;
                break;
            }
        }
        return existingLineItem;
    }

    public static Decimal getTotalAnimalNumbersForSpecies(String species, String applicationId){
        Decimal numAnimals = 0;
        for(Application_Unit__c au : allApplicationUnits){
            if(au.Animals__c == species && au.Application__c == applicationId){
                numAnimals = numAnimals + au.Number_of_Animals__c;
            }
        }
        return numAnimals;
    }

    public static List<Application_Line_Item__c> getExistingPoultryLineItems(Id appId, String species){
        Set<String> poultryProductIds = new Set<String>();
        for(Product2 p : productList){
            if(p.Family == 'Poultry' && p.Animal__c.contains(species)){
                poultryProductIds.add(p.Id);
            }
        }
        List<Application_Line_Item__c> existingLineItems = new List<Application_Line_Item__c>();
        for(Application_Line_Item__c li : allExistingLines){
            if(
                li.Application__c == appId &&
                poultryProductIds.contains(li.Product__c)
            ){
                existingLineItems.add(li);
            }
        }
        return existingLineItems;
    }

    // Create line item from application unit and product passed in
    public static Application_Line_Item__c createLineItem(Id appUnitId, Id appId, Id productId, Double quantity, String headOfficeBillingCountry){
        // get price for product
        Decimal price = getPriceForProduct(productId);
        System.debug('Price => ' + price);
        Application_Line_Item__c appli = new Application_Line_Item__c();
        appli.Application__c = appId;
        appli.Product__c = productId;
        appli.List_Price__c = price;
        appli.Quantity__c = quantity;
        appli.Application_Unit__c = appUnitId;
        if(headOfficeBillingCountry == 'United Kingdom'){
            appli.List_Price_Inc_Vat__c = price + (price * 0.2);
        }else {
            appli.List_Price_Inc_Vat__c = price;
        }
        
        
        return appli;
    }

    public static Application_Line_Item__c createPigStage1DiscountLine(Id appUnitId, Id appId, Double quantity, String headOfficeBillingCountry){
        String pigStage1DiscountId = null;
        for(Product2 p : productList){
            if(p.ProductCode == 'PIGSTAGE1DISCOUNT'){
                pigStage1DiscountId = p.Id;
                break;
            }
        }
        Application_Line_Item__c appli = createLineItem(appUnitId, appId, pigStage1DiscountId, quantity, headOfficeBillingCountry);
        return appli;
    }

    public static Application_Line_Item__c createPigStage2DiscountLine(Id appUnitId, Id appId, Double quantity, String headOfficeBillingCountry){
        String pigStage2DiscountId = null;
        for(Product2 p : productList){
            if(p.ProductCode == 'PIGSTAGE2DISCOUNT'){
                pigStage2DiscountId = p.Id;
                break;
            }
        }
        Application_Line_Item__c appli = createLineItem(appUnitId, appId, pigStage2DiscountId, quantity, headOfficeBillingCountry);
        return appli;
    }

    public static List<Unit__c> getPigBreedingRearingFinishingUnitCount(String siteId){
        Map<String, Unit__c> PigsBreedingRearingFinishing = new Map<String, Unit__c>();
        for(Unit__c u: allSiteUnits){
            if(
                u.Business__c == 'Producer' && 
                u.Animals__c == 'Pigs' && 
                u.Account__c == siteId &&
                u.Status__c == 'Certified' &&
                (
                    u.Production__c == 'Breeding' || 
                    u.Production__c == 'Finishing' || 
                    u.Production__c == 'Rearing'
                )
                ){
                    PigsBreedingRearingFinishing.put(u.Production__c, u);
            }
        }
        return PigsBreedingRearingFinishing.values();
    }

    public static integer getPigBreedingRearingFinishingAppCount(String appId, Set<Id> unitIds){
        Set<String> pigProduction = new Set<String>(); // using set to find unique counts of units with production
        Integer countOfPigsBreedingRearingFinishing = 0;
        for(Application_Unit__c au: allApplicationUnits){
            if(au.Business__c == 'Producer' && au.Animals__c == 'Pigs' && !unitIds.contains(au.Unit__c)){
                if(au.Production__c == 'Breeding' || au.Production__c == 'Finishing' ||  au.Production__c == 'Rearing'){
                    pigProduction.add(au.Production__c);
                }
                if(au.Production__c == 'Breeding to rearing'){
                    pigProduction.add('Breeding');
                    pigProduction.add('Rearing');
                }
                if(au.Production__c == 'Breeding to finishing'){
                    pigProduction.add('Breeding');
                    pigProduction.add('Finishing');
                }
                if(au.Production__c == 'Rearing to finishing'){
                    pigProduction.add('Rearing');
                    pigProduction.add('Finishing');
                }
            }
        }

        for(String s : pigProduction){
            countOfPigsBreedingRearingFinishing++;
        }
        return countOfPigsBreedingRearingFinishing;
    }

}