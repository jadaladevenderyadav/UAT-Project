import { LightningElement , track, wire, api} from 'lwc';
import getDocumentStatus from '@salesforce/apex/Rpl_DocumentUploadClass.getDocumentStatus';
import updateIsUnderApprovalProcess from '@salesforce/apex/Rpl_DocumentUploadClass.updateIsUnderApprovalProcess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Rpl_studentRegistrationFormStatus extends LightningElement {
    isSpinner = true;
    @api recordId;
    isSubmitDisabled = true;
    isCheckboxDisabled = false;
    acknowledgmentChecked = false;
    @track data = [
    { id: '1', documentName: 'Student General Information', statusLabel: null, apiName:'Rpl_isStudentDetailsComplete__c', variant:'brand' },
    { id: '2', documentName: 'School Education Details', statusLabel: null, apiName: 'Rpl_isStudentDetailsComplete__c', variant:'brand' },
    { id: '3', documentName: 'College Education Details', statusLabel: null, apiName: 'RPL_IsGraduationComplete__c', variant:'brand' },
    { id: '4', documentName: 'Tenth Marksheet', statusLabel: null, apiName : 'IsTenUpload__c', variant:'brand'},
    { id: '5', documentName: 'Twelveth / Diploma Marksheet', statusLabel: null , apiName : 'Rpl_isTwelveUpload__c', variant:'brand'},
    { id: '6', documentName: 'Resume Upload', statusLabel: null ,apiName: 'Rpl_IsResumeUpload__c',variant:'brand' }
];

@track modifiedData = [];

@wire(getDocumentStatus, { recordId: '$recordId' })
wiredDocumentStatus({ error, data }) {
    this.isSpinner = true;
    console.log('Inside wired method');
    if (data) {
        console.log('Incoming Data Status' + JSON.stringify(data));
        // Transform the data received from Apex to match the structure of your component
        this.modifiedData = this.data.map(row => {
            const apiName = row.apiName;
            const matchingStatus = data[apiName];
            if(!matchingStatus){
                this.isCheckboxDisabled = true;
            }
           // const matchingStatus = data.find(status => status.DocumentName === row.documentName);
            return {
                id: row.id,
                documentName: row.documentName,
                statusLabel: matchingStatus ? 'Completed' : 'Pending', 
                variant : matchingStatus ? 'success' : 'brand',
            };
        });
        console.log('Wired data ' + JSON.stringify(this.modifiedData));
        this.isSpinner = false;
    } else if (error) {
        console.error('Error fetching document status:', error);

    }
}

handleAcknowledgmentChange(event){
    this.acknowledgmentChecked = event.target.checked;
    this.isSubmitDisabled = !this.acknowledgmentChecked;
}
handleSubmit(event){
    console.log('In Submit Handler');
    this.isSpinner = true;
    updateIsUnderApprovalProcess({recordId : this.recordId})
    .then(result => {
        const event = new CustomEvent('sendapproval', {
            bubbles: true, // Allow the event to bubble up the DOM hierarchy
        });
        this.dispatchEvent(event);
        this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Documents Sent For Verification Successfully!',
                    variant: 'success'
                })
            );
        this.isSpinner = false;
        location.reload();

    }).catch(error=>{
        console.log('Error When Submitting For Approval ' + JSON.stringify(error));
        this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'destructive'
                })
            );
        this.isSpinner = false;
    })
    console.log('Submit Clicked');
}


}