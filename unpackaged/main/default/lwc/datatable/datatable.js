import { LightningElement, api, track } from "lwc";

export default class DataTable extends LightningElement {
  @api selectLabel;
  @api columns;
  @api showRemoveRows;
  @api showEditRows;
  @api selectOnchange;
  @api rowSelectable;
  @track sortDirection = "ASC";
  @track sortBy = "Name";
  @api isFixedHeader;
  @api bodyHeight;
  @api setStatusOnRemove;
  @api isResizeable;
  @api currentGroupingType;
 
  get overflowStyle() {
    return !this.isFixedHeader
      ? "overflow:initial;width:100%"
      : "overflow-x: auto;width:100%";
  }
  get heightStyle() {
    return !this.isFixedHeader
      ? "slds-table_edit_container"
      : "slds-table_edit_container slds-scrollable_y  custom-height";
  }
  @api get records() {
    return this._records;
  }
  set records(val) {
    if (val) {
      this._records = JSON.parse(JSON.stringify(val));
    } else {
      this._records = [];
    }
  }
  @track _records = [];
  get hasData() {
    return this._records && this._records.length > 0 ? true : false;
  }
  connectedCallback() {//Dynamically render columns based on type field in resource roster. Used in resourceRosterRelatedList
  }
  fixedWidth = "width:10rem;";
  selectedRows = [];
  @api
  setValues(fieldName, rowIndex, value) {
    let sobj = this._records[rowIndex];
    sobj[fieldName] = value;
    console.log("calling", fieldName, rowIndex, value);
    this._records[rowIndex] = JSON.parse(JSON.stringify(sobj));
  }
  
