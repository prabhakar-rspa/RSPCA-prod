@isTest
public class RenewalPriceCheckerTest {
	@testSetup
    static void loadData(){
        List<Product2> productList = New List<Product2>();
        Product2 product = New Product2();
        product.Name= 'testProduct';
        product.Business__c='Supply Chain';
        product.Animal__c='Pigs';
        product.ProductCode='PIGSTAGE1DISCOUNT';
        product.Production__c='Processor';  
        product.IsActive=true;
        product.Pricing_Method__c='Per Site';
        product.Quantity_Threshold__c=5; 
        product.Family='Vehicle';
        product.Additional_Quantity_Pricing_Component__c=false;
        product.Dynamic_Quantity_Pricing_Component__c=false;        
        product.Vehicle_Type__c='Van';
        productList.add(product);
        
        product = New Product2();
        product.Name= 'testProduct2';
        product.Business__c='Abattoir';
        product.Animal__c='Pigs';
        product.ProductCode='PIGSTAGE1DISCOUNT';
        product.Production__c='Rearing';  
        product.IsActive=true;
        product.Pricing_Method__c='Per Site';
        product.Quantity_Threshold__c=5; 
        product.Family='Vehicle';
        product.Additional_Quantity_Pricing_Component__c=false;
        product.Dynamic_Quantity_Pricing_Component__c=false;        
        product.Vehicle_Type__c='Van';
        productList.add(product);
        
        product = New Product2();
        product.Name= 'testProduct3';
        product.Business__c='Producer';
        product.Animal__c='Pigs';
        product.ProductCode='PIGSTAGE1DISCOUNT';
        product.Production__c='Breeding to rearing';  
        product.IsActive=true;
        product.Pricing_Method__c='Per Site';
        product.Quantity_Threshold__c=5; 
        product.Family='Vehicle';
        productList.add(product);
        
        product = New Product2();
        product.Name= 'testProduct4';
        product.Business__c='Producer';
        product.Animal__c='Beef Cattle';
        product.ProductCode='PIGSTAGE1DISCOUNT';
        product.Production__c='Finishing';  
        product.IsActive=true;
        product.Pricing_Method__c='Dynamic Quantity Price';
        product.Quantity_Threshold__c=5; 
        //product.Dynamic_Quantity_Pricing_Component__c = true;
        product.Family='Vehicle';
        productList.add(product);
        
        
        product = New Product2();
        product.Name= 'testProduct4';
        product.Business__c='Producer';
        product.Animal__c='Chickens';
        product.ProductCode='PIGSTAGE1DISCOUNT';
        product.Production__c='Producer';  
        product.IsActive=true;
        product.Pricing_Method__c='Additional Quantity Price';
        product.Quantity_Threshold__c=5; 
        product.Family='Vehicle';
        productList.add(product);
        
        product = New Product2();
        product.Name= 'testProduct4';
        product.Business__c='Catching';
        product.Animal__c='Turkeys';
        product.ProductCode='PIGSTAGE1DISCOUNT';
        product.Production__c='Catching Team';  
        product.IsActive=true;
        product.Pricing_Method__c='Additional Quantity Price';
        product.Quantity_Threshold__c=5; 
        //product.Additional_Quantity_Pricing_Component__c = true;
        product.Family='Vehicle';
        productList.add(product);
        
        insert productList;
        
       Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;

        Contact cnt = new Contact();
        cnt.AccountId = act.Id;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;

        act.Primary_Contact__c = cnt.Id;
        update act;

        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = act.Id;
        site.Company_Industry__c = 'Fish';
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(14);
        site.Status__c = 'Member';
        site.Pig_Discount_Eligibility__c = true;
        insert site;

		Renewal_Price_Report__c report = new Renewal_Price_Report__c();
        report.Site__c = site.Id;
        report.Membership_Expiry_Date__c = Date.today().addDays(14);
        insert report;
        Renewal_Price_Line__c line = new Renewal_Price_Line__c();
        line.Renewal_Price_Report__c = report.Id;
        line.Total_Inc_VAT__c = 100;
        insert line;

        Application__c app = new Application__c();
        app.RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = act.Id;
        app.Site__c = site.Id;
        app.Applicant_Contact__c = cnt.Id;
        insert app;     


        List<Unit__c> units = new List<unit__c>();
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = site.Id;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unit1.Status__c = 'Certified';
        units.add(unit1);

        Unit__c unit2 = new Unit__c();
        unit2.Account__c = site.Id;
        unit2.Name = '02';
        unit2.Business__c = 'Supply Chain';
        unit2.Ingredients__c = 'Beef';
        unit2.Production__c = 'Processor';
        unit2.Order_Sizes__C = 'Single';
        unit2.Status__c = 'Certified';
        units.add(unit2);
        
        Unit__c unit3 = new Unit__c();
        unit3.Account__c = site.Id;
        unit3.Name = '03';
        unit3.Business__c = 'Producer';
        unit3.Production__c = 'Rearing';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Pigs';
        units.add(unit3);
        
        unit3 = new Unit__c();
        unit3.Account__c = site.Id;
        unit3.Name = '04';
        unit3.Business__c = 'Producer';
        unit3.Production__c = 'Breeding';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Ducks';
        units.add(unit3);

        
        
        unit3 = new Unit__c();
        unit3.Account__c = site.Id;
        unit3.Name = '05';
        unit3.Business__c = 'Catching';
        unit3.Production__c = 'Catching Team';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Ducks';
        units.add(unit3);
        
        unit3 = new Unit__c();
        unit3.Account__c = site.Id;
        unit3.Name = '05';
        unit3.Business__c = 'Hatchery';
        unit3.Production__c = 'Hatchery';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Salmon';
        units.add(unit3);
        
        unit3 = new Unit__c();
        unit3.Account__c =site.Id;
        unit3.Name = '05';
        unit3.Business__c = 'Haulier';
        unit3.Production__c = 'Haulier';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Salmon';
        unit3.Vehicle_Type__c = 'Wellboat';
        units.add(unit3);
        insert units;
    }
    @isTest
    static void testmethod1(){
        Account act = [SELECT Id FROM Account WHERE Name='Test Site'];
        RenewalPriceChecker checker = new RenewalPriceChecker();
        checker.accId = act.Id;
        checker.createRenewalPriceReport(act.Id);
    }

