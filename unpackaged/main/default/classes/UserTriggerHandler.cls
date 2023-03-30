public class UserTriggerHandler {
    
    public static void sendCommunityInvitationEmail(User usr){
        EmailTemplate emailTemplate = [SELECT ID FROM EmailTemplate WHERE Name = 'NewMemberCommunityInvite'];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(usr.ContactId); 
        message.setSenderDisplayName('RSPCA Assured'); 
        message.setReplyTo('accounts@rspcaassured.org.uk');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(true);
        message.setTemplateID(emailTemplate.Id); 
        message.setWhatId(usr.Id);
        message.toAddresses = new String[] {usr.Email};
        System.debug('message '+message);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            if(messages != null && messages.size() > 0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                System.debug('results.size() '+results.size());
                if (results != null && results.size() > 0 && results[0].success){
                    System.debug('The email was sent successfully.');
                }else {
                    System.debug('The email failed to send: '+results[0].errors[0].message);
                }
            }
    }
}