  handleSetValue(event) {
    let fieldName = event.detail.fieldName;
    let rowIndex = event.detail.rowIndex;
    let value = event.detail.value;
    let sobj = this._records[rowIndex];
    sobj[fieldName] = value;
    this._records[rowIndex] = JSON.parse(JSON.stringify(sobj));
    
  }
  @api
  addRows(value, indexAttribute) {
    value.index = this._records ? this._records.length : 0;
    value[indexAttribute] = value.index + 1;
    console.log("value:", value);
    this._records.unshift(value);
    console.log(this._records.length);
  }
  @api
  returnSelectdRows() {
    return this.selectedRows;
  }
  removeRow(event) {
    let index = event.target.dataset.index;
    let id = event.target.dataset.Id;
    console.log("index::", index);
    let record = this._records[index];
    this._records.splice(index, 1);
    let position = this.selectedRows.indexOf(id);
    if (position !== -1) this.selectedRows.splice(position, 1);
  }
  editRow(event) {
    let index = event.target.dataset.index;
    let id = event.target.dataset.Id;
    this.dispatchEvent(
      new CustomEvent("edit", { detail: { index: index, id: id } })
    );
  }
  handleColumnUpdate(event) {
    let updatedSobj = event.detail;
    let propName = updatedSobj.fieldName;
    let propVal = updatedSobj.fieldVal;
    let rowIndex = updatedSobj.rowIndex;
    console.log(propName, "-", propVal);
    let sobj = this._records[rowIndex];
    sobj[propName] = propVal;
    if (this.selectOnchange) {
      sobj.selected = true;
      let index = rowIndex.toString();
      let position = this.selectedRows.indexOf(index);
      if (position === -1) this.selectedRows.push(index);
    }
    this._records[rowIndex] = JSON.parse(JSON.stringify(sobj));

    this.dispatchEvent(
      new CustomEvent("handleupdate", {
        detail: { fieldName: propName, fieldValue: propVal, index: rowIndex ,tableType:this.currentGroupingType}
      })
    );

  }
  /*handleColumnBlur(event){
    let updatedSobj = event.detail;
    let propName = updatedSobj.fieldName;
    let propVal = updatedSobj.fieldVal;
    let rowIndex = updatedSobj.rowIndex;
    this.dispatchEvent(
      new CustomEvent("handleupdate", { detail: {fieldName:propName,fieldValue:propVal,index:rowIndex} })
    );
  }*/
  allSelected(event) {
    let checked = event.detail.checked;
    let selectCmp = this.template.querySelectorAll("lightning-input");
    let records = this._records;

    selectCmp.forEach((cmp) => {
      let id = cmp.dataset.id;
      let index = cmp.dataset.index;
      let value = id ? id : index;
      if (value) {
        cmp.checked = checked;
        let position = this.selectedRows.indexOf(value);
        if (checked) {
          if (position === -1) this.selectedRows.push(value);
        } else {
          if (position !== -1) this.selectedRows.splice(position, 1);
        }
      }
      if (index) {
        let sobj = records[index];
        sobj.selected = checked;
        records[index] = sobj;
      }
    });
    this._records = JSON.parse(JSON.stringify(records));
    console.log("this.selectedRows:::", this.selectedRows);
  }
  handleSelected(event) {
    let id = event.target.dataset.id;
    let index = event.target.dataset.index;
    let value = id ? id : index;
    let checked = event.target.checked;
    if (checked) {
      this.selectedRows.push(value);
    } else {
      let position = this.selectedRows.indexOf(value);
      this.selectedRows.splice(position, 1);
    }
    if (this.selectOnchange) {
      let sobj = this._records[index];
      sobj.selected = checked;
      this._records[index] = JSON.parse(JSON.stringify(sobj));
    }

    console.log("this.selectedRows:::", this.selectedRows);
  }
  handleSorting(event) {
    let headerTitle = event.target.title;
    this.sortRecords(headerTitle);
  }
  handleSortingUpdate(event) {
    let headerTitle = event.detail;
    this.sortRecords(headerTitle);
  }
  sortRecords(headerTitle) {
    console.log("headerTitle:::" + headerTitle);

    console.log("sortBy:::" + this.sortBy);
    if (this.sortBy && headerTitle === this.sortBy) {
      this.sortDirection = this.sortDirection === "ASC" ? "DESC" : "ASC";
    } else {
      this.sortBy = headerTitle;
      this.sortDirection = "ASC";
    }
    let sortDirection = this.sortDirection;
    let headerSortingCmp = this.template.querySelectorAll(
      "c-ci-header-sorting"
    );
    headerSortingCmp.forEach((cmp) => {
      cmp.reload(headerTitle, sortDirection);
    });
    let records = this.records;
    if (this.sortDirection == "ASC") {
      records.sort(function (record1, record2) {
        return record1[headerTitle] > record2[headerTitle] ? 1 : -1;
      });
    } else {
      records.sort(function (record1, record2) {
        return record1[headerTitle] < record2[headerTitle] ? 1 : -1;
      });
    }
    this.records = JSON.parse(JSON.stringify(records));
  }
  onRowClick(event) {
    console.log("event:::", event);
    /*let target = event.target || event.currentTarget;
    let index = target.dataset.index;
    this.dispatchEvent(new CustomEvent('rowclick',{detail:index}));
    event.stopPropagation();*/
  }
  handleOutputClick(event) {
    console.log("event:::", event);
    let rowIndex = event.detail.rowIndex;
    let apiName = event.detail.apiName;
    this.dispatchEvent(
      new CustomEvent("dataclick", {
        detail: { rowIndex: rowIndex, apiName: apiName }
      })
    );
  }
  tableOuterDivScrolled(event) {
    this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
    if (this._tableViewInnerDiv) {
      if (
        !this._tableViewInnerDivOffsetWidth ||
        this._tableViewInnerDivOffsetWidth === 0
      ) {
        this._tableViewInnerDivOffsetWidth =
          this._tableViewInnerDiv.offsetWidth;
      }
      this._tableViewInnerDiv.style =
        "width:" +
        (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) +
        "px;" +
        this.tableBodyStyle;
    }
    this.tableScrolled(event);
  }
  tableScrolled(event) {
    if (this.enableInfiniteScrolling) {
      if (
        event.target.scrollTop + event.target.offsetHeight >=
        event.target.scrollHeight
      ) {
        this.dispatchEvent(
          new CustomEvent("showmorerecords", {
            bubbles: true
          })
        );
      }
    }
    if (this.enableBatchLoading) {
      if (
        event.target.scrollTop + event.target.offsetHeight >=
        event.target.scrollHeight
      ) {
        this.dispatchEvent(
          new CustomEvent("shownextbatch", {
            bubbles: true
          })
        );
      }
    }
  }
  handlemouseup(e) {
    if(this._tableThColumn){//This logic set the modified column width to newly adding row.
      let curentIndex = this._tableThColumn.dataset.index;//This retuns the curent column's index located inside this.column 
      let columns = JSON.parse(JSON.stringify(this.columns));
      let curentWidth = this._tableThColumn.style.width;
      columns[curentIndex].fixedWidth='width:'+curentWidth+';';
      this.columns=columns;
    }
      this._tableThColumn = undefined;
      this._tableThInnerDiv = undefined;
      this._pageX = undefined;
      this._tableThWidth = undefined;
  }
  handlemousedown(e) {
      if (!this._initWidths) {
        this._initWidths = [];
        let tableThs = this.template.querySelectorAll(
          "table thead .dv-dynamic-width"
        );
        tableThs.forEach((th) => {
          this._initWidths.push(th.style.width);
        });
        this._originalColumnReceived = JSON.parse(JSON.stringify(this.columns));
      }
      this._tableThColumn = e.target.parentElement;
      this._tableThInnerDiv = e.target.parentElement;
      while (this._tableThColumn.tagName !== "TH") {
        this._tableThColumn = this._tableThColumn.parentNode;
      }
      while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
        this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
      }
      console.log(
        "handlemousedown this._tableThColumn.tagName => ",
        this._tableThColumn.tagName
      );
      console.log('pageX',e.pageX);
      console.log('this._tableThColumn',this._tableThColumn);
      this._pageX = e.pageX;
      
