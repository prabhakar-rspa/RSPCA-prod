public class MembershipPricesController {
    public Id accountId{get;set;}
    public MembershipPricesController(){
        accountId = ApexPages.currentPage().getParameters().get('id');
    }
    
}