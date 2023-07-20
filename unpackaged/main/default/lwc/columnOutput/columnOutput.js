import { LightningElement, api, track } from 'lwc';
import CURRENCY from '@salesforce/i18n/currency';
export default class CiColumnOutput extends LightningElement {
    @api isClickable;
    @api rowIndex;
    @track _record;
    @api inputClass;
    @api isTextLink;
    @track urlValue;
    get isNotEmpty(){
        return this.fieldValue && this.urlValue ? true:false;
    }
    @api get record(){
        return this._record;
    }
    set record(value){
        this._record = {...value};
        if(this.apiName){
            if(this.fieldType === 'Date'){
                let fieldValue = this._record[this.apiName];
                
                if(fieldValue){
                    if(fieldValue.includes(' '))this.fieldValue = fieldValue.split(' ')[0];
                    else if(fieldValue.includes('-'))this.fieldValue = fieldValue;
                }
            }else{
                if(this.apiName.includes('.')){
                    console.log('yes includes');
                    let apiNames = this.apiName.split('.');
                    console.log('yes includes',apiNames);
                    console.log('yes includes',this._record[apiNames[0]]);
                    if(this._record[apiNames[0]]){
                        this.fieldValue = this._record[apiNames[0]][apiNames[1]];
                    }
                }else{
                    this.fieldValue = this._record[this.apiName];
                }
            }
        }
        this.isLink = false;
        if(this.fieldType === 'Link' && this.urlName && this._record[this.urlName]){
            this.isLink = true;
            this.urlValue = '/'+this._record[this.urlName];
        }else{
            this.urlValue = '';
        }

    }
    @api apiName;
    @api urlName;
    @api fieldType;
    @api wrapText;
    @track fieldValue;
    @track isImage = false;
    @track isText = false;
    @track isNumber = false;
    @track isCheckbox = false;
    @track isDate = false;
    @track isDateTime = false;
    @track isPicklist = false;
    @track isProductName = false;
    @track isCurrency = false;
    @track isLink = false;
    currencyCode = CURRENCY;
    renderedCallback() {
        if(this.apiName){
            if(this.fieldType === 'Date'){
                let fieldValue = this._record[this.apiName];
                if(fieldValue){
                    //console.log('fieldValue:::',fieldValue);
                    if(fieldValue.includes(' '))this.fieldValue = fieldValue.split(' ')[0];
                    else if(fieldValue.includes('-'))this.fieldValue = fieldValue;
                }
            }else{
                //this.fieldValue = this._record[this.apiName];
                if(this.apiName.includes('.')){
                    let apiNames = this.apiName.split('.');
                    if(this._record[apiNames[0]]){
                        this.fieldValue = this._record[apiNames[0]][apiNames[1]];
                    }
                }else{
                    this.fieldValue = this._record[this.apiName];
                }
            }
            //console.log('this.fieldValue ::',this.fieldValue );
        }
        if (this.fieldType === 'Text'){
            this.isText = true;
        } 
        else if (this.fieldType === 'Currency') {
            this.isCurrency = true;
        }else if (this.fieldType === 'Number') this.isNumber = true;
        else if (this.fieldType === 'Checkbox') this.isCheckbox = true;
        else if (this.fieldType === 'Date') {
            this.isDate = true;
        }
        else if (this.fieldType === 'Date Time') this.isDateTime = true;
        else if (this.fieldType === 'Picklist') this.isPicklist = true;
        else if(this.fieldType === 'Link' && this.urlName && this._record[this.urlName]){
            this.urlValue = '/'+this._record[this.urlName];
            this.isLink = true;
        }
    }
    handleClick(){
        if(this.isClickable){
            this.dispatchEvent(new CustomEvent('outputclick',{detail:{apiName:this.apiName,rowIndex:this.rowIndex}}));
        }
    }
}