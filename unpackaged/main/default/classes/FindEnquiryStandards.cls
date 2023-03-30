public class FindEnquiryStandards {
    public Id leadId {get; set;}
    
    public List<Enquiry_Standard__c> getEnquiryStandards(){
        List<Enquiry_Standard__c> standards;
        standards=[SELECT Id, Standards_link__c, Standard_Name__c FROM Enquiry_Standard__c WHERE Lead__c =:leadId];
        return standards;
    }
    
}