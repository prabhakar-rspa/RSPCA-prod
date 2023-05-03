({
    doInit: function (component, event, helper) {
        helper.getContactRecord(component);
        // Prepare a new record from template
        component.find("applicationRecordCreate").getNewRecord(
            "Application__c", // sObject type (objectApiName)
            "$Label.c.Application_Record_Type_Id",      // recordTypeId 
            false,     // skip cache?
            $A.getCallback(function () {
                var rec = component.get("v.newApplication");
                var error = component.get("v.newApplicationError");
                // Set the application header fields
                component.set('v.NewApplicationFields.Existing_Member__c', 'Yes');
                component.set('v.NewApplicationFields.Renewal_Stage__c', 'Renewal');
                component.set('v.NewApplicationFields.Application_Type__c', 'Transfer');
                if(component.get('v.primaryContact') != null){
                    component.set('v.NewApplicationFields.Signatory_Contact__c', component.get('v.primaryContact.Id'));
                    component.set('v.NewApplicationFields.Applicant_Contact__c', component.get('v.primaryContact.Id'));
                }
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                component.set('v.NewApplicationFields.Agreement_Date__c', today);
                
                if (error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }else{
                    console.log("Record template initialized: " + rec.apiName);
                }
                
            })
        );
    },

    handleNext: function (component, event, helper) {
        var allValid = helper.validateFields(component);
        console.log(allValid);
        if(component.get('v.transferType') == 'Group' && component.get('v.accountSelected') == false){
            allValid = false;
        }
        if (allValid) {
            component.set('v.hasError', false);
            console.log('All form entries look valid. Ready to submit!');
            var cs = parseInt(component.get('v.currentStep'));
            if (cs < 4) {
                cs = cs + 1;
                component.set('v.currentStep', cs.toString());
            }
            helper.stepsHandler(component, event);
        } else {
            alert('Please update the invalid form entries and try again.');
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

    handleSubmit: function(component, event, helper){
        var allValid = helper.validateFields(component);
        console.log(allValid);
        if (allValid) {
            component.set('v.hasError', false);
            console.log('All form entries look valid. Ready to submit!');
            
            // Do something
            helper.createTransferApplication(component);
            
        } else {
            alert('Please update the invalid form entries and try again.');
            component.set('v.hasError', true);
        }
    },

    handleCancel: function () {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleKeyUp: function (cmp, evt, helper) {
        var isEnterKey = evt.keyCode === 13;
        console.log('KeyCode ==> ' + evt.keyCode);
        console.log('Event code ==> ' + evt.code);

        var queryTerm = cmp.find('membership-search').get('v.value');
        if (isEnterKey) {
            cmp.set('v.isSearching', true);
            cmp.set('v.transferToObject', null);
            cmp.set('v.accountSelected', false);
            if(queryTerm !== ''){
                setTimeout(function() {
                    if(cmp.get('v.transferType') == 'Group'){
                        console.log('Query Term ==> ' +  queryTerm);
                        helper.getHeadOffice(cmp, queryTerm);
                        if(cmp.get('v.transferToObject') !== undefined){
                            cmp.set('v.isSearching', false);
                        }
                         
                    }else{
                    }
                }, 2000);

            } else {
                alert('Please enter a membership number.');
                cmp.set('v.isSearching', false);
            }
            
        }
    },
    goToApplication: function(component){
        
        var payMethod = component.get('v.NewApplicationFields.Payment_Method__c');
        var navEvt = $A.get("e.force:navigateToSObject");
        if(payMethod == 'Card'){
            navEvt.setParams({
                "recordId": component.get("v.submitResponse.Application__c"),
                "slideDevName": "detail"
            });
            
        }else{
            navEvt.setParams({
                "recordId": component.get("v.submitResponse.Id"),
                "slideDevName": "detail"
            });
            
        }
        
        navEvt.fire();
        
    },
    goToApplication2: function(component){
        
        var payMethod = component.get('v.NewApplicationFields.Payment_Method__c');
        var navEvt = $A.get("e.force:navigateToSObject");
        if(payMethod == 'Card'){
            navEvt.setParams({
                "recordId": component.get("v.submitResponse.Application__c"),
                "slideDevName": "detail"
            });
            
        }else{
            navEvt.setParams({
                "recordId": component.get("v.submitResponse.Id"),
                "slideDevName": "detail"
            });
            
        }
        
        navEvt.fire();
        
    },
})