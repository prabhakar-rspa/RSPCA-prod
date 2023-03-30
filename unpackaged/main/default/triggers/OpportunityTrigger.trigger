trigger OpportunityTrigger on Opportunity (before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        OpportunityTriggerHandler.onBeforeInsert(Trigger.new);
    }
}