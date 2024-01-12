import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AssessmentChecklistSourceSelection extends LightningElement {
    @api recordId;
    @track isloading = false;
    filter ={};
    assessorOptions = [
        { label: 'None', value: '' }
    ];
    @track filteredAssessmentChecklistDetails =[];
    @api get assessmentChecklistDetails(){
        return this._assessmentChecklistDetails;
    }
    set assessmentChecklistDetails(val){
        console.log('val:::',val);
        let details = JSON.parse(JSON.stringify(val));
        let assessors = [];
        try{
            details.forEach(detail=>{
                if(!detail.sourceAssessment && detail.otherAssessmentsAvailable){
                    detail.OtherAssessments.forEach(other=>{
                        other.membershipNumber = other.Application__r.Membership_Number__c;
                        other.applicationType = other.Application__r.Application_Type__c;
                        other.siteName = other.Application__r.Site__r.Name;
                        other.assessmentDate = other.Application__r.Assessment_Date__c;
                        other.assessor = other.Application__r.Assessor__r?other.Application__r.Assessor__r.Name:'';
                        if(other.Application__r.Assessor__c && assessors.indexOf(other.Application__r.Assessor__c) == -1){
                            let option = {
                                label:other.Application__r.Assessor__r.Name,
                                value:other.Application__r.Assessor__c
                            };
                            assessors.push(other.Application__r.Assessor__c);
                            this.assessorOptions.push(option);
                        }
                    })
                }
            });
            this._assessmentChecklistDetails = [...details];
            this.filteredAssessmentChecklistDetails = details;
        }catch(e){
            console.log(e);
        }
        
    }
    columns = [
        {
            label: "Name",
            fieldName: "Name",
            columnType: "Text",
            fixedWidth: "width:5rem;",
        },
        {
            label: "Application Type",
            fieldName: "applicationType",
            columnType: "Text",
            fixedWidth: "width:5rem;"
        },
        /*{
            fieldName: "Animals_List__c",
            label: "Animals List",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },*/
        {
            fieldName: "membershipNumber",
            label: "Membership Number",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
        {
            fieldName: "siteName",
            label: "Site Name",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
        {
            fieldName: "assessor",
            label: "Assessor",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
        {
            fieldName: "assessmentDate",
            label: "Assessment Date",
            type: "date-local",
            typeAttributes:{
                month: "2-digit",
                day: "2-digit"
            },
            fixedWidth: "width:10rem;",
        }

    ];
    @api
    getDetails(){
        let tableCmps = this.template.querySelectorAll("lightning-datatable");
        let assessmentChecklistDetails = JSON.parse(JSON.stringify(this._assessmentChecklistDetails));
        console.log('other assessments:::',assessmentChecklistDetails);
        let failedCount = 0;
        tableCmps.forEach((tableCmp,index)=>{
            let selectedRows = tableCmp.getSelectedRows();
            console.log('selectedRows:::',selectedRows);
            console.log('index:::',index);
            if(selectedRows.length == 1){
                if(assessmentChecklistDetails[index].OtherAssessments){
                    assessmentChecklistDetails[index].OtherAssessments.forEach(assessment=>{
                        if(assessment.Id == selectedRows[0].Id){
                            assessmentChecklistDetails[index].sourceAssessment = assessment;
                            console.log('matched');
                        }
                    });
                    console.log('other assessments:::',assessmentChecklistDetails[index]);
                }

            }else{
                if(selectedRows.length == 0){
                    this.showMessage('Error', 'Please select an assessment checklist', 'error');
                    failedCount++;
                }
            }
            
            
        });
        if(failedCount == 0){
            return assessmentChecklistDetails;
        }else{
            return undefined;
        }
    }
    handleChange(event){
        this.filter[event.target.name] = event.target.value;
        console.log(this.filter);
    }
    clearFilters(){
        this.isloading = true;
        let inputCmps = this.template.querySelectorAll('lightning-input');
        inputCmps.forEach(inputCmp=>{
            inputCmp.value='';
        });
        let comboCmp = this.template.querySelector('lightning-combobox');
        comboCmp.value = '';
        this.filter = {};
        let details = JSON.parse(JSON.stringify(this._assessmentChecklistDetails));
        this.filteredAssessmentChecklistDetails = details;
        this.isloading = false;
    }
    applyFilters(){
        try{
            this.isloading = true;
            console.log('filter:::::',this.filter);
            //filteredAssessmentChecklistDetails
            let details = JSON.parse(JSON.stringify(this._assessmentChecklistDetails));
            details.forEach(detail=>{
                if(!detail.sourceAssessment && detail.otherAssessmentsAvailable){
                    let otherAssessments = [];
                    detail.OtherAssessments.forEach(other=>{
                        let conditionMet = true;
                        if(this.filter.assessor){
                            if((other.Application__r.Assessor__c != this.filter.assessor)){
                                conditionMet = false;
                            }
                        }
                        if(this.filter.membershipNumber){
                            if(!(other.Application__r.Membership_Number__c.startsWith(this.filter.membershipNumber))){
                                conditionMet = false;
                            }
                        }
                        if(this.filter.startDate){
                            console.log(other.Application__r.Assessment_Date__c);
                            console.log(this.filter.startDate);
                            if(!(other.Application__r.Assessment_Date__c >= this.filter.startDate)){
                                conditionMet = false;
                            }
                        }
                        if(this.filter.endDate){
                            if(!(other.Application__r.Assessment_Date__c <= this.filter.endDate)){
                                conditionMet = false;
                            }
                        }
                        console.log(':::conditionMet:::',conditionMet);
                        if(conditionMet){
                            otherAssessments.push(other);
                        }
                    })
                    detail.OtherAssessments = otherAssessments;
                    if(otherAssessments.length == 0){
                        detail.otherAssessmentsAvailable = false;
                    }else{
                        detail.otherAssessmentsAvailable = true;
                    }
                }
            });
            this.filteredAssessmentChecklistDetails = details;
            console.log('::::::',this.filteredAssessmentChecklistDetails);
            this.isloading = false;
        }catch(e){

        }
        
    }
    showMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}