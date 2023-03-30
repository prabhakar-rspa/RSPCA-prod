public class AssessmentTriggerHandler extends TriggerHandler{
    public AssessmentTriggerHandler() {

    }

    public override void beforeUpdate(){
        NonComplianceCreation.createNonCompliance((List<Assessments__c>)Trigger.new);
    }
}