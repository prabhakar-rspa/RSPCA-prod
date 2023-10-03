import { LightningElement,api,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContacts from '@salesforce/apex/SendBulkRenewalInvoiceController.getContacts';
import sendMultipleInvoices from '@salesforce/apex/SendBulkRenewalInvoiceController.sendMultipleInvoices';
import createSageInvoice from '@salesforce/apex/SendBulkRenewalInvoiceController.createInvoice';
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email', type: 'email' }
];
export default class SendBulkRenewalInvoice extends LightningElement {
    @api
    get recordId(){
        return this._recordId;
    }
    set recordId(val){
        this._recordId = val;
        this.isLoading = true;
        this.getHeadOfficeContacts(val);
    }
    get contactsAvailable(){
        return this.records && this.records.length >0 ?true:false;
    }
    @track records;
    invoiceDate;
    message;
    columns = columns;
    selectedRows = [];
    @track isLoading;
    getHeadOfficeContacts(recordId){
        getContacts({recordId:recordId}).then(data=>{
            if(data){
                this.records = JSON.parse(JSON.stringify(JSON.parse(data)));
            }
            this.isLoading = false;
        }).catch(error=>{
            console.log('error:::',error);
        })
    }
    /*handleMessageChange(event){
        this.message = event.target.value;
    }
    handleDateChange(event){
        this.invoiceDate = event.target.value;
    }*/
    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    getSelectedRecord(event){
        const selectedRows = event.detail.selectedRows;
        this.selectedRows = [];
        for (let i = 0; i < selectedRows.length; i++) {
            console.log('You selected: ' + selectedRows[i].Id);
            this.selectedRows.push(selectedRows[i].Id);
        }
    }
    UpdateMessage(){
        console.log('message::',this.message);
        console.log('selectedRows::',this.selectedRows);
        if(this.selectedRows.length>0){
            if(this.isValid()){
                this.isLoading = true;
                this.template.querySelector('lightning-record-edit-form').submit();
                console.log('submitted:::::::::');

            }
            /*updateBulkRenewal({message:this.message, recordId:this.recordId,invoiceDate:this.invoiceDate}).then(data=>{
                this.sendInvoice();
            }).error(error=>{
                this.showMessage("Error", this.processError(error), "error");
                this.isLoading = false;
            })*/
        }else{
            this.showMessage("Error", "Please select any contact", "error");
        }
    }
    isValid() {
        let valid = [
          ...this.template.querySelectorAll("lightning-input-field")
        ].reduce((validSoFar, field) => {
          return validSoFar && field.reportValidity();
        }, true);
    
        return valid;
      }
    handleError(event){
        console.log('error event',event);
        this.isLoading = false;
    }
    handleSucess(){
        console.log('this.recordId:::::::::',this.recordId);
        createSageInvoice({recordId:this.recordId}).then(data=>{
            console.log('data:::::::::',data);
            this.sendInvoice();
        }).catch(error=>{
            console.log('error:::::::::',error);
            this.showMessage("Error", this.processError(error), "error");
            this.isLoading = false;
        })
        //this.sendInvoice();
    }
    sendInvoice(){
        sendMultipleInvoices({
            contactId:this.selectedRows,message:this.message, recordId:this.recordId
        }).then(data=>{
            this.showMessage("Success", "Invoice send successfully", "success");
            this.isLoading = false;
            this.handleCancel();
        }).catch(error=>{
            console.log('error:::',error);
            this.showMessage("Error", this.processError(error), "error");
            this.isLoading = false;
        })
    }
    processError(error) {
        let message = "";
        if (Array.isArray(error.body)) {
          message = error.body.map(e => e.message).join(", ");
        } else if (typeof error.body.message === "string") {
          message = error.body.message;
        }
        return message;
      }
    showMessage(title, message, variant) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
          })
        );
      }
}