({
    doInit : function(component, event, helper) {
        helper.getWoaHensData(component);
        component.set("v.woaCompleteToggle", component.get("v.woaSummaryRecord.IsCompleted__c"));
    },
    saveLayingHens : function(component, event, helper) {
        var action = component.get("c.saveWOAHens");
        action.setParams({
            "woaHen": component.get("v.woaLayingHen"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("WOA Hens Saved");
            }else{
                console.log('Problem saving WOA Laying Hens Data, response state: ' + state);
            }
            
        })
        $A.enqueueAction(action);
    },
    handleEnrichmentChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaLayingHen.Enrichment__c", selectedValues.join(";"));
    },
    handleImprovementsMadeChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaLayingHen.ImprovementMadeLast12Months__c", selectedValues.join(";"));
    },
    handleImprovementsPlannedChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaLayingHen.ImprovementPlannedNext12Months__c", selectedValues.join(";"));
    },
    additionalValidations : function(component, event, helper) {
        var valid1 = helper.validateHeadNeckFeatherLoss(component);
        var valid2 = helper.validateBackVentFeatherLoss(component);
        var valid3 = helper.validateDirtiness(component);
        if(valid1 && valid2 && valid3){
            return true;
        }else{
            return false;
        }
    },
    handleFlockSizeChange : function(component, event, helper){
        let value = component.get('v.woaLayingHen.Flock_Size__c') || 0;
        component.set('v.flockSizeValue',value);
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            if(inputCmp.get('v.name') == 'totalBirdsOnFarm'){
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }
        }, true);
    }
})