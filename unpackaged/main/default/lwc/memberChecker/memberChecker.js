import { LightningElement, track} from 'lwc';
import getStatus from '@salesforce/apex/MemberCheckerController.getStatus';

export default class MemberChecker extends LightningElement {

    showSearch=true;
    @track status; // stavi dekorater ako treba
    @track memNumber;

    handleSearch() {
        this.showSearch=false; // posle ovoga neka validacija za membership number
        this.memNumber = this.template.querySelector(`[data-id="mem-number"]`).value;
        getStatus({membershipNumber: this.memNumber})
        .then(result => {
          console.log("Result: " +result);
          if(result!=undefined && result!=null){
            this.status=result.Status__c; // promeni
          }
          else{
            this.status= 'Member not found';
          }
          
        })
        .catch(error => {
          this.error = error;
          console.log('Error is ' + this.error);
        });

    }

    handleBack() {
        this.showSearch=true;
    }
}