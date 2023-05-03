({
  doInit: function (component, event, helper) {
    helper.getWoaDairyData(component);
    component.set(
      "v.woaCompleteToggle",
      component.get("v.woaSummaryRecord.IsCompleted__c")
    );
  },
  validateChildRecords: function (component, event, helper) {
    console.log("here calling");
    var allValid = true;
    var cowHousingComponents = component.find("cowHousing");
    if (cowHousingComponents) {
      if (cowHousingComponents.length > 0) {
        cowHousingComponents.forEach((chCmp) => {
          let isvalid = chCmp.validateFields();
          if (!isvalid) {
            allValid = false;
          }
        });
      } else {
        allValid = false;
      }
    } else {
      allValid = true;
    }

    return allValid;
  },
  saveDairy: function (component, event, helper) {
    let cowHousingRecords = [];
    let cowHousingDeletedRecords = [];
    var cowHousingComponents = component.find("cowHousing");
    if (cowHousingComponents && cowHousingComponents.length > 0) {
      cowHousingComponents.forEach((chCmp) => {
        let dmlRecords = chCmp.getRecords();
        console.log("dmlRecords:::", dmlRecords);
        if (dmlRecords) {
          if (dmlRecords.records && dmlRecords.records.length > 0) {
            cowHousingRecords = cowHousingRecords.concat(dmlRecords.records);
          }
          if (
            dmlRecords.deletedRecords &&
            dmlRecords.deletedRecords.length > 0
          ) {
            cowHousingDeletedRecords = cowHousingDeletedRecords.concat(
              dmlRecords.deletedRecords
            );
          }
        }
      });
    }
    var mobilityScoringCmp = component.find("mobilityScoring");
    var mobilityScoringRecords = [];
    var mobilityScoringDeletedRecords = [];
    if (mobilityScoringCmp) {
      let dmlRecords = mobilityScoringCmp.getRecords();
      console.log("mobility dmlRecords:::", dmlRecords);
      if (dmlRecords) {
        if (dmlRecords.records && dmlRecords.records.length > 0) {
          mobilityScoringRecords = dmlRecords.records;
        }
        if (dmlRecords.deletedRecords && dmlRecords.deletedRecords.length > 0) {
          mobilityScoringDeletedRecords = dmlRecords.deletedRecords;
        }
      }
    }
    console.log("mobility records", JSON.stringify(mobilityScoringRecords));
    console.log(
      "Mobility deleted",
      JSON.stringify(mobilityScoringDeletedRecords)
    );
    var lamenessPrevalenceCmp = component.find("lamenessPrevalence");
    var lamenessPrevalenceRecords = [];
    var mobilityScoringDeletedRecords = [];
    if (lamenessPrevalenceCmp) {
      lamenessPrevalenceRecords = lamenessPrevalenceCmp.getRecords();
      console.log(
        "lamenessPrevalence dmlRecords:::",
        lamenessPrevalenceRecords
      );
    }

    var action = component.get("c.saveWOADairy");
    action.setParams({
      woaDairy: component.get("v.woaDairy"),
      cowHousing: JSON.stringify(cowHousingRecords),
      deletedCHRecords: cowHousingDeletedRecords,
      mobilityScoring: JSON.stringify(mobilityScoringRecords),
      deletedMSRecords: mobilityScoringDeletedRecords,
      lamenessPrevalence: JSON.stringify(lamenessPrevalenceRecords)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("WOA Dairy Saved");
      } else {
        console.log(
          "Problem saving WOA Dairy Cattle Data, response state: " + state
        );
      }
    });
    $A.enqueueAction(action);
  },
  handleImprovementsMadeChange: function (component, event, helper) {
    var selectedValues = event.getParam("value");
    component.set("v.woaDairy.ImprovementMade__c", selectedValues.join(";"));
  },
  handleImprovementsPlannedChange: function (component, event, helper) {
    var selectedValues = event.getParam("value");
    component.set("v.woaDairy.ImprovementPlanned__c", selectedValues.join(";"));
  }
});