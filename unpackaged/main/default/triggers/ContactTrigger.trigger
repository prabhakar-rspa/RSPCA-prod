trigger ContactTrigger on Contact (
    before insert, 
	before update, 
	after insert, 
	after update) {
        
    // Before Insert
	if(Trigger.isInsert && Trigger.isBefore){
		ContactTriggerHandler.OnBeforeInsert(Trigger.new);
	}
	// After Insert
	if(Trigger.isInsert && Trigger.isAfter){
		ContactTriggerHandler.OnAfterInsert(Trigger.new);
	}
	// Before Update
	if(Trigger.isUpdate && Trigger.isBefore){
		ContactTriggerHandler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
	// After Update
	if(Trigger.isUpdate && Trigger.isAfter){
		ContactTriggerHandler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}

}