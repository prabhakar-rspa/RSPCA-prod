@isTest
public class TestDataFactory {
    Public static Account createHeadOfficeAccount(){
        Account act = new Account();
        act.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office').getRecordTypeId();
        act.Name = 'Test Head Office';
        act.Status__c = 'ENQUIRY';
        insert act;
        return act;
    }
    Public static Account createSiteAccount(Id parentAccount){
        Account site = new Account();
        site.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        site.Name = 'Test Site';
        site.ParentId = parentAccount;
        site.Company_Industry__c = 'Fish';
        site.Active__c = true;
        site.Membership_Expiry_Date__c = Date.today().addDays(42);
        insert site;
        return site;
    }
    public static Contact createContact(Id accountId){
        Contact cnt = new Contact();
        cnt.AccountId = accountId;
        cnt.FirstName = 'Test';
        cnt.LastName = 'Name';
        cnt.Email = 'test@test.com';
        insert cnt;
        return cnt;
    }
    public static Application__c createApplication(Id recordTypeId,Id headOfficeId,Id SiteId,Id contactId,Boolean create){
        Application__c app = new Application__c();
        app.RecordTypeId = recordTypeId;
        app.Existing_Member__c = 'No';
        app.Application_Type__c = 'New';
        app.Stage__c = 'Application';
        app.Head_Office__c = headOfficeId;
        app.Site__c = SiteId;
        app.Applicant_Contact__c = contactId;
        app.Evidence_Deadline__c = Date.today().addDays(6);
        app.Assessment_Date__c = system.today().addDays(-21);
        if(create)insert app;
        return app;
    }
    public static Bulk_Renewal__c createBulkRenewal(Id contactId,Id headOfficeId,Boolean create){
        Bulk_Renewal__c  bulk_renewal = new Bulk_Renewal__c();
        bulk_renewal.Application_Contact__c =  contactId;
        bulk_renewal.Head_Office__c = headOfficeId;
        if(create)insert bulk_renewal;
        return bulk_renewal;
    }
    public static Application_Line_Item__c createApplicationLineItem(Id productId,Id applicationId,Boolean create){
        Application_Line_Item__c lineItem = new Application_Line_Item__c();
        lineItem.Product__c = productId;
        lineItem.Application__c = applicationId;
        lineItem.List_Price__c = 10;
        lineItem.List_Price_Inc_Vat__c = 10;
        lineItem.Quantity__c = 1;
        if(create) insert lineItem;
        return lineItem;
    }
    public static PricebookEntry createPriceBookEntry(Id productId,Id pricebookId,Boolean create){
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = productId,
            UnitPrice = 12000, IsActive = true);
        if(create)insert pbe;
        return pbe;
    }
    Public static Unit__c createUnit(Id accountId,Boolean create){
        Unit__c unit1 = new Unit__c();
        unit1.Account__c = accountId;
        unit1.Name = '01';
        unit1.Business__c = 'Supply Chain';
        unit1.Ingredients__c = 'Beef';
        unit1.Production__c = 'Processor';
        unit1.Order_Sizes__C = 'Single';
        unit1.Status__c = 'Certified';
        if(create)insert unit1;
        return unit1;
    }
    Public static Product2 createProduct(Boolean create){
        Product2 product = new Product2();
        product.Name = 'Test product';
        product.ProductCode = 'Test code';
        product.IsActive = true;
        if(create)insert product;
        return product;
    }
    public static Document createDocument(String name){
        Document doc = new Document();
        doc.DeveloperName = name;
        doc.Body = Blob.valueOf('Some Text');
        doc.ContentType = 'application/pdf';
        doc.IsPublic = true;
        doc.AuthorId = UserInfo.getUserId();
		doc.FolderId = UserInfo.getUserId();
        doc.Name = name;
        insert doc;
        return doc;
    }
}