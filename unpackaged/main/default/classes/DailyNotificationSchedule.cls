global class DailyNotificationSchedule implements Database.Batchable<sObject>, Schedulable, Database.stateful {
    private static Set<String> emailTemplateNames = new Set<String>{
        'Daily_Notification_Member_Services',
        'Daily_Notification_Accounts',
        'Daily_Notification_NSF'
    };
    // Query all email templates from the email template names set
    private static List<EmailTemplate> emailTemplateList = [SELECT Id,DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName IN :emailTemplateNames];
    
    // Query the org wide email address
    private static OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'help@rspcaassured.org.uk'];

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,DeveloperName, Name, Type FROM Group WHERE Type = 'Regular']);
    }

    global void execute(Database.BatchableContext BC, List<Group> scope) {
        // Get the userType prefix
        String userType = Schema.SObjectType.User.getKeyPrefix();

        //Set for group Id
        Set<Id> groupIdSet = new Set<Id>();

        // iterate through the group to add the group id to the set
        for(Group g : scope){
            groupIdSet.add(g.Id);
        }

        // Group Id to User Id
        Map<Id, List<Id>> groupIdToUserId = new Map<Id, List<Id>>();

        // query and iterate through the group members of the groupIdSet and add user ids to the groupIdToUserId map
        for(GroupMember gm : [SELECT Id, UserOrGroupId,GroupId FROM GroupMember WHERE GroupId IN :groupIdSet]){
            if(((String)gm.UserOrGroupId).startsWith(userType)){
                if(groupIdToUserId.containsKey(gm.GroupId)){
                    List<Id> userId = groupIdToUserId.get(gm.GroupId);
                    userId.add(gm.UserOrGroupId);
                    groupIdToUserId.put(gm.GroupId, userId);
                }else{
                    groupIdToUserId.put(gm.GroupId, new List<Id> {gm.UserOrGroupId});
                }
            }
        }
        // Create email template variables for each email template
        EmailTemplate dailyNotificationMembershipService = new EmailTemplate();
        EmailTemplate dailyNotificationAccounts = new EmailTemplate();
        EmailTemplate dailyNotificationNSF = new EmailTemplate();

        // iterate through the list of email templates and assign to the email template variables
        for(EmailTemplate et : emailTemplateList){
            if(et.DeveloperName == 'Daily_Notification_Member_Services'){
                dailyNotificationMembershipService = et;
            }else if(et.DeveloperName == 'Daily_Notification_Accounts'){
                dailyNotificationAccounts = et;
            }else if(et.DeveloperName == 'Daily_Notification_NSF'){
                dailyNotificationNSF = et;
            }
        }
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for(Group g : scope){
            if(g.DeveloperName == 'Membership_Services'){
                if(groupIdToUserId.containsKey(g.Id)){
                    System.debug('User Ids for Membership Services => ' + groupIdToUserId.get(g.Id));
                    for(Id userId : groupIdToUserId.get(g.Id)){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(userId);
                        message.setReplyTo('help@rspcaassured.org.uk');
                        message.setOrgWideEmailAddressId(owea.get(0).Id);
                        message.setUseSignature(false);
                        message.setBccSender(false);
                        message.setSaveAsActivity(false);
                        message.setTemplateID(dailyNotificationMembershipService.Id);
                        message.setWhatId(userId); //This is important for the merge fields in template to work

                        messages.add(message);
                    }
                }
            }
            if(g.DeveloperName == 'Accounts'){
                if(groupIdToUserId.containsKey(g.Id)){
                    System.debug('User Ids for Accounts => ' + groupIdToUserId.get(g.Id));
                    for(Id userId : groupIdToUserId.get(g.Id)){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(userId);
                        message.setReplyTo('help@rspcaassured.org.uk');
                        message.setOrgWideEmailAddressId(owea.get(0).Id);
                        message.setUseSignature(false);
                        message.setBccSender(false);
                        message.setSaveAsActivity(false);
                        message.setTemplateID(dailyNotificationAccounts.Id);
                        message.setWhatId(userId); //This is important for the merge fields in template to work

                        messages.add(message);
                    }
                }
            }
            if(g.DeveloperName == 'Certifiers'){
                if(groupIdToUserId.containsKey(g.Id)){
                    System.debug('User Ids for NSF => ' + groupIdToUserId.get(g.Id));
                    for(Id userId : groupIdToUserId.get(g.Id)){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(userId);
                        message.setReplyTo('help@rspcaassured.org.uk');
                        message.setOrgWideEmailAddressId(owea.get(0).Id);
                        message.setUseSignature(false);
                        message.setBccSender(false);
                        message.setSaveAsActivity(false);
                        message.setTemplateID(dailyNotificationNSF.Id);
                        message.setWhatId(userId); //This is important for the merge fields in template to work

                        messages.add(message);
                    }
                }
            }
        }
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        for(Messaging.SendEmailResult result : results){
            if (result.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
        }
        
        
    }

    global void finish(Database.BatchableContext BC) {
        
    }

    global void execute(SchedulableContext ctx) {
        Id batchInstanceId = Database.executeBatch(new DailyNotificationSchedule(), 3);
    }
}