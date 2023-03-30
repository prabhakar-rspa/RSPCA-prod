trigger AssessmentTrigger on Assessments__c (
    before insert, 
    before update,  
    after insert, 
    after update) {

    new AssessmentTriggerHandler().run();

}