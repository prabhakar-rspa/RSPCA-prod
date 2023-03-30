trigger AppUnitTrigger on Application_Unit__c (
    before insert, 
	before update, 
	after insert, 
	after update) {
        
    // Before Insert
	if(Trigger.isInsert && Trigger.isBefore){
		AppUnitTriggerHandler.OnBeforeInsert(Trigger.new);
	}
	// After Insert
	if(Trigger.isInsert && Trigger.isAfter){
		AppUnitTriggerHandler.OnAfterInsert(Trigger.new);
	}

}