import { LightningElement ,track,api} from 'lwc';
import getContacts from '@salesforce/apex/ContactListViewController.getContacts';
export default class ContactListView extends LightningElement {
    @api accountType;
    get isSiteAccount(){
        return this.accountType == 'Site'?true:false;
    }
    get isHeadOfficeAccount(){
      return this.accountType == 'Head Office'?true:false;
    }
    @track isLoading = true;
    outputColumns = [
        {
          columnName: "Name",
          columnLabel: "Name",
          columnType: "Text",
          fixedWidth: "width:20rem;",
        },
        {
          columnName: "Email",
          columnLabel: "Email",
          columnType: "Text",
          fixedWidth: "width:20rem;"
        },
        {
          columnName: "Title",
          columnLabel: "Title",
          columnType: "Text",
          fixedWidth: "width:20rem;",
        },
        {
          columnName: "Phone",
          columnLabel: "Phone",
          columnType: "Text",
          fixedWidth: "width:10rem;"
        }
    ];
    inputColumns = [
        {
          columnName: "FirstName",
          columnLabel: "First Name",
          columnType: "Text",
          isEditable: true,
          fixedWidth: "width:10rem;",
        },
        {
            columnName: "LastName",
            columnLabel: "Last Name",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:10rem;"
        },
        {
          columnName: "Email",
          isRequired:true,
          columnLabel: "Email",
          columnType: "Text",
          isEditable: true,
          fixedWidth: "width:20rem;"
        },
        {
          columnName: "Title",
          isRequired:true,
          columnLabel: "Title",
          columnType: "Text",
          isEditable: true,
          fixedWidth: "width:20rem;",
        },
        {
          columnName: "Phone",
          columnLabel: "Phone",
          columnType: "Text",
          isEditable: true,
          fixedWidth: "width:10rem;"
        }
    ];
    @track  headOfficeContacts =[];
    @track  siteContacts =[];
    headOfficeAccountId;
    siteAccountId;
    primaryContact ={};
    get showHeadOfficeContacts(){
        return this.headOfficeContacts && this.headOfficeContacts.length>0?true:false;
    }
    get showSiteContacts(){
        console.log(this.siteContacts.length);
        return this.siteContacts && this.siteContacts.length>0?true:false;
    }
    connectedCallback(){
        this.getAllContacts();
    }
    getAllContacts(){
        getContacts().then(data=>{
            console.log('data:::',data);
            let result = JSON.parse(data);
            this.headOfficeAccountId = result.headOfficeAccountId;
            this.siteAccountId = result.siteAccountId;
            this.primaryContact = result.primaryContact;
            this.siteContacts = result.siteContacts;
            this.headOfficeContacts = result.headOfficeContacts;
            
            this.isLoading = false;
            console.log('result:::',result);
            console.log('result:::',this.headOfficeContacts);
            console.log('result:::',this.siteContacts);
        }).catch(error=>{
            console.log('error:::',error);
            this.isLoading = false;
        });
    }
    handleRefresh(){
      console.log('refresh');
      this.headOfficeContacts =[];
      this.siteContacts =[];
      this.isLoading = true;
      this.getAllContacts();
    }
    
}