trigger UserTrigger on User (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        for(User usr : Trigger.new){
            Profile communityHdOfcRecTypId = [SELECT Id FROM Profile WHERE Name='RSPCA Assured Community User Head Office'];
            Profile communityUsrRecTypId = [SELECT Id FROM Profile WHERE Name='RSPCA Assured Community User Site'];
            if(usr.ProfileId == communityHdOfcRecTypId.Id || usr.ProfileId == communityUsrRecTypId.Id){
                //UserTriggerHandler.sendCommunityInvitationEmail(usr);
            }
        }
    }
}