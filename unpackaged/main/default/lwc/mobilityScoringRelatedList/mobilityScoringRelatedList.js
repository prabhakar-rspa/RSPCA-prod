import { LightningElement, api, track, wire } from "lwc";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import WHO_SCORES_FIELD from "@salesforce/schema/Mobility_Scoring__c.Who_scores__c";
import ROMS_FIELD from "@salesforce/schema/Mobility_Scoring__c.RoMS__c";
import HOW_OFTEN_FIELD from "@salesforce/schema/Mobility_Scoring__c.How_often__c";
import WHICH_COWS_FIELD from "@salesforce/schema/Mobility_Scoring__c.Which_cows__c";
import MOBILITY_SCORING_OBJECT from "@salesforce/schema/Mobility_Scoring__c";
import getMobilityScoring from "@salesforce/apex/WOADairyController.getMobilityScoring";
export default class MobilityScoringRelatedList extends LightningElement {
  @api disableAll;
  @api get woaDairyId() {
    return this._woaDairyId;
  }
  set woaDairyId(val) {
    this._woaDairyId = val;
    if (val) {
      this.isLoading = true;
      this.getMobilityScoringRecords();
    }
  }
  @track deletedRecords = [];
  @track isLoading = false;
  @track objectInfo;
  @track records = [{ index: 1 }];
  @track whoScoresPicklistValues = [];
  @track romsPicklistValues = [];
  @track howOftenPicklistValues = [];
  @track whichCowsPicklistValues = [];
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: WHO_SCORES_FIELD
  })
  wiredWhoScoresField({ error, data }) {
    if (data && data.values) {
      this.whoScoresPicklistValues = data.values;
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: ROMS_FIELD
  })
  wiredRomsField({ error, data }) {
    if (data && data.values) {
      this.romsPicklistValues = data.values;
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: HOW_OFTEN_FIELD
  })
  wiredHowOftenField({ error, data }) {
    if (data && data.values) {
      this.howOftenPicklistValues = data.values;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: WHICH_COWS_FIELD
  })
  wiredWhichCowsField({ error, data }) {
    if (data && data.values) {
      this.whichCowsPicklistValues = data.values;
    }
  }
  getMobilityScoringRecords() {
    console.log("this.woaDairyId", this.woaDairyId);
    if (this.woaDairyId) {
      getMobilityScoring({
        woaDairyId: this.woaDairyId
      })
        .then((data) => {
          let records = JSON.parse(data);
          if (records && records.length) {
            records.forEach((record, index) => {
              record.index = index + 1;
              if (record.Who_scores__c === "Other")
                record.showWhoScoresNotes = true;
              if (record.How_often__c === "Other")
                record.showHowOftenNotes = true;
              if (record.Which_cows__c === "Other")
                record.showWhichCowsNotes = true;
            });
            this.records = [...records];
          }
          this.isLoading = false;
        })
        .catch((error) => {});
    } else {
      this.isLoading = false;
    }
  }
  removeRow(event) {
    let selectedIndex = event.target.dataset.index;
    let id = event.target.dataset.Id;
    let selectedRecord = this.records[selectedIndex];
    if (selectedRecord.Id) {
      this.deletedRecords.push(selectedRecord.Id);
    }
    this.records.splice(selectedIndex, 1);
    let position = this.selectedRows.indexOf(id);
    if (position !== -1) this.selectedRows.splice(position, 1);
    this.records.forEach((record, index) => {
      record.index = index + 1;
    });
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
    this.records[index][fieldName] = value;
    if (fieldName === "Who_scores__c") {
      if (value === "Other") this.records[index].showWhoScoresNotes = true;
      else this.records[index].showWhoScoresNotes = false;
    } else if (fieldName === "How_often__c") {
      if (value === "Other") this.records[index].showHowOftenNotes = true;
      else this.records[index].showHowOftenNotes = false;
    } else if (fieldName === "Which_cows__c") {
      if (value === "Other") this.records[index].showWhichCowsNotes = true;
      else this.records[index].showWhichCowsNotes = false;
    }
  }
  addRow() {
    let records = this.records;
    let index = 1;
    if (records && records.length > 0) {
      index = this.records[records.length - 1].index + 1;
    }
    this.records.push({
      index: index
    });
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
    return { records: this.records, deletedRecords: this.deletedRecords };
  }
}