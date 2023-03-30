import { LightningElement, track, api } from "lwc";
import getLamenessPrevalence from "@salesforce/apex/WOADairyController.getLamenessPrevalence";

export default class LamenessPrevalenceRelatedList extends LightningElement {
  @track records = [{ index: 1 }, { index: 2 }, { index: 3 }, { index: 4 }];
  @api disableAll;
  record1 = {};
  record2 = {};
  record3 = {};
  record4 = {};
  averageOfScore2Cows = 0;
  averageOfScore3Cows = 0;
  @track deletedRecords = [];
  @track isLoading = false;
  @api get woaDairyId() {
    return this._woaDairyId;
  }
  set woaDairyId(val) {
    this._woaDairyId = val;
    if (val) {
      this.isLoading = true;
      this.getLamenessPrevalenceRecords();
    }
  }
  getLamenessPrevalenceRecords() {
    console.log("this.woaDairyId", this.woaDairyId);
    if (this.woaDairyId) {
      getLamenessPrevalence({
        woaDairyId: this.woaDairyId
      })
        .then((data) => {
          let records = JSON.parse(data);
          if (records && records.length) {
            if (records[0]) {
              this.record1 = records[0];
            }
            if (records[1]) {
              this.record2 = records[1];
            }
            if (records[2]) {
              this.record3 = records[2];
            }
            if (records[3]) {
              this.record4 = records[3];
            }
            this.calculateAverage("Percentage_Of_Score_2_cows__c");
            this.calculateAverage("Percentage_Of_Score_3_cows__c");
          }
          this.isLoading = false;
        })
        .catch((error) => {});
    } else {
      this.isLoading = false;
    }
  }
  handleChange(event) {
    console.log("change event", event);
    let value = event.detail.value;
    let target = event.target || event.currentTarget;
    let index = target.dataset.index;
    let fieldName = target.dataset.fieldname;
    console.log("name:::", target.name);
    console.log("value:::", value);
    console.log("index:::", index);
    if (index === "1") {
      this.record1[fieldName] = value;
    } else if (index === "2") {
      this.record2[fieldName] = value;
    } else if (index === "3") {
      this.record3[fieldName] = value;
    } else if (index === "4") {
      this.record4[fieldName] = value;
    }
    this.calculateAverage(fieldName);
  }
  @api
  validateFields() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll(".validate");
    inputFields.forEach((inputField) => {
      if (!inputField.checkValidity()) {
        inputField.reportValidity();
        isValid = false;
      }
    });
    console.log("valid", isValid);
    return isValid;
  }
  @api
  getRecords() {
    let records = [this.record1, this.record2, this.record3, this.record4];
    return records;
  }
  calculateAverage(fieldName) {

    console.log('-------------values------------');
    if (fieldName === "Percentage_Of_Score_2_cows__c") {
      let total = this.record1.Percentage_Of_Score_2_cows__c
        ? parseFloat(this.record1.Percentage_Of_Score_2_cows__c)
        : 0;
      total += this.record2.Percentage_Of_Score_2_cows__c
        ? parseFloat(this.record2.Percentage_Of_Score_2_cows__c)
        : 0;
      total += this.record3.Percentage_Of_Score_2_cows__c
        ? parseFloat(this.record3.Percentage_Of_Score_2_cows__c)
        : 0;
      total += this.record4.Percentage_Of_Score_2_cows__c
        ? parseFloat(this.record4.Percentage_Of_Score_2_cows__c)
        : 0;
      this.averageOfScore2Cows = parseFloat(total / 4).toFixed(2);
    } else if (fieldName === "Percentage_Of_Score_3_cows__c") {
      let total = this.record1.Percentage_Of_Score_3_cows__c
        ? parseFloat(this.record1.Percentage_Of_Score_3_cows__c)
        : 0;
      total += this.record2.Percentage_Of_Score_3_cows__c
        ? parseFloat(this.record2.Percentage_Of_Score_3_cows__c)
        : 0;
      total += this.record3.Percentage_Of_Score_3_cows__c
        ? parseFloat(this.record3.Percentage_Of_Score_3_cows__c)
        : 0;
      total += this.record4.Percentage_Of_Score_3_cows__c
        ? parseFloat(this.record4.Percentage_Of_Score_3_cows__c)
        : 0;
      this.averageOfScore3Cows = parseFloat(total / 4).toFixed(2);
    }
  }
}