({
  getWOASummaryRecord: function (component, event, helper) {
    var action = component.get("c.getWOASummaryRecord");
    action.setParams({
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.woaSummaryRecord", response.getReturnValue());
        console.log(":::::::", component.get("v.woaSummaryRecord"));
        if (
          !component.get("v.woaSummaryRecord.Visit_Date__c") &&
          component.get("v.woaSummaryRecord.Application__r.Assessment_Date__c")
        ) {
          component.set(
            "v.woaSummaryRecord.Visit_Date__c",
            component.get(
              "v.woaSummaryRecord.Application__r.Assessment_Date__c"
            )
          );
        }

        if (!component.get("v.woaSummaryRecord.Visit_Type__c")) {
          component.set("v.woaSummaryRecord.Visit_Type__c", "RSPCA Assured");
        }
        if (component.get("v.woaSummaryRecord.IsCompleted__c") == true) {
          component.set("v.dynamicDisableField", true);
        } else {
          component.set("v.dynamicDisableField", false);
        }
      } else {
        console.log("Problem getting record, response state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  getAssessors: function (component, event, helper) {
    var action = component.get("c.getAssessors");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.assessorOptions", response.getReturnValue());
      } else {
        console.log("Problem getting assessors, response state: " + state);
      }
    });
    $A.enqueueAction(action);
  },

  validateFields: function (component) {
    var fields = component.find("field");
    console.log("Fields found: " + fields);
    if (fields != null) {
      var allValid = component
        .find("field")
        .reduce(function (validSoFar, inputCmp) {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);
      return allValid;
    } else {
      return true;
    }
  },

  saveWOASummary: function (component, event, helper) {
    var action = component.get("c.saveWOASummary");
    action.setParams({
      woaSummary: component.get("v.woaSummaryRecord")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("Woa Summary Saved");
      } else {
        console.log("Problem saving WOA Summary, response state: " + state);
      }
    });
    $A.enqueueAction(action);
  },

  navigateToApplication: function (component, event, helper) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: component.get("v.woaSummaryRecord.Application__c"),
      slideDevName: "detail"
    });
    navEvt.fire();
  }
});