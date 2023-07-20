import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateContacts from '@salesforce/apex/ContactListViewController.updateContacts';
import createContact from '@salesforce/apex/ContactListViewController.createContact';
import deleteContacts from '@salesforce/apex/ContactListViewController.deleteContacts';
import getSiteAccounts from '@salesforce/apex/ContactListViewController.getSiteAccounts';
import getContactsToDelete from '@salesforce/apex/ContactListViewController.getContactsToDelete';
import getPicklistValues from '@salesforce/apex/ContactListViewController.getPicklistValues';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import ROLE_FIELD from '@salesforce/schema/Contact.Roles__c';


export default class ContactsTable extends LightningElement {
    get outputColumns() {
        return !this.parentAccountId ? this.headOfficeOutputColumns : this.siteOutputColumns;
    }
    get inputColumns() {

        return !this.parentAccountId ? this.headOfficeInputColumns : this.siteInputColumns;
    }
    headOfficeOutputColumns = [
        {
            columnName: "Name",
            columnLabel: "Name",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
        {
            columnName: "Email",
            columnLabel: "Email",
            columnType: "Text",
            fixedWidth: "width:15rem;"
        },
        {
            columnName: "Title",
            columnLabel: "Title",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
        {
            columnName: "Primary_Contact__c",
            columnLabel: "Primary Contact",
            columnType: "Checkbox",
            fixedWidth: "width:5rem;",
        },
        {
            columnName: "Roles__c",
            columnLabel: "Role",
            columnType: "Text",
            fixedWidth: "width:15rem;",
        },
        {
            columnName: "MobilePhone",
            columnLabel: "Mobile",
            columnType: "Text",
            fixedWidth: "width:10rem;"
        },
        {
            columnName: "Phone",
            columnLabel: "Phone",
            columnType: "Text",
            fixedWidth: "width:10rem;"
        },
        {
            columnName: "Preferred_Phone__c",
            columnLabel: "Preferred Phone",
            columnType: "Text",
            fixedWidth: "width:10rem;"
        }
    ];
    @track
    headOfficeInputColumns = [
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
            columnLabel: "Email",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:15rem;"
        },
        {
            columnName: "Title",
            columnLabel: "Title",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:10rem;",
        },
        {
            columnName: "Primary_Contact__c",
            columnLabel: "Primary Contact",
            columnType: "Checkbox",
            fixedWidth: "width:5rem;",
        },
        {
            columnName: "Roles__c",
            columnLabel: "Role",
            columnType: "Multiselect",
            isEditable: true,
            fixedWidth: "width:15rem;",
            options: []
        },
        {
            columnName: "MobilePhone",
            columnLabel: "Mobile",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:10rem;"
        },
        {
            columnName: "Phone",
            columnLabel: "Phone",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:10rem;"
        },
        {
            columnName: "Preferred_Phone__c",
            columnLabel: "Preferred Phone",
            columnType: "Picklist",
            isEditable: true,
            fixedWidth: "width:10rem;",
            options: [
                { label: 'None', value: '' }, { label: 'Landline', value: 'Landline' }, { label: 'Mobile', value: 'Mobile' }
            ]
        }
    ];
    siteOutputColumns = [
        {
            columnName: "Account.Membership_Number__c",
            columnLabel: "Membership Number",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
        {
            columnName: "Name",
            columnLabel: "Name",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
        {
            columnName: "Email",
            columnLabel: "Email",
            columnType: "Text",
            fixedWidth: "width:15rem;"
        },
        {
            columnName: "Title",
            columnLabel: "Title",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
        {
            columnName: "Roles__c",
            columnLabel: "Role",
            columnType: "Text",
            fixedWidth: "width:15rem;",
        },
        {
            columnName: "MobilePhone",
            columnLabel: "Mobile",
            columnType: "Text",
            fixedWidth: "width:10rem;"
        },
        {
            columnName: "Phone",
            columnLabel: "Phone",
            columnType: "Text",
            fixedWidth: "width:10rem;"
        },
        {
            columnName: "Preferred_Phone__c",
            columnLabel: "Preferred Phone",
            columnType: "Text",
            fixedWidth: "width:10rem;"
        }
    ];
    @track
    siteInputColumns = [
        {
            columnName: "Account.Membership_Number__c",
            columnLabel: "Membership Number",
            columnType: "Text",
            fixedWidth: "width:10rem;",
        },
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
            columnLabel: "Email",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:15rem;"
        },
        {
            columnName: "Title",
            columnLabel: "Title",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:10rem;",
        },
        {
            columnName: "Roles__c",
            columnLabel: "Role",
            columnType: "Multiselect",
            isEditable: true,
            fixedWidth: "width:15rem;",
            options: []

        },
        {
            columnName: "MobilePhone",
            columnLabel: "Mobile",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:10rem;"
        },
        {
            columnName: "Phone",
            columnLabel: "Phone",
            columnType: "Text",
            isEditable: true,
            fixedWidth: "width:10rem;"
        },
        {
            columnName: "Preferred_Phone__c",
            columnLabel: "Preferred Phone",
            columnType: "Picklist",
            isEditable: true,
            fixedWidth: "width:10rem;",
            options: [
                { label: 'None', value: '' }, { label: 'Landline', value: 'Landline' }, { label: 'Mobile', value: 'Mobile' }
            ]
        }
    ];
    @api primaryContact;
    @api records;
    editMode = false;
    @track isShowNewModal = false;
    @track isShowDeleteModal = false;
    @api label;
    @api isLoading = false;
    @api accountId;
    @api parentAccountId;
    //@api roleOptions = [];
    @track roleOptions = [
        {label:'Administration Contact',value:'Administration Contact'},
        {label:'Assessment Contact',value:'Assessment Contact'},
        {label:'Compliance Contact',value:'Compliance Contact'},
        {label:'Invoice Contact',value:'Invoice Contact'},
        {label:'Levy Contact',value:'Levy Contact'}
    ];
    options = [{ label: 'None', value: '' }];
    preferredPhoneOptions = [{ label: 'None', value: '' }, { label: 'Landline', value: 'Landline' }, { label: 'Mobile', value: 'Mobile' }];

    connectedCallback() {
        this.handleMultiPickListOptions();
    }

    get showAccount() {
        return this.options && this.options.length > 1 ? true : false;
    }
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    ContactMetadata;

    handleMultiPickListOptions() {
        /*getPicklistValues()
            .then(result => {
                if (result !== null) {
                    var rolePicklistValues = [];
                    for (let key in result) {
                        rolePicklistValues.push({
                            label: result[key], value: result[key]
                        });
                    }
                    this.roleOptions = rolePicklistValues;
                    for (const key in this.headOfficeInputColumns) {
                        if (this.headOfficeInputColumns[key].columnName == "Roles__c") {
                            this.headOfficeInputColumns[key].options = this.roleOptions;
                        }
                    }

                    for (const key in this.siteInputColumns) {
                        if (this.siteInputColumns[key].columnName == "Roles__c") {
                            this.siteInputColumns[key].options = this.roleOptions;
                        }
                    }
                }
            }
            );*/
        for (const key in this.headOfficeInputColumns) {
            if (this.headOfficeInputColumns[key].columnName == "Roles__c") {
                this.headOfficeInputColumns[key].options = this.roleOptions;
            }
        }

        for (const key in this.siteInputColumns) {
            if (this.siteInputColumns[key].columnName == "Roles__c") {
                this.siteInputColumns[key].options = this.roleOptions;
            }
        }
    }

    handleEdit() {
        this.changedIndex = [];
        this.editMode = true;
    }
    handleCancel() {
        this.changedIndex = [];
        this.editMode = false;
    }
    handleCreate() {
        if (this.accountId) {
            this.isShowNewModal = true;
            this.newContact.AccountId = this.accountId;
        } else {
            getSiteAccounts({ parentAccountId: this.parentAccountId }).then(data => {
                let result = JSON.parse(data);
                result.forEach(account => {
                    this.options.push({ label: account.Name + ' (' + account.Membership_Number__c + ')', value: account.Id });
                });
                this.isShowNewModal = true;
            }).catch(error => {
                this.showNotification('Error', error.body.message, 'error');
            })
        }
    }
    hideModal() {
        this.contact = {};
        this.isShowNewModal = false;
        this.isShowDeleteModal = false;
    }
    deleteRecord() {
        let tableCmp = this.template.querySelector("c-datatable");
        let selectedRow = tableCmp.returnSelectdRows();
        this.isLoading = true;
        deleteContacts({ contactIds: selectedRow }).then(data => {
            console.log('data:::', data);
            this.showNotification('Success', 'Deleted Successfully', 'success');
            this.isLoading = true;
            this.isShowDeleteModal = false;
            this.refreshView();
        }).catch(error => {
            console.log('error:::', error);
            this.showNotification('Error', error.body.message, 'error');
            this.isLoading = true;
        });
    }
    contactsToDelete = [];
    handleDelete() {
        this.contactsToDelete = [];
        let tableCmp = this.template.querySelector("c-datatable");
        console.log('tableCmp:::', tableCmp)
        let selectedRow = tableCmp.returnSelectdRows();
        console.log('selectedRow:::', selectedRow)
        if (selectedRow && selectedRow.length > 0) {
            let doNotContinue = false
            selectedRow.forEach(recordId => {
                if (recordId == this.primaryContact.Id) {
                    doNotContinue = true;
                    this.showNotification('Error', 'You are not allowed to delete the Primary Contact.', 'error');
                }
            });

            if (!doNotContinue) {
                this.isLoading = true;
                getContactsToDelete({ contactIds: selectedRow }).then(data => {
                    console.log('data:::', data);
                    let result = JSON.parse(data);
                    this.contactsToDelete = result;
                    this.isShowDeleteModal = true;
                    this.isLoading = false;
                }).catch(error => {
                    console.log('error:::', error);
                    this.showNotification('Error', error.body.message, 'error');
                    this.isLoading = false;
                });
            }

        } else {
            this.showNotification('Error', 'Please select any contacts', 'error');
        }
    }
    changedIndex = [];
    handleFieldUpdate(event){
        console.log('event:::',event.detail.index);
        if(this.changedIndex.indexOf(event.detail.index) == -1){
            this.changedIndex.push(event.detail.index);
        }
    }
    handleSave() {
        let tableCmp = this.template.querySelector("c-datatable");
        if (tableCmp.records && tableCmp.records.length > 0) {
            console.log(this.primaryContact);
            let primaryContactEmail = this.primaryContact.Email ? this.primaryContact.Email : '';
            let primaryContactPhone = this.primaryContact.Phone ? this.primaryContact.Phone : '';
            let doNotContinue = false;
            let isRoleEmpty = false;
            console.log('changedIndexes:::',this.changedIndex);
            tableCmp.records.forEach((record,index) => {
                if(this.changedIndex.indexOf(index) != -1){
                    if (record.Id == this.primaryContact.Id) {
                        let Email = record.Email ? record.Email : '';
                        let Phone = record.Phone ? record.Phone : '';
                        if (Phone != primaryContactPhone || Email != primaryContactEmail) {
                            doNotContinue = true;
                            this.showNotification('Error', 'You are not allowed to update the Email and Phone number for the Primary Contact. Please reach out to email address', 'error');
                        }
                    }
                    if(record.Roles__c == undefined || record.Roles__c == ''){
                        doNotContinue = true;
                        this.showNotification('Error', 'Role is required to update the records.', 'error');
                    }
                    if(record.Email == undefined || record.Email == ''){
                        doNotContinue = true;
                        this.showNotification('Error', 'Email is required to update the records.', 'error');
                    }
                    if(record.FirstName == undefined || record.FirstName == ''){
                        doNotContinue = true;
                        this.showNotification('Error', 'First Name is required to update the records.', 'error');
                    }
                    if(record.LastName == undefined || record.LastName == ''){
                        doNotContinue = true;
                        this.showNotification('Error', 'Last Name is required to update the records.', 'error');
                    }
                }
                /*if(record.Title == undefined || record.Title == ''){
                    doNotContinue = true;
                    this.showNotification('Error', 'Job Title is required for all Contacts listed below, please update the Title and click Save.', 'error');
                }*/
            });
            if (!doNotContinue) {
                this.isLoading = true;
                updateContacts({ contacts: JSON.stringify(tableCmp.records) }).then(data => {
                    console.log('data:::', data);
                    this.showNotification('Success', 'Updated Successfully', 'success');
                    this.refreshView();
                    this.isLoading = false;
                }).catch(error => {
                    console.log('error:::', error);
                    this.showNotification('Error', error.body.message, 'error');
                    this.isLoading = false;
                });
            }

        }
    }
    newContact = { AccountId: '' };
    handleChange(event) {
        let name = event.target.name;
        let value = event.target.value;
        this.newContact[name] = value;
    }
    handleSelection(event) {
        let selectedoptions = event.detail.selectedoptions;
        console.log('selectedoptions:::', selectedoptions);
        this.newContact['Roles__c'] = selectedoptions.join(";");
        console.log('newContact:::', this.newContact);
    }
    create() {
        let allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        let comboboxValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        let valid = this.template.querySelector('c-multi-select-picklist').isValid();

        if (allValid && comboboxValid && valid) {
            this.isLoading = true;
            createContact({ contactStr: JSON.stringify(this.newContact) }).then(data => {
                this.showNotification('Success', 'Created Successfully', 'success');
                this.refreshView();
                this.isLoading = false;
                this.isShowNewModal = false;
            }).catch(error => {
                console.log('error:::', error);
                this.showNotification('Error', error.body.message, 'error');
                this.isLoading = false;
            });
        }
    }
    refreshView() {
        this.dispatchEvent(
            new CustomEvent('refresh')
        );
    }
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}