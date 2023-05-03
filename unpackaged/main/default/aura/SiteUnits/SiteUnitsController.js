({
    doInit : function(component) {
        var action = component.get("c.getUnits");
        action.setParams({
            accId: component.get("v.siteId")
        });
        action.setCallback(this, function(response) {
            var unitlist = response.getReturnValue();
            component.set("v.unitList", unitlist);
        })
        $A.enqueueAction(action);
    }
})