({
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

    getContactRecord: function (component) {
        // Get the contact record from the apex controller
        var action = component.get("c.fetchCustomerContact");
        action.setParams({ "siteId": component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.primaryContact", response.getReturnValue());
                var fullname = component.get('v.primaryContact.FirstName') + ' ' + component.get('v.primaryContact.LastName');
                component.set('v.fullname', fullname);
                component.set('v.NewApplicationFields.Applicant_Contact__c', component.get('v.primaryContact.Id'));
                component.set('v.NewApplicationFields.Signatory_Contact__c', component.get('v.primaryContact.Id'));
                component.set('v.isLoading', false);
                console.log('isLoading ==> ' + component.get('v.isLoading'));
            } else {
                console.log('Problem getting contact, response state: ' + state);
                alert('No primary contact found for this site. Please ensure that there is a primary contact available for this site.');
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    getHeadOffice: function (component, headOfficeNumber) {
        console.log('Record Id ==> '+ component.get('v.recordId'));
        console.log('Membership Number ==> '+ headOfficeNumber);
        var action = component.get("c.getHeadOffice");
        action.setParams({ 
            "accId": component.get("v.transferFromId"),
            "headOfficeNumber": headOfficeNumber
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.transferToObject', response.getReturnValue());
                
            } else {
                console.log('Problem getting contact, response state: ' + state);
                alert('No account found.');
            }
        });
        $A.enqueueAction(action);

    },
    createTransferApplication: function(component, event, helper) {
        //Set loading screen
        component.set('v.isLoading', true);
        var action = component.get("c.createTransferApplication");
        action.setParams({
            "app": component.get("v.NewApplicationFields") ,
            "transferType": component.get("v.transferType"),
            "transferToAccount": component.get('v.transferToObject'),
            "oldSite": component.get('v.siteFields')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                alert('Transfer application submitted successfully');
                component.set('v.submitResponse', response.getReturnValue());
                component.set('v.currentStep', '3');
                component.set('v.step1', false);
                component.set('v.step2', false);
                // Active Step
                component.set('v.step3', true);
                component.set('v.isLoading', false);
            } else {
                console.log('Problem saving units, response state: ' + state);
            }
        }); 
        $A.enqueueAction(action);
    }
})