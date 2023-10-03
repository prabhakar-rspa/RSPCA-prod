({
	doInit : function(component, event, helper) {
		// do something
		var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	component.set('v.today', today);
		helper.getApplication(component);
		//helper.getAppLineItems(component);
	},

	handleNext: function (component, event, helper) {
		var errorMessage = "Please update the invalid form entries and try again.";
        var allValid = helper.validateFields(component);
		// Check if any line items are selected in step 1
		if(parseInt(component.get('v.currentStep')) == 1){
			// create array[list] type temp. variable for store app line item ids that are selected
        	var tempIDs = [];
 
        	// get(find) all checkboxes with aura:id "checkBox"
            var getAllId = component.find('lineItemCheckbox');
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
            console.log(tempIDs.length);

			if(tempIDs.length > 0){
				helper.getCreditLines(component, tempIDs);
			}else{
				allValid = false;
				errorMessage = "Please select line items to credit.";
			}
		}
        console.log(allValid);
        if (allValid) {
            component.set('v.hasError', false);
            console.log('All form entries look valid. Ready to submit!');
            var cs = parseInt(component.get('v.currentStep'));
            if (cs < 3) {
                cs = cs + 1;
                component.set('v.currentStep', cs.toString());
            }
            helper.stepsHandler(component, event);
        } else {
            alert(errorMessage);
            component.set('v.hasError', true);
        }
        
    },

	handlePrevious: function (component, event, helper) {
        var cs = parseInt(component.get('v.currentStep'));
        if (cs > 1) {
            cs = cs - 1;
            component.set('v.currentStep', cs.toString());
        }
        helper.stepsHandler(component, event);
    },

	handleExit : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},

	handleSave : function(component, event, helper){
		var allValid = helper.validateFields(component);
        console.log(allValid);
        
        if (allValid) {
            component.set('v.hasError', false);
            console.log('All form entries look valid. Ready to submit!');
			
			component.set("v.isLoading", true);
        	// call the helper function and pass all selected record id's.   
        	helper.createCreditNote(component);

        } else {
            alert('Please update the invalid form entries and try again.');
            component.set('v.hasError', true);
        }
	},

	handleSelectAll: function(component, event, helper){
		var selectAll = component.find("selectAllCheckbox").get("v.value");
		if(selectAll){
			helper.selectAllSites(component);
		}else{
			helper.deselectAllSites(component);
		}
	}
})