({
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
            } else {
                console.log('Problem getting contact, response state: ' + state);
                //alert('No primary contact found for this site. Please ensure that there is a primary contact available for this site.');
                this.showMessage('error','Error!','No primary contact found for this site. Please ensure that there is a primary contact available for this site.');

                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    getPoultryUnits: function (component) {
        // Get the list of poultry units from the apex controller
        var action = component.get("c.getPoultryUnits");
        action.setParams({ "siteId": component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.poultryList", response.getReturnValue());
                console.log(response.getReturnValue().length);
                component.set("v.poultrySize", response.getReturnValue().length);
            } else {
                console.log('Problem getting poultry units, response state: ' + state);
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
            component.set('v.step4', false);

        } else if (cs == 2) {
            component.set('v.step1', false);
            // Active Step
            component.set('v.step2', true);
            component.set('v.step3', false);
            component.set('v.step4', false);

            var updateType = component.get('v.NewApplicationFields.Update_Type__c');

            if (updateType == 'New Unit') {
                component.set('v.newUnit', true);
                component.set('v.extension', false);
            } else if (updateType == 'Update to flock size') {
                component.set('v.newUnit', false);
                component.set('v.extension', true);
            }

        } else if (cs == 3) {
            component.set('v.step1', false);
            component.set('v.step2', false);
            // Active Step
            component.set('v.step3', true);
            component.set('v.step4', false);

        } else if (cs == 4) {
            component.set('v.step1', false);
            component.set('v.step2', false);
            component.set('v.step3', false);
            // Active Step
            component.set('v.step4', true);

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
            var multiValid = true;
            let multiFields = component.find('multiField');
            if(Array.isArray(multiFields)){
                multiFields.forEach(multiField=>{
                    if(!multiField.isValid()){
                        multiValid = false;
                    }
                });
            }else if(multiFields){
                multiValid = multiFields.isValid();
            }
            return allValid && multiValid;
        } else {
            return true;
        }
    },
    
    validateUnitList: function(component, event) {
        //Validate all account records
        var isValid = true;
        var unitList = component.get("v.unitList");
        for (var i = 0; i < unitList.length; i++) {
            if (unitList[i].Name == undefined) {
                isValid = false;
                //alert('Unit Number cannot be blank on row number ' + (i + 1));
                this.showMessage('error','Error!','Unit Number cannot be blank on row number ' + (i + 1));

            }
            if (unitList[i].Business__c == '') {
                isValid = false;
                //alert('Business value cannot be blank on row number ' + (i + 1));
                this.showMessage('error','Error!','Business value cannot be blank on row number ' + (i + 1));

            }
        }
        return isValid;
    },


    addUnitRecord: function(component, event) {
        //get the account List from component  
        var unitList = component.get("v.unitList");
        var unitNumber = unitList.length +1;
        var unitString = unitNumber.toString();

        unitList.length;
        //Add New Account Record
        unitList.push({
            'sobjectType': 'Unit__c',
            'Name': unitString.padStart(2,'0'),
            'Business__c': '',
            'Animals__c': '',
            'Production__c': ''
        });
        component.set("v.unitList", unitList);
    },

    createApplication: function(component, event, helper) {
        //Set loading screen
        component.set('v.isLoading', true);
        // call apex class to pass unit list parameters
        var action = component.get("c.createAppWithUnits");
        action.setParams({
            "app": component.get("v.NewApplicationFields") ,
            "units": component.get("v.unitList"),
            "assessmentRequired":component.get('v.assessmentRequired'),
            "createRevisitFee":component.get('v.assessmentNeeded')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //alert('Unit records saved successfully');
                this.showMessage('success','Success!','Unit records saved successfully');

                component.set('v.submitResponse', response.getReturnValue());
                component.set('v.currentStep', '4');
                component.set('v.step1', false);
                component.set('v.step2', false);
                component.set('v.step3', false);
                // Active Step
                component.set('v.step4', true);
                component.set('v.isLoading', false);
            } else {
                console.log('Problem saving units, response state: ' + state);
            }
        }); 
        $A.enqueueAction(action);
    },
    
    createApplicationExtension: function(component, event, helper) {
        //Set loading screen
        component.set('v.isLoading', true);
        // call apex class to pass unit list parameters
        var action = component.get("c.createAppWithUnits");
        action.setParams({
            "app": component.get("v.NewApplicationFields") ,
            "units": component.get("v.poultryList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                //alert('Unit records saved successfully');
                this.showMessage('success','Success!','Unit records saved successfully');
                component.set('v.submitResponse', response.getReturnValue());
                component.set('v.currentStep', '4');
                component.set('v.step1', false);
                component.set('v.step2', false);
                component.set('v.step3', false);
                // Active Step
                component.set('v.step4', true);
                component.set('v.isLoading', false);
            } else {
                console.log('Problem saving units, response state: ' + state);
            }
        }); 
        $A.enqueueAction(action);
    },
    showMessage : function(type,title,message){
        console.log('type::',type);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "title": title,
            "message": message,
            "mode": 'sticky'
        });
        toastEvent.fire();
    }
})