({
    getContactRecord: function (component) {
        // Get the contact record from the apex controller
        var action = component.get("c.fetchCustomerContact");
        action.setParams({ "accId": component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.primaryContact", response.getReturnValue());
                var fullname = component.get('v.primaryContact.FirstName') + ' ' + component.get('v.primaryContact.LastName');
                component.set('v.fullname', fullname);
                component.set('v.isLoading', false);
            } else {
                console.log('Problem getting contact, response state: ' + state);
                alert('No primary contact found for this site. Please ensure that there is a primary contact available for this site.');
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    getSiteRecords: function(component, event) {
        // call apex method for fetch child records list.
        var action = component.get('c.getSites');
        action.setParams({"accId": component.get("v.recordId")});
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS') {
                //set response value in ChildRecordList attribute on component.
                component.set('v.siteList', actionResult.getReturnValue());
                if (actionResult.getReturnValue().length == 0) {
                    component.set('v.emptyListSize', true);
                }
                console.log(actionResult.getReturnValue().length);
                console.log(component.get('v.emptyListSize'));
            }
        });
        $A.enqueueAction(action);
    },

    stepsHandler: function (component) {
        var cs = parseInt(component.get('v.currentStep'));

        if (cs == 1) {
            // Active Step
            component.set('v.step1', true);
            component.set('v.step2', false);
            component.set('v.step3', false);

        } else if (cs == 2) {
            component.set('v.step1', false);
            // Active Step
            component.set('v.step2', true);
            component.set('v.step3', false);

        } else if (cs == 3) {
            component.set('v.step1', false);
            component.set('v.step2', false);
            // Active Step
            component.set('v.step3', true);

        }
    },

    validateFields: function (component) {
        var fields = component.find('field');
        console.log('Fields found: ' + fields);
        if (fields != null) {
            var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            return allValid;
        } else {
            return true;
        }
    },
    renewSelectedHelper: function(component, event, siteIds) {
        //call apex class method
        var action = component.get('c.createBulkRenewal');

        action.setParams({
            "accId": component.get("v.recordId"),
            "agreement": component.get("v.agreement"),
            "noOffences": component.get("v.noOffences"),
            "payMethod": component.get("v.payMethod"),
            "lstOfSiteIds": siteIds,
            "poNumber": component.get("v.poNumber")
        });
        //component.set("v.isLoading", true);
 
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set('v.submitResponse', response.getReturnValue());
                component.set('v.step1', false);
                component.set('v.step2', true);
                component.set('v.currentStep', '2');
                
            } else {
                console.log('Problem renewing application: ' + state + ' - ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})