({
	getChecklistTemplates : function(component) {
        var action = component.get('c.getChecklistTemplates');
        action.setParams({
            "appId": component.get("v.recordId")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS') {
                var checklistTemplates = actionResult.getReturnValue();
                checklistTemplates.forEach(checklistTemplate=>{
                    if(checklistTemplate.Animals_List__c){
                   		 checklistTemplate.animals = checklistTemplate.Animals_List__c;
                	}else{
                   		 checklistTemplate.animals = checklistTemplate.Species__c;
                    }
                });
                console.log('checklistTemplates::::',checklistTemplates);
                component.set('v.checklistTemplates',checklistTemplates);
            }else {
                console.log('Problem getting records: ' + state + ' - ' + actionResult.getError());
                let errors = response.getError();
                var errormessage = 'Problem getting records: ' + state + ' - ' + errors && errors[0]? errors[0].message:errors;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": errormessage
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	},
    checkSelectedChecklist: function(component, event, checklistIds) {
        component.set('v.isLoading',true);
        console.log(checklistIds);
        //call apex class method
        var action = component.get('c.checkPreviousAssessmentChecklist');
 
        action.setParams({
            "appId": component.get("v.recordId"),
            "checklistIds": checklistIds,
        });
 
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('response::::',response.getReturnValue());
                let result = response.getReturnValue();
                if(result.status === 'success'){
        			this.createSelectedChecklist(component, event, checklistIds,result.AssessmentChecklistDetails);
                }else{
                    component.set('v.assessmentChecklistDetails',result.AssessmentChecklistDetails);
                    component.set('v.showOtherAssessments',true);
                    component.set('v.isLoading',false);
                    //show modal
                }
            } else {
                let errors = response.getError();
                console.log('Problem creating records: ' + state + ' - ' ,response.getError());
                var errormessage = 'Problem getting records: ' + state + ' - ' + errors && errors[0]? errors[0].message:errors;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": errormessage
                });
                toastEvent.fire();
                component.set('v.isLoading',false);
            }
        });
        $A.enqueueAction(action);
    },
    createSelectedChecklist: function(component, event, checklistIds,assessmentChecklistDetails) {
        console.log(checklistIds);
        component.set('v.isLoading',true);
        //call apex class method
        var action = component.get('c.createAssessmentChecklist');
        console.log(JSON.stringify(assessmentChecklistDetails));
        action.setParams({
            "appId": component.get("v.recordId"),
            "checklistIds": checklistIds,
            "assessmentChecklistDetailStr":JSON.stringify(assessmentChecklistDetails)
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
                let errors = response.getError();
                console.log('Problem creating records: ' + state + ' - ' ,response.getError());
                var errormessage = 'Problem getting records: ' + state + ' - ' + errors && errors[0]? errors[0].message:errors;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": errormessage
                });
                toastEvent.fire();
            }
            component.set('v.isLoading',false);
        });
        $A.enqueueAction(action);
    },
})