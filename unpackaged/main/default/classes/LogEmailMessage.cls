public class LogEmailMessage {
    
    public static void logEmailSent(String toId, String emailTo, String relatedToId,String subject ,String body){
        // if EnhancedEmail Perm is enabled, create an EmailMessage object
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '3'; // email was sent
        emailMessage.fromAddress = 'help@rspcaassured.org.uk'; // from address
        emailMessage.fromName = 'Membership Services'; // from name
        emailMessage.subject = subject; // email subject
        emailMessage.htmlBody = body; // email body
        emailMessage.RelatedToId = relatedToId;
        // Contact, Lead or User Ids of recipients
        String[] toIds = new String[]{toId}; 
            emailMessage.toIds = toIds;
        // additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)
        emailMessage.toAddress = emailTo;
        insert emailMessage; // insert
        
        system.debug('EmailMessageId ==> ' + emailMessage.Id);
        
        
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.emailMessageId = emailMessage.id;
        emr.relationId = toId; // user id of the sender
        emr.relationType = 'ToAddress';
        insert emr;
    }
    
    
    
}