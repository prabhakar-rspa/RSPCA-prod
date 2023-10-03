({
    getWoaDairyData : function(component, event, helper) {
        var action = component.get("c.getWOADairy");
        action.setParams({
            "recordId": component.get("v.woaSummaryRecord.Id"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.woaDairy", response.getReturnValue());
            }else{
                console.log('Problem getting WOA Dairy Cattle Data, response state: ' + state);
            }
            // set the selected values for improvementsMade
            if( component.get("v.woaDairy.ImprovementMade__c") != null ){
                var improvementsMadeSelected = component.get("v.woaDairy.ImprovementMade__c").split(';');
                component.set("v.improvementsMadeSelected", improvementsMadeSelected);
            }
             // set the selected values for improvementsPlanneed
             if( component.get("v.woaDairy.ImprovementPlanned__c") != null ){
                var improvementsPlannedSelected = component.get("v.woaDairy.ImprovementPlanned__c").split(';');
                component.set("v.improvementsPlannedSelected", improvementsPlannedSelected);
            }
        })
        $A.enqueueAction(action);
    }
})