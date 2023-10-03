import { LightningElement, api, track } from "lwc";

export default class ColumnInput extends LightningElement {
  @track _record = {};
  get readOnly(){
    let hiddenName = this.apiName+'hide';
    console.log('hiddenName:::',hiddenName);
    return this._record.readOnly ? true: (this._record[hiddenName]?true:false);
  }
  @api get record() {
    return this._record;
  }
  set record(value) {
    this._record = { ...value };
    if (this.apiName) {
      this.fieldValue =
        this._record[this.apiName] || this._record[this.apiName] === 0
          ? this._record[this.apiName]
          : "";
      if (this.fieldType === "Lookup") {
        this.isLookup = true;
        console.log("filterFieldName::", this.filterFieldName);
        console.log("filterSourceFieldName::", this.filterSourceFieldName);
        if (
          this.filterSourceFieldName &&
          this._record[this.filterSourceFieldName]
        ) {
          if (
            !this.filterSourceFieldValue ||
            this._record[this.filterSourceFieldName] ===
              this.filterSourceFieldValue
          ) {
            this.filter =
              this.filterFieldName +
              " LIKE '%" +
              this._record[this.filterSourceFieldName] +
              "%'";
          } else {
            this.filter =
            ' (NOT ('+this.filterFieldName +
              " LIKE '%" +
              this.filterSourceFieldValue +
              "%')) ";
          }
        }else{
          this.filter = '';
        }
        if (this.urlName && this._record[this.urlName])
          this.recordName = this._record[this.urlName];
      }
    }
  }
  @api filterSourceFieldValue;
  @api filter;
  @api filterFieldName;
  @api filterSourceFieldName;
  @api recordId;
  @api objectName;
  @api apiName;
  @api fieldType;
  @api isRequired;
  @api rowIndex;
  @api dependentField;
  @track fieldValue;
  @track isText = false;
  @track isNumber = false;
  @track isCheckbox = false;
  @track isDate = false;
  @track isDateTime = false;
  @track isPicklist = false;
  @track isCurrency = false;
  @track isLookup = false;
  @track isMultiPicklist = false;
  @track recordName = "";
  @track _options;
  @api get options() {
    return this._options;
  }
  set options(val) {
    if (val) {
      this._options = JSON.parse(JSON.stringify(val));

    } else {
      this._options = [];
    }
  }

  connectedCallback() {
    this.fieldValue = this._record[this.apiName];
    if (this.fieldType === "Text") this.isText = true;
    else if (this.fieldType === "Number") this.isNumber = true;
    else if (this.fieldType === "Checkbox") this.isCheckbox = true;
    else if (this.fieldType === "Date") this.isDate = true;
    else if (this.fieldType === "Date Time") this.isDateTime = true;
    else if (this.fieldType === "Picklist") {
      if (this.fieldType === "Picklist") this.isPicklist = true;
      if (this.fieldValue) {
        let selected = false;
        let values = JSON.parse(JSON.stringify(this.options));
        values.forEach(option => {
          if (option.value === this.fieldValue) {
            option.selected = true;
            selected = true;
          } else option.selected = false;
        });
        if (!selected) {
          values.push({
            value: this.fieldValue,
            label: this.fieldValue,
            selected: true
          });
        }
        this._options = values;
      }
    }else if (this.fieldType === "Multiselect"){
      let selectedValues = [];
      if(this.fieldValue) selectedValues = this.fieldValue.split(';');
      this.isMultiPicklist = true;
      let values = JSON.parse(JSON.stringify(this.options));
      values.forEach(option => {
        if (selectedValues.includes(option.value) != -1) {
          option.selected = true;
        } else option.selected = false;
      });
    } 
    else if (this.fieldType === "Currency") this.isCurrency = true;
    else if (this.fieldType === "Lookup") {
      this.isLookup = true;
      console.log("filterFieldName::", this.filterFieldName);
      console.log("filterSourceFieldName::", this.filterSourceFieldName);
      if (
        this.filterSourceFieldName &&
        this._record[this.filterSourceFieldName]
      ) {
        if (
          !this.filterSourceFieldValue ||
          this._record[this.filterSourceFieldName] ===
            this.filterSourceFieldValue
        ) {
          this.filter =
            this.filterFieldName +
            " LIKE '%" +
            this._record[this.filterSourceFieldName] +
            "%'";
        } else {
          this.filter =
            ' (NOT ('+this.filterFieldName +
            " LIKE '%" +
            this.filterSourceFieldValue +
            "%' ))";
        }
      }else{
        this.filter = '';
      }
      if (this.urlName && this._record[this.urlName])
        this.recordName = this._record[this.urlName];
    }
  }

