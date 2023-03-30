trigger ApplicationTrigger on Application__c (
    before insert, 
    before update,  
    after insert, 
    after update) {
    
  new ApplicationTriggerHandler().run();

}