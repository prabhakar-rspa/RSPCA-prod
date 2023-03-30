public class RenewalPriceChecker extends AppUnitHelper{
    public Id accId {get; set;}
    public List<LineItem> lineItems {get;set;}
    public Account site {get;set;}
    public Decimal totalAmount {get;set;}
    public String groupName {get;set;}

    public RenewalPriceChecker() {
        lineItems = new List<LineItem>();
    }

    public void getRenewalPriceForUnits(List<Unit__c> unitsList){

        List<Unit__c> certifiedUnits = filterByCertifiedUnits(unitsList);
        

        if(!certifiedUnits.isEmpty()){
            getAllSiteUnits(getSiteIdsforUnits(certifiedUnits));
            getProductList();
            loadPriceBookEntries();
            findPricingForUnits(certifiedUnits);
        }
    }

    private List<Unit__c> filterByCertifiedUnits(List<Unit__c> unitList){
        List<Unit__c> certifiedUnits = new List<Unit__c>();
        // check which units are 'Certified'.
        for(Unit__c u : unitList){
            if(u.Status__c == 'Certified'){
                certifiedUnits.add(u);
            }
        }
        return certifiedUnits;
    }

    private Set<String> getSiteIdsforUnits(List<Unit__c> unitList){
        Set<String> siteIds = new Set<String>();
        for(Unit__c u : unitList){
            siteIds.add(u.Account__c);
        }
        return siteIds;
    }

    private void loadPriceBookEntries(){
        // query pricebooks
        List<Pricebook2> pricebooks = getPricebooks();
        // Find membership pricebook
        String memberPricebookId = getMembershipPricebookId(pricebooks);
        // query pricebook entries for the pricebook on the application
        if(memberPricebookId != null){
            getAllPricebookEntries(new Set<String> {memberPricebookId});
        }else {
            String standardPricebookId = getStandardPricebookId(pricebooks); 
            getAllPricebookEntries(new Set<String> {standardPricebookId});
        }
    }

    private List<Pricebook2> getPricebooks(){
        List<Pricebook2> pricebooks = [SELECT Id, Name FROM Pricebook2];
        return pricebooks;
    }

    private String getMembershipPricebookId(List<Pricebook2> pricebookList){
        // Find membership pricebook
        String memberPricebookId;
        for(Pricebook2 pb : pricebookList){
            if(pb.Name == 'Membership Price Book'){
                memberPricebookId = pb.Id;
            }
        }
        return memberPricebookId;
    }

    private String getStandardPricebookId(List<Pricebook2> pricebookList){
        // Find standard pricebook
        String standardPricebookId;
        for(Pricebook2 pb : pricebookList){
            if(pb.IsStandard){
                standardPricebookId = pb.Id;
            }
        }
        return standardPricebookId;
    }

    private void findPricingForUnits(List<Unit__c> unitList){
        Set<String> pigProduction = new Set<String>(); // using set to find unique counts of units with production
        for(Unit__c u : unitList){
            if(u.Business__c =='Supply Chain'){
                findSupplyChainPricing(u);
            }
            if(u.Business__c != null && u.Animals__c != null && u.Production__c != null){
                String vehicleType = u.Vehicle_Type__c;
                // if business is haulier then do not filter the getProduct method by vehicle type
                if(u.Business__c == 'Haulier' && u.Animals__c != 'Salmon'&& u.Animals__c != 'Trout'){
                    vehicleType = null;
                }
                //find product with matching fields
                Product2 unitProduct = AppUnitHelper.getProduct(u.Business__c, u.Animals__c, u.Production__c, vehicleType);
                if(unitProduct != null){
                    if(unitProduct.Pricing_Method__c == 'Per Site'){
                        findPerSiteUnitPricing(u, unitProduct);
                    }
                    if(unitProduct.Pricing_Method__c == 'Dynamic Quantity Price'){
                        findDynamicQuantityPricing(u, unitProduct);
                    }
                    if(unitProduct.Pricing_Method__c == 'Additional Quantity Price'){
                        findAdditionalQuantityPricing(u, unitProduct);
                    }
                }
            }
            if(u.Business__c == 'Producer' && u.Animals__c == 'Pigs'){
                if(u.Production__c == 'Breeding' || u.Production__c == 'Finishing' ||  u.Production__c == 'Rearing'){
                    pigProduction.add(u.Production__c);
                }
                if(u.Production__c == 'Breeding to rearing'){
                    pigProduction.add('Breeding');
                    pigProduction.add('Rearing');
                }
                if(u.Production__c == 'Breeding to finishing'){
                    pigProduction.add('Breeding');
                    pigProduction.add('Finishing');
                }
                if(u.Production__c == 'Rearing to finishing'){
                    pigProduction.add('Rearing');
                    pigProduction.add('Finishing');
                }
            }
        }

        if(site.Pig_Discount_Eligibility__c){
            LineItem item = new LineItem();
            if(pigProduction.size() == 1){
                String pigStage1DiscountId = '';
                for(Product2 p: AppUnitHelper.productList){
                    if(p.ProductCode == 'PIGSTAGE1DISCOUNT'){
                        pigStage1DiscountId = p.Id;
                        break;
                    }
                }
                
                item.lineDescription = 'Pigs Stage 1 Discount';
                item.priceExVAT = getPriceForProduct(pigStage1DiscountId);
                item.animalOrIngrediants = 'Pigs';
                item.quantity = 1;
                item.subtotal = item.priceExVAT * item.quantity;
                if(site.Parent.BillingCountry == 'United Kingdom'){
                    item.vat = item.subtotal * 0.2;
                }
                item.production = 'Discount';
                lineItems.add(item);
            }else if(pigProduction.size() == 2){
                String pigStage2DiscountId = '';
                for(Product2 p: AppUnitHelper.productList){
                    if(p.ProductCode == 'PIGSTAGE2DISCOUNT'){
                        pigStage2DiscountId = p.Id;
                        break;
                    }
                }
                item.lineDescription = 'Pigs Stage 2 Discount';
                item.priceExVAT = getPriceForProduct(pigStage2DiscountId);
                item.animalOrIngrediants = 'Pigs';
                item.quantity = 1;
                item.subtotal = item.priceExVAT * item.quantity;
                if(site.Parent.BillingCountry == 'United Kingdom'){
                    item.vat = item.subtotal * 0.2;
                }
                item.production = 'Discount';
                lineItems.add(item);
            }
        }


    }

    private void findSupplyChainPricing(Unit__c unit){
        Map<String, LineItem> productNameToLineItem = new Map<String, LineItem>();
        for(LineItem li : lineItems){
            productNameToLineItem.put(li.lineDescription, li);
        }
        //find the supply chain product
        Product2 unitProduct = AppUnitHelper.getProduct(unit.Business__c, unit.Production__c);
        if(unitProduct != null){
            LineItem item = new LineItem();
            item.lineDescription = unitProduct.Name;
            item.priceExVAT = getPriceForProduct(unitProduct.Id);
            item.animalOrIngrediants = unit.Ingredients__c;
            item.numberOfAnimals = unit.Number_of_Animals__c;
            item.quantity = 1;
            item.subtotal = item.priceExVAT * item.quantity;
            if(site.Parent.BillingCountry == 'United Kingdom'){
                item.vat = item.subtotal * 0.2;
            }
            item.production = unit.Production__c;
            item.unitId = unit.Id;
            productNameToLineItem.put(item.lineDescription, item);
        }
        lineItems = productNameToLineItem.values();
    }

    private void findPerSiteUnitPricing(Unit__c unit, Product2 unitProduct){
        Map<String, LineItem> productNameToLineItem = new Map<String, LineItem>();
        for(LineItem li : lineItems){
            productNameToLineItem.put(li.lineDescription, li);
        }

        LineItem item = new LineItem();
        item.lineDescription = unitProduct.Name;
        item.production = unit.Production__c;
        item.priceExVAT = getPriceForProduct(unitProduct.Id);
        item.animalOrIngrediants = unit.Animals__c;
        item.numberOfAnimals = unit.Number_of_Animals__c;
        item.quantity = 1;
        item.subtotal = item.priceExVAT * item.quantity;
        if(site.Parent.BillingCountry == 'United Kingdom'){
            item.vat = item.subtotal * 0.2;
        }
        item.production = unit.Production__c;
        item.unitId = unit.Id;
        productNameToLineItem.put(item.lineDescription, item);
        lineItems = productNameToLineItem.values();
    }

    private void findDynamicQuantityPricing(Unit__c unit, Product2 unitProduct){
        Product2 dynamicQuantityProduct = getDynamicQuantityProduct(unitProduct);
        //if the number of animals is less than or equal to the quantity threshold
        if(unit.Number_of_Animals__c <= unitProduct.Quantity_Threshold__c){
            LineItem item = new LineItem();
            item.lineDescription = unitProduct.Name;
            item.priceExVAT = getPriceForProduct(unitProduct.Id);
            item.animalOrIngrediants = unit.Animals__c;
            item.numberOfAnimals = unit.Number_of_Animals__c;
            item.quantity = 1;
            item.subtotal = item.priceExVAT * item.quantity;
            if(site.Parent.BillingCountry == 'United Kingdom'){
                item.vat = item.subtotal * 0.2;
            }
            item.production = unit.Production__c;
            item.unitId = unit.Id;
            lineItems.add(item);
        }else{
            LineItem item = new LineItem();
            item.lineDescription = dynamicQuantityProduct.Name;
            item.priceExVAT = getPriceForProduct(dynamicQuantityProduct.Id);
            item.animalOrIngrediants = unit.Animals__c;
            item.numberOfAnimals = unit.Number_of_Animals__c;
            item.quantity = 1;
            item.subtotal = item.priceExVAT * item.quantity;
            if(site.Parent.BillingCountry == 'United Kingdom'){
                item.vat = item.subtotal * 0.2;
            }
            item.production = unit.Production__c;
            item.unitId = unit.Id;
            lineItems.add(item);
        }
    }

    private void findAdditionalQuantityPricing(Unit__c unit, Product2 unitProduct){
        Map<String, LineItem> productNameToLineItem = new Map<String, LineItem>();
        for(LineItem li : lineItems){
            productNameToLineItem.put(li.lineDescription, li);
        }

        Boolean existingLineItem = false;
        if(productNameToLineItem.containsKey(unitProduct.Name)){
            existingLineItem = true;
        }

        Product2 additionalQuantityProduct = getAdditionalQuantityProduct(unitProduct);
        if((unitProduct.Family == 'Vehicle') || (unitProduct.Business__c =='Catching')){
            if(!existingLineItem){ // If line item does not exist on application, then standard price is applied
                if((unitProduct.Family == 'Vehicle') && (!unit.Own_Transport__c) ){
                    LineItem item = new LineItem();
                    item.lineDescription = unitProduct.Name;
                    item.priceExVAT = getPriceForProduct(unitProduct.Id);
                    item.animalOrIngrediants = unit.Animals__c;
                    item.numberOfAnimals = unit.Number_of_Animals__c;
                    item.quantity = 1;
                    item.subtotal = item.priceExVAT * item.quantity;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item.vat = item.subtotal * 0.2;
                    }
                    item.production = unit.Production__c;
                    item.unitId = unit.Id;
                    lineItems.add(item);
                }
                if((unitProduct.Family == 'Vehicle') && (unit.Own_Transport__c) ){
                    LineItem item = new LineItem();
                    item.lineDescription = unitProduct.Name;
                    item.priceExVAT = 0;
                    item.animalOrIngrediants = unit.Animals__c;
                    item.numberOfAnimals = unit.Number_of_Animals__c;
                    item.quantity = 1;
                    item.subtotal = item.priceExVAT * item.quantity;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item.vat = item.subtotal * 0.2;
                    }
                    item.production = unit.Production__c;
                    item.unitId = unit.Id;
                    lineItems.add(item);
                }
                if((!unit.Own_Catching__c) && (unitProduct.Business__c =='Catching') ){
                    LineItem item = new LineItem();
                    item.lineDescription = unitProduct.Name;
                    item.priceExVAT = getPriceForProduct(unitProduct.Id);
                    item.animalOrIngrediants = unit.Animals__c;
                    item.numberOfAnimals = unit.Number_of_Animals__c;
                    item.quantity = 1;
                    item.subtotal = item.priceExVAT * item.quantity;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item.vat = item.subtotal * 0.2;
                    }
                    item.production = unit.Production__c;
                    item.unitId = unit.Id;
                    lineItems.add(item);
                }
            }else { // If line item does exist on application, then Additional quantity price is applied
                if((unitProduct.Family == 'Vehicle') && (!unit.Own_Transport__c) ){
                    LineItem item = new LineItem();
                    item.lineDescription = additionalQuantityProduct.Name;
                    item.priceExVAT = getPriceForProduct(additionalQuantityProduct.Id);
                    item.animalOrIngrediants = unit.Animals__c;
                    item.numberOfAnimals = unit.Number_of_Animals__c;
                    item.quantity = 1;
                    item.subtotal = item.priceExVAT * item.quantity;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item.vat = item.subtotal * 0.2;
                    }
                    item.production = unit.Production__c;
                    item.unitId = unit.Id;
                    lineItems.add(item);
                }
                if((unitProduct.Family == 'Vehicle') && (unit.Own_Transport__c) ){
                    LineItem item = new LineItem();
                    item.lineDescription = additionalQuantityProduct.Name;
                    item.priceExVAT = 0;
                    item.animalOrIngrediants = unit.Animals__c;
                    item.numberOfAnimals = unit.Number_of_Animals__c;
                    item.quantity = 1;
                    item.subtotal = item.priceExVAT * item.quantity;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item.vat = item.subtotal * 0.2;
                    }
                    item.production = unit.Production__c;
                    item.unitId = unit.Id;
                    lineItems.add(item);
                }
                if((!unit.Own_Catching__c) && (unitProduct.Business__c =='Catching') ){
                    LineItem item = new LineItem();
                    item.lineDescription = additionalQuantityProduct.Name;
                    item.priceExVAT = getPriceForProduct(additionalQuantityProduct.Id);
                    item.animalOrIngrediants = unit.Animals__c;
                    item.numberOfAnimals = unit.Number_of_Animals__c;
                    item.quantity = 1;
                    item.subtotal = item.priceExVAT * item.quantity;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item.vat = item.subtotal * 0.2;
                    }
                    item.production = unit.Production__c;
                    item.unitId = unit.Id;
                    lineItems.add(item);
                }
            }
        }else{
            if(unitProduct.Family == 'Poultry'){ 
                Decimal existingNumberOfAnimals = unit.Number_of_Animals__c;
                List<LineItem> listItemsToKeep = new List<LineItem>();
                for(LineItem li : lineItems){
                    if(li.animalOrIngrediants == unit.Animals__c){
                        existingNumberOfAnimals = existingNumberOfAnimals + li.numberOfAnimals;
                    }else{
                        listItemsToKeep.add(li);
                    }
                }
                
                //if the number of animals is less than or equal to the quantity threshold
                if(existingNumberOfAnimals <= unitProduct.Quantity_Threshold__c){
                    LineItem item = new LineItem();
                    item.lineDescription = unitProduct.Name;
                    item.priceExVAT = getPriceForProduct(unitProduct.Id);
                    item.animalOrIngrediants = unit.Animals__c;
                    item.numberOfAnimals = existingNumberOfAnimals;
                    item.quantity = 1;
                    item.subtotal = item.priceExVAT * item.quantity;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item.vat = item.subtotal * 0.2;
                    }
                    item.production = unit.Production__c;
                    item.unitId = unit.Id;
                    listItemsToKeep.add(item);
                }else{
                    // add 1 standard price fee and then 1 additional membership fee with quantity from the variable
                    List<Application_Line_Item__c> initialUnits = new List<Application_Line_Item__c>();
                    double q = Math.ceil(existingNumberOfAnimals / unitProduct.Quantity_Threshold__c);
                    // line 1
                    LineItem item1 = new LineItem();
                    item1.lineDescription = unitProduct.Name;
                    item1.priceExVAT = getPriceForProduct(unitProduct.Id);
                    item1.animalOrIngrediants = unit.Animals__c;
                    item1.numberOfAnimals = unitProduct.Quantity_Threshold__c;
                    item1.quantity = 1;
                    item1.subtotal = item1.priceExVAT;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item1.vat = item1.subtotal * 0.2;
                    }
                    item1.production = unit.Production__c;
                    item1.unitId = unit.Id;
                    System.debug('item1 => ' + item1);
                    listItemsToKeep.add(item1);

                    // Line 2
                    LineItem item2 = new LineItem();
                    item2.lineDescription = additionalQuantityProduct.Name;
                    item2.priceExVAT = getPriceForProduct(additionalQuantityProduct.Id);
                    item2.animalOrIngrediants = unit.Animals__c;
                    item2.numberOfAnimals = existingNumberOfAnimals - unitProduct.Quantity_Threshold__c;
                    item2.quantity = q-1;
                    item2.subtotal = item2.priceExVAT * item2.quantity;
                    if(site.Parent.BillingCountry == 'United Kingdom'){
                        item2.vat = item2.subtotal * 0.2;
                    }
                    item2.production = unit.Production__c;
                    item2.unitId = unit.Id;
                    System.debug('item2 => ' + item2);
                    listItemsToKeep.add(item2);
                }
                
                lineItems = listItemsToKeep;
                System.debug('lineItems => ' + lineItems);
                
            }
        }
    
    }

    public class LineItem{
        public String lineDescription{get;set;}
        public Decimal priceExVAT{get;set;}
        public String animalOrIngrediants {get;set;}
        public Decimal numberOfAnimals {get;set;}
        public Double quantity {get;set;}
        public Decimal subtotal {get;set;}
        public Decimal vat {get;set;}
        public String production {get;set;}
        public String unitId {get;set;}

    }

    public List<RenewalPriceChecker.RenewalPriceUnitLine> getRenewalPriceLineForSite(){
        List<RenewalPriceUnitLine> rpulList = new List<RenewalPriceUnitLine>();
        List<Renewal_Price_Report__c> rpr = [SELECT Id, Site__r.Parent.Name, Name,Total_Inc_VAT__c, CreatedDate FROM Renewal_Price_Report__c WHERE Site__c = :accId AND Site__r.Renewal_Reminder_Ready__c = true ORDER BY CreatedDate DESC LIMIT 1];
        totalAmount = rpr[0].Total_Inc_VAT__c;
        groupName = rpr[0].Site__r.Parent.Name;
        List<AggregateResult> aggregateResultList = [SELECT Max(Animal_Or_Ingrediants__c)animalOrIngrediants, SUM(Number_Of_Animals__c)numberOfAnimals, SUM(Total_Inc_VAT__c)totalIncVAT, MAX(Production__c)production, UnitId__c, MAX(Renewal_Price_Report__r.Site__r.Membership_Number__c)membershipNumber, MAX(Renewal_Price_Report__r.Site__r.Name)siteName, MAX(Renewal_Price_Report__r.Membership_Expiry_Date__c)expiryDate FROM Renewal_Price_Line__c WHERE Renewal_Price_Report__r.Site__c = :accId AND Renewal_Price_Report__c = :rpr[0].Id GROUP BY UnitId__c];
        for(AggregateResult ar : aggregateResultList){
            RenewalPriceUnitLine rpul = new RenewalPriceUnitLine();
            rpul.member = (String)ar.get('siteName');
            if((String)ar.get('animalOrIngrediants') == 'Pigs' && (String)ar.get('production') == 'Discount'){
                rpul.member = 'Pig Discount';
            }
            rpul.membershipNumber = '';
            if(ar.get('membershipNumber') != null){
                rpul.membershipNumber = (String)ar.get('membershipNumber');
            }
            String animalsOrIngrediants = '';
            if((String)ar.get('animalOrIngrediants') != null){
                animalsOrIngrediants = (String)ar.get('animalOrIngrediants');
            }
            rpul.unitName = animalsOrIngrediants +' '+ (String)ar.get('production');
            if((Double)ar.get('numberOfAnimals') > 0){
                rpul.unitName =  rpul.unitName + ' (Qty: ' + Math.round((Double)ar.get('numberOfAnimals')) +')' ;
            }
            rpul.amountDue = ((Decimal)ar.get('totalIncVAT')).setScale(2);
            rpul.expiryDate = '';
            if((Date)ar.get('expiryDate') != null){
                rpul.expiryDate = String.valueOf(((Date)ar.get('expiryDate')).day()).leftPad(2,'0') +'/'+ String.valueOf(((Date)ar.get('expiryDate')).month()).leftPad(2,'0') +'/'+ String.valueOf(((Date)ar.get('expiryDate')).year());
            }
            rpulList.add(rpul);
        }
        return rpulList;
    }

    public List<RenewalPriceChecker.RenewalPriceUnitLine> getRenewalPriceLineForHeadOffice(){
        Date invitationReminderDate = Date.today();
        x6WeekRenewalReminderTestDate__c testDateSettingInvitation = x6WeekRenewalReminderTestDate__c.getOrgDefaults();
        if(testDateSettingInvitation.Use_Test_Date_Data__c == true && testDateSettingInvitation.Test_Date__c != null){
            invitationReminderDate = testDateSettingInvitation.Test_Date__c;
        }
        Date finalReminderDate = Date.today();
        x2WeekRenewalReminderTestDate__c testDateSettingFinal = x2WeekRenewalReminderTestDate__c.getOrgDefaults();
        if(testDateSettingFinal.Use_Test_Date_Data__c == true && testDateSettingFinal.Test_Date__c != null){
            finalReminderDate = testDateSettingFinal.Test_Date__c;
        }
        

        List<RenewalPriceUnitLine> rpulList = new List<RenewalPriceUnitLine>();
        totalAmount = 0;
        groupName = '';
        Set<String> reportIds = new Set<String>(); 
        List<AggregateResult> renewalReportAgg = [SELECT MAX(Id)id, MAX(Site__r.Parent.Name)headOfficeName, MAX(Total_Inc_VAT__c)totalIncVat, MAX(CreatedDate) FROM Renewal_Price_Report__c WHERE Site__r.ParentId = :accId AND Site__r.Renewal_Reminder_Ready__c = true AND (Site__r.Final_Renewal_Reminder_Sent__c = null OR Site__r.Six_Week_Renewal_Reminder_Sent__c = null) AND Site__r.Status__c = 'MEMBER' AND (Site__r.X6_Week_Renewal_Scheduled_Date__c =:invitationReminderDate OR Site__r.X2_Week_Renewal_Scheduled_Date__c =:finalReminderDate) GROUP BY Site__c];
        for(AggregateResult ar : renewalReportAgg){
            groupName = (String)ar.get('headOfficeName');
            reportIds.add( (String)ar.get('id') );
        }
        List<AggregateResult> aggregateResultList = [SELECT Max(Animal_Or_Ingrediants__c)animalOrIngrediants, SUM(Number_Of_Animals__c)numberOfAnimals, SUM(Total_Inc_VAT__c)totalIncVAT, MAX(Production__c)production, UnitId__c, MAX(Renewal_Price_Report__r.Site__r.Membership_Number__c)membershipNumber, MAX(Renewal_Price_Report__r.Site__r.Name)siteName, MAX(Renewal_Price_Report__r.Membership_Expiry_Date__c)expiryDate FROM Renewal_Price_Line__c WHERE Renewal_Price_Report__r.Site__r.ParentId = :accId AND Renewal_Price_Report__c IN :reportIds GROUP BY Renewal_Price_Report__r.Site__r.Site_Number__c, UnitId__c ORDER BY Renewal_Price_Report__r.Site__r.Site_Number__c ASC];
        for(AggregateResult ar : aggregateResultList){
            RenewalPriceUnitLine rpul = new RenewalPriceUnitLine();
            rpul.member = (String)ar.get('siteName');
            if((String)ar.get('animalOrIngrediants') == 'Pigs' && (String)ar.get('production') == 'Discount'){
                rpul.member = rpul.member + ' Pig Discount';
            }
            rpul.membershipNumber = '';
            if(ar.get('membershipNumber') != null){
                rpul.membershipNumber = (String)ar.get('membershipNumber');
            }
            String animalsOrIngrediants = '';
            if((String)ar.get('animalOrIngrediants') != null){
                animalsOrIngrediants = (String)ar.get('animalOrIngrediants');
            }
            rpul.unitName = animalsOrIngrediants +' '+ (String)ar.get('production');
            if((Double)ar.get('numberOfAnimals') > 0){
                rpul.unitName =  rpul.unitName + ' (Qty: ' + Math.round((Double)ar.get('numberOfAnimals')) +')' ;
            }
            rpul.amountDue = ((Decimal)ar.get('totalIncVAT')).setScale(2);
            rpul.expiryDate = '';
            if((Date)ar.get('expiryDate') != null){
                rpul.expiryDate = String.valueOf(((Date)ar.get('expiryDate')).day()).leftPad(2,'0') +'/'+ String.valueOf(((Date)ar.get('expiryDate')).month()).leftPad(2,'0') +'/'+ String.valueOf(((Date)ar.get('expiryDate')).year());
            }
            rpulList.add(rpul);


            totalAmount = totalAmount + rpul.amountDue;
        }
        return rpulList;
    }

    public void createRenewalPriceReport(String accountId){
        site = [SELECT Id, Parent.BillingCountry, Membership_Expiry_Date__c, Pig_Discount_Eligibility__c, Create_Renewal_Price_Report__c FROM Account WHERE ID =:accountId];
        List<Unit__c> unitsRecords = [SELECT Id, Name, Account__c, Animals__c, Business__c, Chassis_Number__c, Description__c, House_Type__c, Ingredients__c, Order_Sizes__c, Own_Catching__c, Own_Transport__c, Production__c, Rearing_System__c, Status__c, Vehicle_Registration__c, Vehicle_Type__c, Number_of_Animals__c FROM Unit__c WHERE Account__c =:accountId AND Status__c = 'Certified'];
        getRenewalPriceForUnits(unitsRecords);
        if(!lineItems.isEmpty()){
            Renewal_Price_Report__c rpr = new Renewal_Price_Report__c();
            rpr.Site__c = accountId;
            rpr.Membership_Expiry_Date__c = site.Membership_Expiry_Date__c;
            insert rpr;
            List<Renewal_Price_Line__c> rplList = new List<Renewal_Price_Line__c>();
            for(RenewalPriceChecker.LineItem li : lineItems){
                Renewal_Price_Line__c rpl = new Renewal_Price_Line__c();
                rpl.Renewal_Price_Report__c = rpr.Id;
                rpl.Name = li.lineDescription;
                rpl.Price_Ex_VAT__c = li.priceExVAT;
                rpl.Animal_Or_Ingrediants__c = li.animalOrIngrediants;
                rpl.Number_Of_Animals__c = li.numberOfAnimals;
                rpl.Quantity__c = li.quantity;
                rpl.Subtotal__c = li.subtotal;
                rpl.VAT__c = 0;
                if(li.vat != null){
                    rpl.VAT__c = li.vat;
                }
                rpl.Total_Inc_VAT__c = rpl.Subtotal__c + rpl.VAT__c;
                rpl.Production__c = li.production;
                rpl.UnitId__c = li.unitId;
                rplList.add(rpl);
            }
            insert rplList;
        }
        
    }

    public class RenewalPriceUnitLine{
        public String member{get;set;}
        public String membershipNumber{get;set;}
        public String unitName {get;set;}
        public String expiryDate {get;set;}
        public Decimal amountDue {get;set;}
    }

    public Decimal getNetAmount(){
        Decimal netAmount = 0;
        for(LineItem li : lineItems){
            netAmount = netAmount + li.subtotal;
        }
        return netAmount;
    }

    public Decimal getVatAmount(){
        Decimal vatAmount = 0;
        for(LineItem li : lineItems){
            vatAmount = vatAmount + li.vat;
        }
        return vatAmount;
    }

}