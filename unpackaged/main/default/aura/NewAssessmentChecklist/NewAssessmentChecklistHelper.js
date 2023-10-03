({
	getChecklistTemplates : function(component) {
        var action = component.get('c.getChecklistTemplates');
        action.setParams({
            "appId": component.get("v.recordId")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS') {
                component.set('v.checklistTemplates', actionResult.getReturnValue());
            }else {
                console.log('Problem getting records: ' + state + ' - ' + response.getError());
            }
        });
        $A.enqueueAction(action);
	},
    createSelectedChecklist: function(component, event, checklistIds) {
        console.log(checklistIds);
        //call apex class method
        var action = component.get('c.createAssessmentChecklist');
 
        action.setParams({
            "appId": component.get("v.recordId"),
            "checklistIds": checklistIds,
        });
 
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Assessment Checklist Records Created."
                });
                toastEvent.fire();
                
                $A.get("e.force:closeQuickAction").fire();
                
            } else {
                console.log('Problem creating records: ' + state + ' - ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})