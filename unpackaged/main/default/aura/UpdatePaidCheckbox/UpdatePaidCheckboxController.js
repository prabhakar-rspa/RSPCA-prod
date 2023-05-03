({

    handleLoad: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
    },

    handleSubmit: function(cmp, event, helper) {
        cmp.set('v.disabled', true);
        cmp.set('v.showSpinner', true);
    },

    handleError: function(cmp, event, helper) {
        // errors are handled by lightning:inputField and lightning:nessages
        // so this just hides the spinnet
        cmp.set('v.showSpinner', false);
    },

    handleSuccess: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        cmp.set('v.saved', true);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },

    handleCancel: function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
});