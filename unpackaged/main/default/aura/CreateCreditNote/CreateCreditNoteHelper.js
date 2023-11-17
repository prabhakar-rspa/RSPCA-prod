({
	getApplication : function(component) {
        var action = component.get("c.getApplication");
		action.setParams({ 
            "recordId": component.get("v.recordId")
		 });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // store the response return value
                var result = response.getReturnValue();

                component.set("v.application", result);
                console.log('result::',result);
                if(result.Sage_Invoice__c){
                    this.getInvoice(component);
                	this.getInvoiceLineItems(component);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message":"Invoice not available",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            } else {
                console.log('Problem getting records, response state: ' , state);
                var message = response.getError()[0].message;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message":message,
                    "type": "error"
                });
                toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
	},

    getInvoice : function(component) {
        var action = component.get("c.getInvoice");
		action.setParams({ 
            "recordId": component.get("v.application.Sage_Invoice__c")
		 });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // store the response return value
                var result = response.getReturnValue();

                component.set("v.invoice", result);
                component.set("v.headOfficeBillingCountry", result.Account.BillingCountry);

            } else {
                console.log('Problem getting records, response state: ' , state);
                var message = response.getError()[0].message;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message":message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    getInvoiceLineItems : function(component){
        var action = component.get("c.getInvoiceLineItems");
		action.setParams({ 
            "recordId": component.get("v.application.Sage_Invoice__c")
		 });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // store the response return value
                var result = response.getReturnValue();
                console.log(result);
                if(result.length > 0){
                    component.set("v.lineItemsExist", true);
                    component.set("v.invoiceLineItems", result);
                    component.set("v.isLoading", false);
                }
                

            } else {
                console.log('Problem getting records, response state: ' , state);
                var message = response.getError()[0].message;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message":message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    getCreditLines : function(component, oppLineIds) {
        var action = component.get("c.getCreditLines");
		action.setParams({ 
            "oppLineIds": oppLineIds
		 });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // store the response return value
                var result = response.getReturnValue();
                console.log("credit lines => " + result);
                component.set("v.creditNoteLines", result);
                

            } else {
                console.log('Problem getting records, response state: ' , state);
                var message = response.getError()[0].message;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message":message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
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

    selectAllSites: function(component) {
        // get(find) all checkboxes with aura:id "checkBox"
        var getAllId = component.find('lineItemCheckbox');
        var chk = (getAllId.length == null) ? [getAllId] : getAllId;
        console.log('chk array ==> ' + chk.length);

        // iterate through the array of checkboxes and set the value to true
        for (var i = 0; i < chk.length; i++) {
            console.log(chk[i].get("v.value"));
            console.log(chk[i].get("v.text"));
            if (chk[i].get("v.value") == false) {
                chk[i].set("v.value", true);
            }
        }

    },

    deselectAllSites: function(component) {
        // get(find) all checkboxes with aura:id "checkBox"
        var getAllId = component.find('lineItemCheckbox');
        var chk = (getAllId.length == null) ? [getAllId] : getAllId;
        console.log('chk array ==> ' + chk.length);

        // iterate through the array of checkboxes and set the value to false
        for (var i = 0; i < chk.length; i++) {
            console.log(chk[i].get("v.value"));
            console.log(chk[i].get("v.text"));
            if (chk[i].get("v.value") == true) {
                chk[i].set("v.value", false);
            }
        }

    },

    createCreditNote : function(component) {
        var action = component.get("c.createCreditNote");
		action.setParams({ 
            "application": component.get("v.application"),
            "creditNoteLinesWrapper": component.get("v.creditNoteLines"),
            "creditNoteReason": component.get("v.creditReason"),
            "purchaseOrder": component.get("v.purchaseOrder"),
            "creditNoteDetails": component.get("v.creditNoteDetails")
		 });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // store the response return value
                var result = response.getReturnValue();
                console.log(result);
                
                component.set("v.creditNote", result);

                component.set('v.step2', false);
                component.set('v.step3', true);
                component.set('v.currentStep', '3');

                component.set("v.isLoading", false);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Credit note created successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                
                

            } else {
                console.log('Problem getting records, response state: ' , state);
                var message = response.getError()[0].message;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message":message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})