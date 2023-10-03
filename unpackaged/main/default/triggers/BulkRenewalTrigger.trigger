trigger BulkRenewalTrigger on Bulk_Renewal__c (after update) {
    /*if(Trigger.isAfter && Trigger.isUpdate){
        BulkRenewalTriggerHandler.OnAfterUpdate(Trigger.new);
    }*/
    new BulkRenewalTriggerHandler().run();
}