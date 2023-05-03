({
    doInit : function(component, event, helper) {
        helper.getUnitRecords(component, event);
        var opts = [
            { value: "", label: "Please select..." },
            { value: "BACS", label: "BACS" }
        ];
        component.set("v.options", opts);

        var today = new Date();
        component.set('v.today', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());

        var contactAction = component.get("c.getContactName");
        contactAction.setParams({"accId": component.get("v.recordId")});
        contactAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.contactName", response.getReturnValue());
            } else {
                console.log('Problem getting application, response state: ' + state);
            }
        });
        $A.enqueueAction(contactAction);
    },
    
    
    handleRenew: function(component, event, helper) {
        
        var allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) {
            // create array[list] type temp. variable for store child record's id's from selected checkboxes.  
        	var tempIDs = [];
 
        	// get(find) all checkboxes with aura:id "checkBox"
            var getAllId = component.find("checkBox");
            var chk = (getAllId.length == null) ? [getAllId] : getAllId;
            console.log('chk array ==> ' + chk.length);
 
        	// play a for loop and check every checkbox values 
        	// if value is checked(true) then add those Id (store in Text attribute on checkbox) in tempIDs var.
            for (var i = 0; i < chk.length; i++) {
                console.log(chk[i].get("v.value"));
                console.log(chk[i].get("v.text"));
       			if (chk[i].get("v.value") == true) {
                	tempIDs.push(chk[i].get("v.text"));
            	}
        	}
 
        	// call the helper function and pass all selected record id's.   
        	helper.addSelectedHelper(component, event, tempIDs);

        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Validation",
                "type": "error",
                "message": "Please complete the required fields and try again"
            });
        }
    },
    
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})