    @isTest
    static void testmethod2(){
        Account act = [SELECT Id FROM Account WHERE Name='Test Site'];
        List<Unit__c> units = new List<unit__c>();
        Unit__c unit3 = new Unit__c();
        

        unit3 = new Unit__c();
        unit3.Account__c = act.Id;
        unit3.Name = '06';
        unit3.Business__c = 'Producer';
        unit3.Production__c = 'Breeding to rearing';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Pigs';
        units.add(unit3);
        
        insert units;


        RenewalPriceChecker checker = new RenewalPriceChecker();
        checker.accId = act.Id;
        checker.createRenewalPriceReport(act.Id);
        checker.getNetAmount();
        checker.getVatAmount();
    }

    @isTest
    static void testmethod3(){
        List<RenewalPriceChecker.RenewalPriceUnitLine> listSite = new List<RenewalPriceChecker.RenewalPriceUnitLine>();
        RenewalPriceChecker checker = new RenewalPriceChecker();
        
    }

    @isTest
    static void testmethod4(){        
        List<RenewalPriceChecker.RenewalPriceUnitLine> listHO = new List<RenewalPriceChecker.RenewalPriceUnitLine>();
        RenewalPriceChecker checker = new RenewalPriceChecker();
        listHO = checker.getRenewalPriceLineForHeadOffice();
        
    }
    @isTest
    static void testmethod5(){
        Account act = [SELECT Id FROM Account WHERE Name='Test Site'];
        List<Unit__c> units = new List<unit__c>();
        Unit__c unit3 = new Unit__c();
        unit3 = new Unit__c();
        unit3.Account__c = act.Id;
        unit3.Name = '06';
        unit3.Business__c = 'Producer';
        unit3.Production__c = 'Finishing';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Beef Cattle';
        units.add(unit3);
        insert units;
        Product2 product = New Product2();
        product.Name= 'testProduct4';
        product.Business__c='Producer';
        product.Animal__c='Beef Cattle';
        product.ProductCode='PIGSTAGE1DISCOUNT';
        product.Production__c='Finishing';  
        product.IsActive=true;
        product.Pricing_Method__c='Additional Quantity Price';
        product.Quantity_Threshold__c=5; 
        product.Additional_Quantity_Pricing_Component__c = true;
        product.Family='Vehicle';
        product.Additional_Quantity_Product__c = [SELECT Id FROM Product2 WHERE Animal__c = 'Beef Cattle'].Id;
        insert product;

        RenewalPriceChecker checker = new RenewalPriceChecker();
        checker.accId = act.Id;
        checker.createRenewalPriceReport(act.Id);
        
    }
    @isTest
    static void testmethod6(){
        Account act = [SELECT Id FROM Account WHERE Name='Test Site'];
        List<Unit__c> units = new List<unit__c>();
        Unit__c unit3 = new Unit__c();
        unit3 = new Unit__c();
        unit3.Account__c = act.Id;
        unit3.Name = '06';
        unit3.Business__c = 'Producer';
        unit3.Production__c = 'Producer';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Chickens';
        unit3.Number_of_Animals__c = 5;
        unit3.Own_Transport__c = true;
        units.add(unit3);
        insert units;
        RenewalPriceChecker checker = new RenewalPriceChecker();
        checker.accId = act.Id;
        checker.createRenewalPriceReport(act.Id);
        
    }
    @isTest
    static void testmethod8(){
        Account act = [SELECT Id FROM Account WHERE Name='Test Site'];
        List<Unit__c> units = new List<unit__c>();
        Unit__c unit3 = new Unit__c();
        unit3 = new Unit__c();
        unit3.Account__c = act.Id;
        unit3.Name = '06';
        unit3.Business__c = 'Producer';
        unit3.Production__c = 'Producer';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'Chickens';
        unit3.Number_of_Animals__c = 5;
        units.add(unit3);
        insert units;
        RenewalPriceChecker checker = new RenewalPriceChecker();
        checker.accId = act.Id;
        checker.createRenewalPriceReport(act.Id);
        
    }
    @isTest
    static void testmethod7(){
        Account act = [SELECT Id FROM Account WHERE Name='Test Site'];
        RenewalPriceChecker checker = new RenewalPriceChecker();
        checker.accId = act.Id;
        checker.getRenewalPriceLineForSite();
    }
    @isTest
    static void testmethod9(){
        Account act = [SELECT Id FROM Account WHERE Name='Test Site'];
        List<Unit__c> units = new List<unit__c>();
        Unit__c unit3 = new Unit__c();
        unit3 = new Unit__c();
        unit3.Account__c = act.Id;
        unit3.Name = '06';
        unit3.Business__c = 'Catching';
        unit3.Production__c = 'Catching Team';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'List';
        unit3.Animals_List__c = 'Turkeys';
        unit3.Number_of_Animals__c = 5;
        units.add(unit3);
        insert units;
        RenewalPriceChecker checker = new RenewalPriceChecker();
        checker.accId = act.Id;
        checker.createRenewalPriceReport(act.Id);
        
    }
    @isTest
    static void testmethod10(){
        Account act = [SELECT Id FROM Account WHERE Name='Test Site'];
        List<Unit__c> units = new List<unit__c>();
        Unit__c unit3 = new Unit__c();
        unit3 = new Unit__c();
        unit3.Account__c = act.Id;
        unit3.Name = '06';
        unit3.Business__c = 'Catching';
        unit3.Production__c = 'Catching Team';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'List';
        unit3.Animals_List__c = 'Turkeys';
        unit3.Number_of_Animals__c = 5;
        units.add(unit3);
        unit3 = new Unit__c();
        unit3.Account__c = act.Id;
        unit3.Name = '07';
        unit3.Business__c = 'Catching';
        unit3.Production__c = 'Catching Team';
        unit3.Status__c = 'Certified';
        unit3.Animals__c = 'List';
        unit3.Animals_List__c = 'Turkeys';
        unit3.Number_of_Animals__c = 5;
        units.add(unit3);
        insert units;
        Product2 product = New Product2();
        product.Name= 'testProduct4';
        product.Business__c='Catching';
        product.Animal__c='Turkeys';
        product.ProductCode='PIGSTAGE1DISCOUNT';
        product.Production__c='Catching Team';  
        product.IsActive=true;
        product.Pricing_Method__c='Additional Quantity Price';
        product.Quantity_Threshold__c=5; 
        product.Additional_Quantity_Pricing_Component__c = true;
        product.Family='Vehicle';
        product.Additional_Quantity_Product__c = [SELECT Id FROM Product2 WHERE Animal__c = 'Turkeys'].Id;
        insert product;
        RenewalPriceChecker checker = new RenewalPriceChecker();
        checker.accId = act.Id;
        checker.createRenewalPriceReport(act.Id);
        checker.findDynamicQuantityPricing(unit3,product);
        product.Family ='Poultry';
        product.Business__c = 'Catching team';
        checker.findAdditionalQuantityPricing(unit3,product);
    }
}