public class FindAppLineItems {
	public Id appId {get; set;}
    public Boolean hasInvoiceLine {get;set;}
    public List<Application_Line_Item__c> getLineItems(){
        List<Application_Line_Item__c> lineItems;
        if(appId != null){
            lineItems = [SELECT Id, Application__c, Product_Name__c, Subtotal__c, Quantity__c, Number_of_Animals__c, List_Price__c, Line_Description__c FROM Application_Line_Item__c WHERE Application__c =:appId];
            if(lineItems.size() != 0){
                hasInvoiceLine = true;
            }
        }
        return lineItems;
    }
    public decimal getNetAmount(){
        Application__c app = [SELECT Id, Amount_Ex_VAT__c FROM Application__c WHERE Id=:appId];
        return app.Amount_Ex_VAT__c;
        
    }
    public decimal getVatAmount(){
        Application__c app = [SELECT Id, VAT__c FROM Application__c WHERE Id=:appId];
        return app.VAT__c;
    }
    public decimal getTotalAmount(){
        Application__c app = [SELECT Id, Total_Amount_Inc_VAT__c FROM Application__c WHERE Id=:appId];
        return app.Total_Amount_Inc_VAT__c.setscale(2,RoundingMode.DOWN);
    }
    
}