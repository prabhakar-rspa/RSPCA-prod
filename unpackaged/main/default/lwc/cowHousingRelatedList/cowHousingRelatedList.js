import { LightningElement, api, track, wire } from "lwc";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import BASE_FIELD from "@salesforce/schema/Cows_Housing__c.Base__c";
import BEDDING_FIELD from "@salesforce/schema/Cows_Housing__c.Bedding__c";
import HOUSING_TYPE_FIELD from "@salesforce/schema/Cows_Housing__c.Housing_Type__c";
import COWS_HOUSING_OBJECT from "@salesforce/schema/Cows_Housing__c";
import getCowHousing from "@salesforce/apex/WOADairyController.getCowHousing";
export default class CowHousingRelatedList extends LightningElement {
  @api disableAll;
  @api recordTypeName;
  @api deletedRecords = [];
  showBaseOptions = true;
  get addButtonLabel() {
    return this.recordTypeName
      ? "Add another " +
          this.recordTypeName.toLowerCase() +
          " cows housing type"
      : "Add another cows housing type";
  }
  @api get woaDairyId() {
    return this._woaDairyId;
  }
  set woaDairyId(val) {
    this._woaDairyId = val;
    if (val) {
      this.isLoading = true;
      this.getCosHousingRecords();
    }
  }
  @track isLoading = false;
  @track objectInfo;
  @track recordTypeId;
  @track _records = [];
  @track basePicklistValues = [];
  @track beddingPicklistValues = [];
  @track housingTypePicklistValues = [];

