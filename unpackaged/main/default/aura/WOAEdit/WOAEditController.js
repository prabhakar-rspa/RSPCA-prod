({
  doInit: function (component, event, helper) {
    helper.getWOASummaryRecord(component);
    helper.getAssessors(component);
  },
  handleSave: function (component, event, helper) {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1;
    var yyyy = today.getFullYear();
    var todayFormatted =
      yyyy +
      "-" +
      mm.toString().padStart(2, "0") +
      "-" +
      dd.toString().padStart(2, "0");

    var woaSummaryValid = helper.validateFields(component);
    var woaCompleting = component.get("v.woaSummaryRecord.CompletingWOA__c");
    if (woaSummaryValid) {
      console.log(
        "All form entries on WOA Summary look valid. Ready to submit!"
      );
      if (component.get("v.woaSummaryRecord.Species_Type__c") == "Laying Hen") {
        var layingHenComponent = component.find("layingHenComponent");
        var woaCompleteToggle = layingHenComponent.get("v.woaCompleteToggle");
        var layingHensValid;
        if (woaCompleteToggle) {
          layingHensValid = helper.validateFields(layingHenComponent);
        } else {
          layingHensValid = true;
        }
        if (layingHensValid) {
          var additionalValid = true;
          if (woaCompleting == "Yes" && woaCompleteToggle)
            additionalValid = layingHenComponent.additionalValidations();
          if (additionalValid) {
            console.log(
              "All form entries on WOAHens look valid. Ready to submit!"
            );
            // complete form if answered 'No'
            if (woaCompleting == "No") {
              component.set(
                "v.woaSummaryRecord.IsCompleted__c",
                layingHenComponent.get("v.woaCompleteToggle")
              );
            } else if (woaCompleting == "Yes") {
              component.set(
                "v.woaSummaryRecord.IsCompleted__c",
                layingHenComponent.get("v.woaCompleteToggle")
              );
              if (layingHenComponent.get("v.woaCompleteToggle")) {
                component.set(
                  "v.woaSummaryRecord.Form_Completion_Date__c",
                  todayFormatted
                );
              }
            }
            helper.saveWOASummary(component);
            layingHenComponent.saveLayingHens();
            helper.navigateToApplication(component);
          }
        } else {
          alert("Please update the invalid form entries and try again.");
        }
      } else if (
        component.get("v.woaSummaryRecord.Species_Type__c") == "Dairy Cattle"
      ) {
        var dairyCattleComponent = component.find("dairyCattleComponent");
        var woaCompleteToggle = dairyCattleComponent.get("v.woaCompleteToggle");
        console.log("woaCompleteToggle::", woaCompleteToggle);
        var dairyValid;
        if (woaCompleteToggle) {
          dairyValid = helper.validateFields(dairyCattleComponent);
        } else {
          dairyValid = true;
        }
        console.log("dairyValid:::", dairyValid);
        var childValid;
        if (woaCompleteToggle) {
          childValid = dairyCattleComponent.validateChildRecords();
        } else {
          childValid = true;
        }
        console.log("childValid:::", childValid);
        if (dairyValid && childValid) {
          //var additionalValid = layingHenComponent.additionalValidations();

          console.log(
            "All form entries on WOADairy look valid. Ready to submit!"
          );
          // complete form if answered 'No'
          if (woaCompleting == "No") {
            component.set(
              "v.woaSummaryRecord.IsCompleted__c",
              dairyCattleComponent.get("v.woaCompleteToggle")
            );
          } else if (woaCompleting == "Yes") {
            component.set(
              "v.woaSummaryRecord.IsCompleted__c",
              dairyCattleComponent.get("v.woaCompleteToggle")
            );
            if (dairyCattleComponent.get("v.woaCompleteToggle")) {
              component.set(
                "v.woaSummaryRecord.Form_Completion_Date__c",
                todayFormatted
              );
            }
          }
          helper.saveWOASummary(component);
          dairyCattleComponent.saveDairy();
          helper.navigateToApplication(component);
        } else {
          alert("Please update the invalid form entries and try again.");
        }
      } else if (
        component.get("v.woaSummaryRecord.Species_Type__c") == "Pigs"
      ) {
        var pigComponent = component.find("pigComponent");
        var woaCompleteToggle = pigComponent.get("v.woaCompleteToggle");
        var pigValid;
        if (woaCompleteToggle) {
          pigValid = helper.validateFields(pigComponent);
        } else {
          pigValid = true;
        }
        //var pigValid = helper.validateFields(pigComponent);
        if (pigValid) {
          var extraValid;
          if (woaCompleteToggle) {
            extraValid = pigComponent.validate();
          } else {
            extraValid = true;
          }
          //var additionalValid = layingHenComponent.additionalValidations();
          console.log("extraValid:::", extraValid);
          if (
            extraValid ||
            component.get("v.woaSummaryRecord.CompletingWOA__c") == "No"
          ) {
            console.log(
              "All form entries on WOAPig look valid. Ready to submit!"
            );
            // complete form if answered 'No'
            if (woaCompleting == "No") {
              component.set(
                "v.woaSummaryRecord.IsCompleted__c",
                pigComponent.get("v.woaCompleteToggle")
              );
            } else if (woaCompleting == "Yes") {
              component.set(
                "v.woaSummaryRecord.IsCompleted__c",
                pigComponent.get("v.woaCompleteToggle")
              );
              if (pigComponent.get("v.woaCompleteToggle")) {
                component.set(
                  "v.woaSummaryRecord.Form_Completion_Date__c",
                  todayFormatted
                );
              }
            }
            helper.saveWOASummary(component);
            pigComponent.savePigs();
            helper.navigateToApplication(component);
          } else {
            alert("Please update the invalid form entries and try again.");
          }
        } else {
          alert("Please update the invalid form entries and try again.");
        }
      }
    } else {
      alert("Please update the invalid form entries and try again.");
    }
  },
  handleCancel: function (component, event, helper) {
    helper.navigateToApplication(component);
  },

  completingWOAChange: function (component, event, helper) {
    var selectedOptionValue = event.getParam("value");
    if (selectedOptionValue == "No") {
      var today = new Date();
      var dd = today.getDate();
      var mm = today.getMonth() + 1;
      var yyyy = today.getFullYear();
      var todayFormatted =
        yyyy +
        "-" +
        mm.toString().padStart(2, "0") +
        "-" +
        dd.toString().padStart(2, "0");
      component.set(
        "v.woaSummaryRecord.Form_Completion_Date__c",
        todayFormatted
      );
      component.set("v.woaSummaryRecord.IsCompleted__c", true);
    } else {
      component.set("v.woaSummaryRecord.Form_Completion_Date__c", null);
    }
  }
});