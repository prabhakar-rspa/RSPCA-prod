({
    doInit : function(component, event, helper) {
        helper.getWoaPigsData(component);
        component.set("v.woaCompleteToggle", component.get("v.woaSummaryRecord.IsCompleted__c"));
    },
    savePigs : function(component, event, helper) {
        var action = component.get("c.saveWOAPigs");
        action.setParams({
            "woaPigs": component.get("v.woaPigs"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("WOA Pigs Saved");
            }else{
                console.log('Problem saving WOA Pigs Data, response state: ' + state);
            }
            
        })
        $A.enqueueAction(action);
    },
    handleBreedingRearingFinishingChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaPigs.Breeding_Rearing_Finishing__c", selectedValues.join(";"));
    },
    handleFurtherCareReasonsChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaPigs.Reason_for_further_care__c", selectedValues.join(";"));
    },
    handlePredominantBodyRegionsBodyMarkChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaPigs.Predominant_body_region_s_of_body_marks__c", selectedValues.join(";"));
    },
    handleImprovementsMadeChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaPigs.Improvements_made_in_last_12_month__c", selectedValues.join(";"));
    },
    handleImprovementsPlannedChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaPigs.Improvements_planned_for_next_12_months__c", selectedValues.join(";"));
    },
    handlePenDesignDrySowsChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaPigs.Pen_design_dry_sows__c", selectedValues.join(";"));
    },
    handlePenDesignFinishingChange : function(component, event, helper){
        var selectedValues = event.getParam("value");
        component.set("v.woaPigs.Pen_design_finishing_pigs__c", selectedValues.join(";"));
    },
    handleNumberOfPigChange : function(component, event, helper){
        let value = component.get('v.woaPigs.Number_of_pigs_assessed_in_pens_1_5__c');
    },
    validateFields : function(component, event, helper){
        let failedCount = 0;
        let woaPigs = component.get('v.woaPigs');
        let totalValue = parseInt(woaPigs.Number_of_pigs_assessed_in_pens_1_5__c);
        console.log('totalValue:::',totalValue);
        let bodyMarksCount = (
            parseInt(woaPigs.Number_of_body_marks_Score_0__c) + 
            parseInt(woaPigs.Number_of_body_marks_Score_1__c)+ 
            parseInt(woaPigs.Number_of_body_marks_Score_2__c)+
            parseInt(woaPigs.Too_dirty_to_assess_body_mark__c)
        );
        console.log('bodyMarksCount:::',bodyMarksCount);
        if(bodyMarksCount != totalValue){
            failedCount ++;
            component.set('v.bodyMarksError','Total number of this section should match Number of pigs assessed in pens 1 - 5 value');
        }else{
            component.set('v.bodyMarksError',"");
        }
        
        let manureCount = (
            parseInt(woaPigs.Number_with_manure_Score_0__c) +
             parseInt(woaPigs.Number_with_manure_Score_1__c)+
             parseInt(woaPigs.Number_with_manure_Score_2__c)+
             parseInt(woaPigs.Too_dirty_to_assess_Manure__c)
        );
        console.log('manureCount:::',manureCount);
        if(manureCount != totalValue){
            failedCount ++;
            component.set('v.manureError','Total number of this section should match Number of pigs assessed in pens 1 - 5 value');
        }else{
            component.set('v.manureError',"");
        }
        let legSwellingCount = (
            parseInt(woaPigs.Number_with_leg_swelling_Score_0__c) + 
            parseInt(woaPigs.Number_with_leg_swelling_Score_1__c)+
            parseInt(woaPigs.Number_with_leg_swelling_Score_2__c)
        );
        console.log('legSwellingCount:::',legSwellingCount);
        if(legSwellingCount != totalValue){
            failedCount ++;
            component.set('v.legSwellingError','Total number of this section should match Number of pigs assessed in pens 1 - 5 value');
        }else{
            component.set('v.legSwellingError',"");
        }
        let skinConditionCount = (
            parseInt(woaPigs.Number_with_skin_condition_Score_0__c) +
            parseInt( woaPigs.Number_with_skin_condition_Score_1__c)+
            parseInt(woaPigs.Number_with_skin_condition_Score_2__c)+
            parseInt(woaPigs.Too_dirty_to_assess_skin_condition__c)
        );
        console.log('skinConditionCount:::',skinConditionCount);
        if(skinConditionCount != totalValue){
            failedCount ++;
            component.set('v.skinConditionError','Total number of this section should match Number of pigs assessed in pens 1 - 5 value');
        }else{
            component.set('v.skinConditionError',"");
        }
        if(woaPigs.Dry_sows_or_Finishing_pigs__c == 'Dry sows'){
            let shoulderLesionsCount = (
                parseInt(woaPigs.Number_with_shoulder_lesions_Score_0__c) +
                parseInt( woaPigs.Number_with_shoulder_lesions_Score_1__c)+
                parseInt(woaPigs.Number_with_shoulder_lesions_Score_2__c)+
                parseInt(woaPigs.Too_dirty_to_assess_shoulder_lesions__c)
            );
            console.log('shoulderLesionsCount:::',shoulderLesionsCount);
            if(shoulderLesionsCount != totalValue){
                failedCount ++;
                component.set('v.shoulderLesionsError','Total number of this section should match Number of pigs assessed in pens 1 - 5 value');
            }else{
                component.set('v.shoulderLesionsError',"");
            }
            let vulvaLesionsCount = (
                parseInt(woaPigs.Number_with_vulva_lesion_Score_0__c) +
                parseInt( woaPigs.Number_with_vulva_lesion_Score_1__c)+
                parseInt(woaPigs.Number_with_vulva_lesion_Score_2__c)+
                parseInt(woaPigs.Too_dirty_to_assess_vulva_lesions__c)
            );
            if(vulvaLesionsCount != totalValue){
                failedCount ++;
                component.set('v.vulvaLesionsError','Total number of this section should match Number of pigs assessed in pens 1 - 5 value');
            }else{
                component.set('v.vulvaLesionsError',"");
            }
            let bodyConditionCount = (
                parseInt(woaPigs.Number_with_body_condition_Thin__c) + 
                parseInt(woaPigs.Number_with_body_condition_Moderate__c)+
                parseInt(woaPigs.Number_with_body_condition_Fat__c)
            );
            if(bodyConditionCount != totalValue){
                failedCount ++;
                component.set('v.bodyConditionError','Total number of this section should match Number of pigs assessed in pens 1 - 5 value');
            }else{
                component.set('v.bodyConditionError',"");
            }
        }
        if(woaPigs.Dry_sows_or_Finishing_pigs__c == 'Finishing pigs'){
            
            let tailLesionsCount = (
                parseInt(woaPigs.Number_of_tail_lesion_Score_0__c) + 
                parseInt(woaPigs.Number_of_tail_lesion_Score_1__c)+
                parseInt(woaPigs.Number_of_tail_lesion_Score_2__c)+
                parseInt(woaPigs.Too_dirty_to_assess_Tail_lesions__c)
            );
            if(tailLesionsCount != totalValue){
                failedCount ++;
                component.set('v.tailLesionsError','Total number of this section should match Number of pigs assessed in pens 1 - 5 value');
            }else{
                component.set('v.tailLesionsError',"");
            }
        }
        if(failedCount >0){
            return false;
        }
        return true;
    }
})