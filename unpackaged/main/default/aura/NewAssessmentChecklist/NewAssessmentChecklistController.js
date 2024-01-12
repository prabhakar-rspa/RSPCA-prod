({
	doInit: function (component, event, helper) {
		helper.getChecklistTemplates(component);
	},
    
    handleSubmit:function(component, event, helper){
        var tempIDs = [];
        var selectedRow =  component.get('v.selectedRow');
        if(selectedRow && selectedRow.Id){
            tempIDs.push(selectedRow.Id);
        }
        // get(find) all checkboxes with aura:id "checkBox"
        /*var getAllId = component.find("checkBox");
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
        }*/
        
        // call the helper function and pass all selected record id's.   
        if(tempIDs.length == 1){
            component.set('v.checklistIds',tempIDs);
        	helper.checkSelectedChecklist(component, event, tempIDs);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": 'Please select checklist before submitting'
            });
            toastEvent.fire();
            
        }
    },
    skip: function (component,event,helper) {
        let  assessmentChecklistDetails = component.get('v.assessmentChecklistDetails');
        console.log('assessmentChecklistDetails:::',assessmentChecklistDetails);
        helper.createSelectedChecklist(component, event, component.get('v.checklistIds'),assessmentChecklistDetails);
    },
    copyChecklist: function (component,event,helper) {
        let sourceSelection = component.find('sourceSelection');
        if(sourceSelection){
            let assessmentChecklistDetails = sourceSelection.getDetails();
            console.log('assessmentChecklistDetails:::',assessmentChecklistDetails);
            if(assessmentChecklistDetails){
            	helper.createSelectedChecklist(component, event, component.get('v.checklistIds'),assessmentChecklistDetails);
            }
            //component.set('v.assessmentChecklistDetails',assessmentChecklistDetails);
        }
    },
    handleCancel: function () {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        console.log(selectedRows);
        component.set("v.selectedRow", selectedRows[0]);
    },
})