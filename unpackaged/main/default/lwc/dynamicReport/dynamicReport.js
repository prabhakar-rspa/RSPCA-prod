import { LightningElement,wire,api } from 'lwc';
/*import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Name';
import userContactIdFld from '@salesforce/schema/User.ContactId';
import userContactNameFld from '@salesforce/schema/User.Contact.Name';
import userMembershipNumberFld from '@salesforce/schema/User.Contact.Account.Head_Office_Number__c';
import userHeadOfficeNumberFld from '@salesforce/schema/User.Contact.Account.Parent.Head_Office_Number__c';*/
//import getMembershipNumber from '@salesforce/apex/DynamicReportController.getMembershipNumber';
export default class DynamicReport extends LightningElement {
    contactId;
    @api reportId;
    @api buttonLabel;
    membershipNumber;
    get reporturl(){
        return "/s/report/"+this.reportId+"?queryScope=userFolders";
    }
    /*get  reporturl(){
        return this.membershipNumber ? "/s/report/"+this.reportId+"?queryScope=userFolders":"/s/report/"+this.reportId+"?queryScope=userFolders";//{%22column%22:%22Account.Primary_Contact__c%22,%22operator%22:%22equals%22,%22value%22:%22"+this.contactName+"%22},
    }*/
    /*get  reporturl(){
        return this.membershipNumber ? "/s/report/"+this.reportId+"?queryScope=userFolders&reportFilters=[{%22column%22:%22Account.Membership_Number__c%22,%22operator%22:%22startsWith%22,%22value%22:%22"+this.membershipNumber+"%22}]":"/s/report/"+this.reportId+"?queryScope=userFolders";//{%22column%22:%22Account.Primary_Contact__c%22,%22operator%22:%22equals%22,%22value%22:%22"+this.contactName+"%22},
    }*/
    /*@wire(getMembershipNumber)
    wiredMembershipNumer({error,data}){
        if(data){
            console.log('data::',data);
            this.membershipNumber = data;
        }else{
            console.log(error);
        }
    }*/
    /*@wire(getRecord, { recordId: Id, fields: [UserNameFld, userContactIdFld,userContactNameFld,userMembershipNumberFld,userHeadOfficeNumberFld]}) 
    userDetails({error, data}) {
        if (data) {
            console.log(data.fields);
            this.contactId = data.fields.ContactId.value;
            if(data.fields.Contact && data.fields.Contact.value && data.fields.Contact.value.fields){
                this.contactName = data.fields.Contact.value.fields.Name.value;
                console.log('data.fields.Contact:::',data.fields.Contact);
                if(data.fields.Contact.value.fields.Account.value && data.fields.Contact.value.fields.Account.value.fields.Head_Office_Number__c){
                    this.membershipNumber = data.fields.Contact.value.fields.Account.value.fields.Head_Office_Number__c.value;
                    console.log(data.fields.Contact.value.fields.Account.value.fields.Head_Office_Number__c.value);
                }
            }
        } else if (error) {
            console.log('error::',error);
        }
    }*/
    openReport(){
        window.open(this.reporturl);
    }
}