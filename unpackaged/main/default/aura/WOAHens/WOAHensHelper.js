({
    getWoaHensData : function(component, event, helper) {
        var action = component.get("c.getWOAHens");
        action.setParams({
            "recordId": component.get("v.woaSummaryRecord.Id"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.woaLayingHen", response.getReturnValue());
                // set the selected values for enrichment
                if( component.get("v.woaLayingHen.Enrichment__c") != null ){
                    var enrichmentSelectedValues = component.get("v.woaLayingHen.Enrichment__c").split(';');
                    component.set("v.enrichmentSelectedValues", enrichmentSelectedValues);
                }
                // set the selected values for improvements made
                if( component.get("v.woaLayingHen.ImprovementMadeLast12Months__c") != null ){
                    var improvementMadeSelectedValues = component.get("v.woaLayingHen.ImprovementMadeLast12Months__c").split(';');
                    component.set("v.improvementMadeSelectedValues", improvementMadeSelectedValues);
                }
                // set the selected values for improvements planned
                if( component.get("v.woaLayingHen.ImprovementPlannedNext12Months__c") != null ){
                    var improvementPlannedSelectedValues = component.get("v.woaLayingHen.ImprovementPlannedNext12Months__c").split(';');
                    component.set("v.improvementPlannedSelectedValues", improvementPlannedSelectedValues);
                }
                let value = component.get('v.woaLayingHen.Flock_Size__c') || 0;
                component.set('v.flockSizeValue',value);
            }else{
                console.log('Problem getting WOA Laying Hens Data, response state: ' + state);
            }
            
        })
        $A.enqueueAction(action);
    },
    validateHeadNeckFeatherLoss : function(component, event, helper) {
        var hnfl0 = component.get("v.woaLayingHen.Head_Neck_feather_loss_Score_0__c");
        var hnfl1 = component.get("v.woaLayingHen.Head_Neck_feather_loss_Score_1__c");
        var hnfl2 = component.get("v.woaLayingHen.Head_Neck_feather_loss_Score_2__c");
        var total = Number(hnfl0) + Number(hnfl1) + Number(hnfl2);
        console.log('total ' +total);
        if(total != 50 && component.get("v.woaCompleteToggle")){
            alert("Head & Neck feather loss score must total 50");
            return false;
        }else{
            return true;
        }
    },
    validateBackVentFeatherLoss : function(component, event, helper) {
        var bvfl0 = component.get("v.woaLayingHen.Back_Vent_feather_loss_Score_0__c");
        var bvfl1 = component.get("v.woaLayingHen.Back_Vent_feather_loss_Score_1__c");
        var bvfl2 = component.get("v.woaLayingHen.Back_Vent_feather_loss_Score_2__c");
        var total = Number(bvfl0) + Number(bvfl1) + Number(bvfl2);
        if(total != 50 && component.get("v.woaCompleteToggle")){ 
            alert("Back & Vent feather loss score must total 50");
            return false;
        }else{
            return true;
        }
    },
    validateDirtiness : function(component, event, helper) {
        var dirt0 = component.get("v.woaLayingHen.Dirtiness_Score_0__c");
        var dirt1 = component.get("v.woaLayingHen.Dirtiness_Score_1__c");
        var dirt2 = component.get("v.woaLayingHen.Dirtiness_Score_2__c");
        var total = Number(dirt0) + Number(dirt1) + Number(dirt2);
        if(total != 50 && component.get("v.woaCompleteToggle")){
            alert("Dirtiness score must total 50");
            return false; 
        }else{
            return true;
        }
    }
})