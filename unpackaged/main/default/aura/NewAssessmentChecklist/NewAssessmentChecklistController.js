({
	doInit: function (component, event, helper) {
		helper.getChecklistTemplates(component);
	},
    
    handleSubmit:function(component, event, helper){
        var tempIDs = [];
        
        // get(find) all checkboxes with aura:id "checkBox"
        var getAllId = component.find("checkBox");
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
        
        // call the helper function and pass all selected record id's.   
        helper.createSelectedChecklist(component, event, tempIDs);
    },
    
    handleCancel: function () {
        $A.get("e.force:closeQuickAction").fire();
    },
})