  @api
  isColumnValid() {
    let isValid = true;

    if (this.isRequired) {
      if (
        this.fieldValue === undefined ||
        this.fieldValue === null ||
        this.fieldValue === ""
      ) {
        isValid = false;
      }
    }
    return isValid;
  }

  handleCheckBoxUpdate() {
    let checkboxVal = false;
    let selectedRows = this.template.querySelectorAll(".selectCheckbox");
    if (selectedRows[0].type === "checkbox") {
      checkboxVal = selectedRows[0].checked;
    }

    let columnUpdate = {
      lineId: this._record.Id,
      rowIndex: this.rowIndex,
      fieldName: this.apiName,
      fieldVal: checkboxVal
    };

    this.dispatchEvent(
      new CustomEvent("columnupdate", { detail: columnUpdate })
    );
  }

  handleUpdate(event) {
    let updatedVal = event.detail.value;
    this.fieldValue = updatedVal;

    let columnUpdate = {
      lineId: this._record.Id,
      rowIndex: this.rowIndex,
      fieldName: this.apiName,
      fieldVal: updatedVal
    };

    this.dispatchEvent(
      new CustomEvent("columnupdate", { detail: columnUpdate })
    );
  }
  
  handleSelect(event) {
    let result = event.detail;
    if (result.selectedValue || result.selectedLabel) {
      console.log("result", result);
      let columnUpdate = {
        lineId: this._record.Id,
        rowIndex: this.rowIndex,
        fieldName: this.apiName,
        fieldVal: result.selectedLabel
      };

      this.dispatchEvent(
        new CustomEvent("columnupdate", { detail: columnUpdate })
      );

      this.dispatchEvent(
        new CustomEvent("setvalue", {
          detail: {
            value: result.selectedValue,
            fieldName: this.dependentField,
            rowIndex: this.rowIndex
          }
        })
      );
      /*let dataTableCmp = this.template.querySelector("c-ci-data-table");
            dataTableCmp.setValues(
              "itemDescription",
              fieldDetails.index,
              selectedValue
            );*/
    }
  }
  /*handleBlur(event){
    
    let columnUpdate = {
      lineId: this._record.Id,
      rowIndex: this.rowIndex,
      fieldName: this.apiName,
      fieldVal: this.fieldValue
    };

    this.dispatchEvent(
      new CustomEvent("columnblur", { detail: columnUpdate })
    );
  }*/
  /*handlePicklistUpdate() {
    let ltngSelect = this.template.querySelectorAll("select");
    let selectedVal = ltngSelect[0].value;
    console.log("selectedVal::::", selectedVal);
    if (selectedVal == "none") this.fieldValue = "";
    else this.fieldValue = selectedVal;

    let columnUpdate = {
      lineId: this._record.Id,
      rowIndex: this.rowIndex,
      fieldName: this.apiName,
      fieldVal: selectedVal
    };

    this.dispatchEvent(
      new CustomEvent("columnupdate", { detail: columnUpdate })
    );
  }*/
  handleSelection(event){
    let selectedoptions = event.detail.selectedoptions;
    console.log('selectedoptions:::',selectedoptions);
    this.fieldValue = selectedoptions.join(";");

    let columnUpdate = {
      lineId: this._record.Id,
      rowIndex: this.rowIndex,
      fieldName: this.apiName,
      fieldVal: this.fieldValue
    };

    this.dispatchEvent(
      new CustomEvent("columnupdate", { detail: columnUpdate })
    );

  }
  handleLookupSelection(event) {
    let recordId = event.detail.Id;
    //let Name = event.detail.Name;
    //let fieldName = event.detail.Name;

    this.fieldValue = recordId;

    let columnUpdate = {
      lineId: this._record.Id,
      rowIndex: this.rowIndex,
      fieldName: this.apiName,
      fieldVal: recordId
    };

    this.dispatchEvent(
      new CustomEvent("columnupdate", { detail: columnUpdate })
    );
  }
}