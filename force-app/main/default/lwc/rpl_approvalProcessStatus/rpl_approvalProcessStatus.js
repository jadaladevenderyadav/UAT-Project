import { LightningElement , track, wire, api} from 'lwc';
import getApprovalStatus from '@salesforce/apex/Rpl_DocumentUploadClass.getApprovalStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rpl_approvalProcessStatus extends LightningElement {

    @api recordId;
    registrationData;
    //isApprovalStatus= true;
    isApproved = false;
   columns = [
    { label: 'Name', fieldName: 'uppercaseName', type: 'text', sortable: true, cellAttributes: { class: 'slds-text-align_center bold-text larger-font uppercase-text', alignment:'center' } },
    { label: 'SRN', fieldName: 'Rpl_SRN__c', type: 'text', sortable: true, cellAttributes: { class: 'slds-text-align_center bold-text larger-font', alignment:'center' } },
    { label: 'Email', fieldName: 'email', type: 'email', sortable: true, cellAttributes: { class: 'slds-text-align_center bold-text larger-font' , alignment:'center'} },
    { label: 'Course Name', fieldName: 'Course_Name__c', type: 'text', sortable: true, cellAttributes: { class: 'slds-text-align_center bold-text larger-font', alignment:'center' } },
    { label: 'Status', fieldName: 'Rpl_Status__c', type: 'button', sortable: true, cellAttributes: { class: 'slds-text-align_center bold-text larger-font', alignment:'center' }, typeAttributes: 
        { 
            label: { fieldName: 'Rpl_Status__c' },
            variant: { fieldName: 'variant' },
            title: 'Click to view details'
        }
    },
    { label: 'Reason For Rejection', fieldName: 'Rpl_Reason_for_Documentation_Fail__c', type: 'text', sortable: true, wrapText :true, cellAttributes: { class: 'slds-text-align_center bold-text larger-font', alignment:'center' } },
];


    @wire(getApprovalStatus, {recordId : '$recordId'})
    wiredApprovalStatus({data, error}){
        if(data){
            console.log('Approval Status Data ' + JSON.stringify(data));
            this.registrationData = data.map(record => ({ ...record, variant: this.getStatusVariant(record.Rpl_Status__c) , uppercaseName: record.Name.toUpperCase(), email:record.Contact__r.Personal_Email__c}));
            console.log('Current Status ' + data.Rpl_Status__c);
            this.isApproved = (data[0].Rpl_Status__c === 'Registration Successfully') ? true : false;
            //this.isApprovalStatus = !this.isApproved;
        }else if(error){
            console.log(error);
        }
    }

    getStatusVariant(status) {
        switch (status) {
            case 'Document Validation Failed':
                return 'destructive';
            case 'Document Validation Pending':
                return 'neutral';
            case 'Registration Successful':
                return 'success';
            default:
                return 'neutral';
        }
    }

}