      this._padding = this.paddingDiff(this._tableThColumn);
      console.log('this._padding',this._padding);

      this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
      console.log('this._tableThWidth',this._tableThWidth);
      console.log(
        "handlemousedown this._tableThColumn.tagName => ",
        this._tableThColumn.tagName
      );
      this._resized = true;
  }
  handledblclickresizable() {
    if(this._resized==true){
      let tableThs = this.template.querySelectorAll(
        "table thead .dv-dynamic-width"
      );
      let tableBodyRows = this.template.querySelectorAll("table tbody tr");
      tableThs.forEach((th, ind) => {
        th.style.width = this._initWidths[ind];
        th.querySelector(".slds-cell-fixed").style.width =
          this._initWidths[ind];
      });
      tableBodyRows.forEach((row) => {
        let rowTds = row.querySelectorAll(".dv-dynamic-width");
        rowTds.forEach((td, ind) => {
          rowTds[ind].style.width = this._initWidths[ind];
        });
      });
      this.columns=this._originalColumnReceived;
    }
  }
  handlemousemove(e) {
    if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
      console.log("mousemove this._tableThColumn => ", this._tableThColumn);
      console.log("e.pageX - this._pageX=",e.pageX,'-',this._pageX);
      this._diffX = e.pageX - this._pageX;
      console.log("this._diffX ", this._diffX);

      this.template.querySelector("table").style.width =
        this.template.querySelector("table") - this._diffX + "px";

      this._tableThColumn.style.width = this._tableThWidth + this._diffX + "px";
      this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

      let tableThs = this.template.querySelectorAll(
        "table thead .dv-dynamic-width"
      );
      let tableBodyRows = this.template.querySelectorAll("table tbody tr");
      let tableBodyTds = this.template.querySelectorAll(
        "table tbody .dv-dynamic-width"
      );
      tableBodyRows.forEach((row) => {
        let rowTds = row.querySelectorAll(".dv-dynamic-width");
        rowTds.forEach((td, ind) => {
          rowTds[ind].style.width = tableThs[ind].style.width;
        });
      });
    }
  }
  paddingDiff(col) {
    if (this.getStyleVal(col, "box-sizing") === "border-box") {
      return 0;
    }

    this._padLeft = this.getStyleVal(col, "padding-left");
    this._padRight = this.getStyleVal(col, "padding-right");
    return parseInt(this._padLeft, 10) + parseInt(this._padRight, 10);
  }
  getStyleVal(elm, css) {
    return window.getComputedStyle(elm, null).getPropertyValue(css);
  }
}