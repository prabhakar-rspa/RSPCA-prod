({
    getWoaPigsData : function(component, event, helper) {
        var action = component.get("c.getWOAPigs");
        action.setParams({
            "recordId": component.get("v.woaSummaryRecord.Id"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.woaPigs", response.getReturnValue());
                // set the selected values for breedingRearingFinishingValues
                if( component.get("v.woaPigs.Breeding_Rearing_Finishing__c") != null ){
                    var breedingRearingFinishingValues = component.get("v.woaPigs.Breeding_Rearing_Finishing__c").split(';');
                    component.set("v.breedingRearingFinishinSelected", breedingRearingFinishingValues);
                }
                // set the selected values for furtherCareReasons
                if( component.get("v.woaPigs.Reason_for_further_care__c") != null ){
                    var furtherCareSelected = component.get("v.woaPigs.Reason_for_further_care__c").split(';');
                    component.set("v.furtherCareSelected", furtherCareSelected);
                }
                // set the selected values for predominantBodyRegions
                if( component.get("v.woaPigs.Predominant_body_region_s_of_body_marks__c") != null ){
                    var predominantBodyRegionSelected = component.get("v.woaPigs.Predominant_body_region_s_of_body_marks__c").split(';');
                    component.set("v.predominantBodyRegionSelected", predominantBodyRegionSelected);
                }
                // set the selected values for improvementsMade
                if( component.get("v.woaPigs.Improvements_made_in_last_12_month__c") != null ){
                    var improvementsMadeSelected = component.get("v.woaPigs.Improvements_made_in_last_12_month__c").split(';');
                    component.set("v.improvementsMadeSelected", improvementsMadeSelected);
                }
                 // set the selected values for improvementsPlanneed
                 if( component.get("v.woaPigs.Improvements_planned_for_next_12_months__c") != null ){
                    var improvementsPlannedSelected = component.get("v.woaPigs.Improvements_planned_for_next_12_months__c").split(';');
                    component.set("v.improvementsPlannedSelected", improvementsPlannedSelected);
                }

                // set the selected values for penDesignDrySows
                if( component.get("v.woaPigs.Pen_design_dry_sows__c") != null ){
                    var penDesignDrySowsSelected = component.get("v.woaPigs.Pen_design_dry_sows__c").split(';');
                    component.set("v.penDesignDrySowsSelected", penDesignDrySowsSelected);
                }
                 // set the selected values for penDesignFinishing
                 if( component.get("v.woaPigs.Pen_design_finishing_pigs__c") != null ){
                    var penDesignFinishingSelected = component.get("v.woaPigs.Pen_design_finishing_pigs__c").split(';');
                    component.set("v.penDesignFinishingSelected", penDesignFinishingSelected);
                }
            }else{
                console.log('Problem getting WOA Pigs Data, response state: ' + state);
            }
            
        })
        $A.enqueueAction(action);
    }
})