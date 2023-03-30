public class ContactTriggerHandler {
    
    public static void OnBeforeInsert(List<Contact> newCons) {
        //Enter method logic here
    }
    
    public static void OnAfterInsert(List<Contact> newCons) {
        Set<String> conId = new Set<String>();
        Set<String> conLeadId = new Set<String>(); 
        
        for(Contact con : newCons){
            conId.add(con.Id);
            if(con.ConvertedLeadID__c != null){
                conLeadId.add(con.ConvertedLeadID__c);
            }
            
        }
        
        List<Contact> conToUpdate = new List<Contact>();
        
        for(Contact con : [SELECT Id, Email, Generated_Community_Username__c FROM Contact WHERE Id =:conId]){            
            Boolean existingUserName;
            Boolean existingNickName;
            
            //check if username is already taken
            if(con.Email != null){
                existingUserName = ContactTriggerHelper.isUserNameTaken(con.Email);
                //if username is taken, add the contact id to the end of the email to make it unique
                if(existingUserName){
                    con.Generated_Community_Username__c = con.Email + '.' + con.Id;
                }
                //otherwise use the email as the username.
                else{
                    con.Generated_Community_Username__c = con.Email;
                }
                
                String emailString = con.Email;
                String nickName = emailString.substringBefore('@');
                existingNickName = ContactTriggerHelper.isNickNameTaken(nickName);
                if(existingNickName){
                    con.Generated_Community_Nickname__c = nickName + '.' + con.Id;
                }else{
                    con.Generated_Community_Nickname__c = nickName;
                }
            }

            conToUpdate.add(con);
            
            
        }
        update conToUpdate;
        
        EmailTemplate template = [SELECT Id, Subject, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName ='ApplicationInstructionsActivtyLog'];
        
        List<Enquiry_Standard__c> enqStandList = [SELECT Id, Standards_link__c, Standard_Name__c, Lead__c FROM Enquiry_Standard__c WHERE Lead__c=:conLeadId];
        //log email activity for application instructions
        for(Contact c : newCons){
            
            if(c.ConvertedLeadID__c != null){
                String salu;
                String fName;
                
                if(c.Salutation == null){
                    salu = '';
                }else{
                    salu = c.Salutation;
                }
                if(c.FirstName == null){
                    fName = '';
                }else{
                    fName = c.FirstName;
                }
                
                String body = template.HtmlValue;
                String mergeSalutation = body.replace('{!Contact.Salutation}', salu);
                String mergeFName = mergeSalutation.replace('{!Contact.FirstName}', fName);
                String mergeLastName = mergeFName.replace('{!Contact.LastName}', c.LastName);
                String mergeAppURL = mergeLastName.replace('{!Contact.Application_URL__c}', c.Application_URL__c);
                body = mergeAppURL;
                
                //if there are standards add the correct links to them
                if(enqStandList.size() > 0){
                    List<String> standardStringList = new List<String>();
                    for(Enquiry_Standard__c enq : enqStandList){
                        String standardsMarkup = '<li><a href="{!link}"style="color:#000000;text-decoration:underline;"target="_blank">RSPCA welfare standards for {!standardName}</a></li>';
                        system.debug('Link ==> ' + enq.Standards_link__c);
                        String addLink = standardsMarkup.replace('{!link}', enq.Standards_link__c);
                        String addName = addLink.replace('{!standardName}', enq.Standard_Name__c);
                        standardStringList.add(addName);
                    }
                    String standardsHtml;
                    if(standardStringList.size() > 0){
                        standardsHtml = String.join(standardStringList, '');
                    }
                    String finalBodyString = mergeAppURL.replace('<c:EnquiryStandardsList lid="{!relatedTo.ConvertedLeadID__c}"/>', standardsHtml);
                    
                	LogEmailMessage.logEmailSent(c.Id, c.Email, null, template.Subject,finalBodyString);
                }else{
                    
                	LogEmailMessage.logEmailSent(c.Id, c.Email, null, template.Subject,body);
                }
                
                
                
                
                
                
            }
            
        }
    }
    
    public static void OnBeforeUpdate(List<Contact> oldCons, List<Contact> updatedCons, Map<ID, Contact> conMap) {
        
        //Enter method logic here
    }
    
    public static void OnAfterUpdate(List<Contact> oldCons, List<Contact> updatedCons, Map<ID, Contact> conMap) {
        //Enter method logic here
    }
    
    
}