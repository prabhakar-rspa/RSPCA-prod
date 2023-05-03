({
    doInit : function(component) {
        var action = component.get("c.getPickListValuesIntoList");
        action.setParams({
            objectType: component.get("v.sObjectName"),
            selectedField: component.get("v.fieldName")
        });
        action.setCallback(this, function(response) {
            var list = response.getReturnValue();
            component.set("v.picklistValues", list);
            let hiddenValues = component.get('v.hiddenValues') || [];
            var listOfPicklistValues = [];
            for (var i = 0; i < list.length; i++) {
                var singlePicklist = {};
                singlePicklist['label'] = list[i];
                singlePicklist['value'] = list[i];
                if(hiddenValues.indexOf(list[i]) == -1){
                    listOfPicklistValues.push(singlePicklist);
                }
            }
            component.set("v.picklistValuesCombobox", listOfPicklistValues);
            console.log(listOfPicklistValues);
        })
        $A.enqueueAction(action);
    }
})