({
    doInit: function (component, event, helper) {
        helper.getSiteRecords(component, event);
        helper.getContactRecord(component);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.agreementDate', today);
    },

    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },

    selectAllSites: function(component, event, helper) {
        // get(find) all checkboxes with aura:id "checkBox"
        var getAllId = component.find('checkBox');
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

    deselectAllSites: function(component, event, helper) {
        // get(find) all checkboxes with aura:id "checkBox"
        var getAllId = component.find('checkBox');
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

    handleSubmit: function (component, event, helper) {
        var allValid = helper.validateFields(component);
        console.log(allValid);
        
        if (allValid) {
            component.set('v.hasError', false);
            console.log('All form entries look valid. Ready to submit!');
            
            // create array[list] type temp. variable for store child record's id's from selected checkboxes.  
        	var tempIDs = [];
 
        	// get(find) all checkboxes with aura:id "checkBox"
            var getAllId = component.find('checkBox');
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
 
        	// call the helper function and pass all selected record id's.   
        	helper.renewSelectedHelper(component, event, tempIDs);

        } else {
            alert('Please update the invalid form entries and try again.');
            component.set('v.hasError', true);
        }
        
        
    },
    

    handleCancel: function () {
        $A.get("e.force:closeQuickAction").fire();
    },

    goToBulkRenewal: function(component){
        
        var payMethod = component.get('v.payMethod');
        var navEvt = $A.get("e.force:navigateToSObject");
        if(payMethod == 'Card'){
            navEvt.setParams({
                "recordId": component.get("v.submitResponse.Bulk_Renewal__c"),
                "slideDevName": "detail"
            });
            
        }else{
            navEvt.setParams({
                "recordId": component.get("v.submitResponse.Id"),
                "slideDevName": "detail"
            });
            
        }
        
        navEvt.fire();
        
    }
})