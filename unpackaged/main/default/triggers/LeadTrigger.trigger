trigger LeadTrigger on Lead (after update) {
    
    // After Insert
    if(Trigger.isUpdate && Trigger.isAfter){
        EmailTemplate template = [SELECT Id, Subject, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Enquiry_Confirmation'];
        List<Lead> leadToUpdate = new List<Lead>();
        for(Lead l : Trigger.new){
            if(l.LogEnquiryConfirmation__c && l.Email != null && !l.EnquiryConfirmationLogged__c){
                LogEmailMessage.logEmailSent(l.Id, l.Email,null, template.Subject,template.htmlValue);
                Lead updatedLead = new Lead(Id=l.Id);
                updatedLead.EnquiryConfirmationLogged__c = true;
                
                leadToUpdate.add(updatedLead);
                
            }
            
        }
        update leadToUpdate;
        
    }

}