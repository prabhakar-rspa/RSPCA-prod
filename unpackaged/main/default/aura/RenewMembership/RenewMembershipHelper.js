({
    getUnitRecords: function(component, event) {
        // call apex method for fetch child records list.
        var action = component.get('c.getUnits');
        action.setParams({"accId": component.get("v.recordId")});
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS') {
                //set response value in ChildRecordList attribute on component.
                component.set('v.UnitRecords', actionResult.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
 
    addSelectedHelper: function(component, event, childRecordsIds) {
        console.log(childRecordsIds);
        //call apex class method
        var action = component.get('c.createRenewalApplication');
 
        // Pass the all selected child record's Id's and
        // Parent Record id (ID of the currently displaying record[context record]) to apex method. 
        // ### You don’t need to add a recordId attribute to a component yourself.
        // It's automatic created with implements force:hasRecordId interface.###
        action.setParams({
            "accId": component.get("v.recordId"),
            "agreement": component.get("v.agreement"),
            "noOffences": component.get("v.noOffences"),
            "payMethod": component.get("v.selectedValue"),
            "lstOfUnitIds": childRecordsIds,
        });
        component.set("v.isLoading", true);
 
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Renewal Application successfully created."
                });
                toastEvent.fire();
                var navService = component.find("navService");
                var pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId":  response.getReturnValue(),
                        "objectApiName": "Application__c",
                        "actionName": "view"
                    },
                    "state": {}
                };
                navService.navigate(pageReference);
            } else {
                console.log('Problem renewing application: ' + state + ' - ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})