  @api get records() {
    alert('get records');
    console.log(JSON.stringify(this._records));
    return this._records;
  }
  set records(val) {
    if (val) {
      this._records = JSON.parse(JSON.stringify(val));
    } else {
      this._records = [
        {
          index: 1,
          baseFieldName: this.recordTypeName + "Base__c-1",
          beddingFieldName: this.recordTypeName + "Bedding__c-1",
          recordTypeId: this.recordTypeId,
          disableBaseOptions : false
        }
      ];
    }
    
  }
  getCosHousingRecords() {
    console.log("this.recordTypeName", this.recordTypeName);
    console.log("this.woaDairyId", this.woaDairyId);
    if (this.recordTypeName && this.woaDairyId) {
      getCowHousing({
        woaDairyId: this.woaDairyId,
        recordTypeName: this.recordTypeName
      })
        .then((data) => {
          let records = JSON.parse(data);
          if (records && records.length) {
            records.forEach((record, index) => {
              record.index = index + 1;
              record.disableBaseOptions = (record.Housing_Type__c == 'Deep litter yar') ? true : false;
              record.baseFieldName =
                this.recordTypeName + "Base__c-" + record.index;
              record.beddingFieldName =
                this.recordTypeName + "Bedding__c-" + record.index;
                
              if (record.Base__c === "Other") record.showBaseNotes = true;
              if (record.Bedding__c === "Other") record.showBeddingNotes = true;
            });
            this._records = [...records];
          }
          
          this.isLoading = false;
        })
        .catch((error) => {});
    } else {
      this.isLoading = false;
    }
  }
  /*@wire(getCowHousing, {
    woaDairyId: "$woaDairyId",
    recordTypeId: "$recordTypeId"
  })
  wiredCowHousing({ error, data }) {
    if (data) {
      let records = JSON.parse(data);
      if (records && records.length) {
        records.forEach((record, index) => {
          record.index = index + 1;
          record.baseFieldName =
            this.recordTypeName + "Base__c-" + record.index;
          record.beddingFieldName =
            this.recordTypeName + "Bedding__c-" + record.index;
          if (record.Base__c === "Other") record.showBaseNotes = true;
          if (record.Bedding__c === "Other") record.showBeddingNotes = true;
        });
        this._records = [...records];
      }
    }
  }*/
  @wire(getObjectInfo, { objectApiName: COWS_HOUSING_OBJECT })
  wiredobjectInfo({ error, data }) {
    console.log("object data:::", data);
    console.log("object error:::", error);
    if (data && data.recordTypeInfos) {
      const rtis = data.recordTypeInfos;
      this.recordTypeId = Object.keys(rtis).find(
        (rti) => rtis[rti].name === this.recordTypeName
      );
      if (this._records && this._records.length > 0) {
        this._records.forEach((record, index) => {
          record.index = index + 1;
          console.log('record.Housing_Type__c'+record.Housing_Type__c);
          record.disableBaseOptions = (record.Housing_Type__c == 'Deep litter yar') ? true : false;
          console.log('record.disableBaseOptions'+record.disableBaseOptions);
          record.baseFieldName =
            this.recordTypeName + "Base__c-" + record.index;
          record.beddingFieldName =
            this.recordTypeName + "Bedding__c-" + record.index;
        });
      } else {
        this._records = [
          {
            index: 1,
            baseFieldName: this.recordTypeName + "Base__c-1",
            beddingFieldName: this.recordTypeName + "Bedding__c-1",
            recordTypeId: this.recordTypeId,
            disableBaseOptions : false
          }
        ];
      }
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: BASE_FIELD
  })
  wiredBaseField({ error, data }) {
    if (data && data.values) {
      this.basePicklistValues = data.values;
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: BEDDING_FIELD
  })
  wiredBeddingField({ error, data }) {
    if (data && data.values) {
      this.beddingPicklistValues = data.values;
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: HOUSING_TYPE_FIELD
  })
  wiredHousingTypeField({ error, data }) {
    if (data && data.values) {
      this.housingTypePicklistValues = data.values;
    }
  }
  removeRow(event) {
    let selectedIndex = event.target.dataset.index;
    let id = event.target.dataset.Id;
    let selectedRecord = this._records[selectedIndex];
    if (selectedRecord.Id) {
      this.deletedRecords.push(selectedRecord.Id);
    }
    this._records.splice(selectedIndex, 1);
    let position = this.selectedRows.indexOf(id);
    if (position !== -1) this.selectedRows.splice(position, 1);
    this._records.forEach((record, index) => {
      record.index = index + 1;
      record.baseFieldName = this.recordTypeName + "Base__c-" + record.index;
      record.beddingFieldName =
        this.recordTypeName + "Bedding__c-" + record.index;
    });
  }
  handleChange(event) {
    console.log(event.target.name);
    console.log("change event", event);
    let value = event.detail.value;
    let target = event.target || event.currentTarget;
    let index = target.dataset.index;
    let fieldName = target.dataset.fieldname;
    console.log("name:::", target.name);
    console.log("value:::", value);
    console.log("index:::", index);
    this._records[index][fieldName] = value;
    if(fieldName == "Housing_Type__c"){
        this._records[index].disableBaseOptions = (value == 'Deep litter yar') ? true : false;
    }
    
    if (fieldName == "Base__c") {
      if (value == "Other") this._records[index].showBaseNotes = true;
      else this._records[index].showBaseNotes = false;
    } else if (fieldName == "Bedding__c") {
     
      if (value == "Other") this._records[index].showBeddingNotes = true;
      else this._records[index].showBeddingNotes = false;
    }
    console.log(JSON.stringify(this._records));
  }
  addRow() {
    let records = this._records;
    let index = 1;
    if (records && records.length > 0) {
      index = this._records[records.length - 1].index + 1;
    }
    this._records.push({
      index: index,
      baseFieldName: this.recordTypeName + "Base__c-" + index,
      beddingFieldName: this.recordTypeName + "Bedding__c-" + index,
      recordTypeId: this.recordTypeId
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
    return { records: this._records, deletedRecords: this.deletedRecords };
  }

  get showReqSign(){
    for(let key in this._records){
      if(!this._records[key].disableBaseOptions){
        return true;
      }
    }
    return false;
  }
}