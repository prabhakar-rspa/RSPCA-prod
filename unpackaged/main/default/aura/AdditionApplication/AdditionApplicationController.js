({
    doInit: function (component, event, helper) {
        helper.getContactRecord(component);
        
        helper.getPoultryUnits(component);
        
        // Prepare a new record from template
        component.find("applicationRecordCreate").getNewRecord(
            "Application__c", // sObject type (objectApiName)
            "$Label.c.Application_Record_Type_Id",      // recordTypeId 
            false,     // skip cache?
            $A.getCallback(function () {
                var rec = component.get("v.newApplication");
                var error = component.get("v.newApplicationError");
                component.set('v.NewApplicationFields.Existing_Member__c', 'Yes');
                component.set('v.NewApplicationFields.Stage__c', 'Application');
                component.set('v.NewApplicationFields.Application_Type__c', 'Update');
                component.set('v.NewApplicationFields.Site__c', component.get('v.recordId'));
                var headOfficeId = component.get("v.siteFields.ParentId");
                if(headOfficeId != null){
                    component.set('v.NewApplicationFields.Head_Office__c', headOfficeId);
                }
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
    
    addUnit: function(component, event, helper) {
        helper.addUnitRecord(component, event);
    },
    
    removeRow: function(component, event, helper) {
        //Get the account list
        var unitList = component.get("v.unitList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        unitList.splice(index, 1);
        component.set("v.unitList", unitList);
    },
    
    handleNext: function (component, event, helper) {
        var allValid = helper.validateFields(component);
        console.log(allValid);
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
            //alert('Please update the invalid form entries and try again.');
            helper.showMessage('error','Error!','Please update the invalid form entries and try again.');
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
    
    handleSubmit: function (component, event, helper) {
        
        var allValid = helper.validateFields(component);
        console.log(allValid);
        if (allValid) {
            component.set('v.hasError', false);
            console.log('All form entries look valid. Ready to submit!');
            var appType = component.get('v.NewApplicationFields.Update_Type__c');
            
            if(appType == 'Update to flock size'){
                helper.createApplicationExtension(component);
            }else if(appType == 'New Unit'){
                helper.createApplication(component);
            }
            
        } else {
            //alert('Please update the invalid form entries and try again.');
            helper.showMessage('error','Error!','Please update the invalid form entries and try again.');
            component.set('v.hasError', true);
        }
        
    },
    
    handleCancel: function () {
        $A.get("e.force:closeQuickAction").fire();
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
    handleBussinessChange: function(component,event,helper){
        let bussiness = event.getSource().get('v.value');
        console.log('bussiness:::'+bussiness);
        console.log('event::::',event);
        let name = event.getSource().get('v.name');
        
        /*if(bussiness != 'Abattoir' && bussiness != 'Catching' && bussiness != 'Hatchery' && bussiness != 'Haulier'){
            name = name.replace('bussiness','');
            let unitList = component.get('v.unitList');
            unitList[name]['Animals_List__c'] ='';
            component.set('v.unitList',unitList);
            console.log('value::',unitList[index]);
        }*/
        if(bussiness && name){
            name = name.replace('business','');
            console.log('name:::'+name);
            let unitList = component.get('v.unitList');
            console.log('value::',unitList[name]);
            unitList[name]['Animals_List__c'] = '';
            if(bussiness == 'Abattoir' || bussiness == 'Catching' || bussiness == 'Hatchery' || bussiness == 'Haulier'){
                unitList[name]['Animals__c'] = 'List';
            }else{
                unitList[name]['Animals__c'] = '';
            }
            component.set('v.unitList',unitList);
        }
    },
    handleAnimalSelection :  function(component,event,helper){
        
        let params = event.getParams();
        let unitList = component.get('v.unitList');
        if(params.index >=0 && params.fieldName){
            unitList[params.index][params.fieldName] = params.selectedoptions.join(';');
            component.set('v.unitList',unitList);
        }
        
        
    }
})