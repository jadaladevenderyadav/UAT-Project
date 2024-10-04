import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import getAllEligibleDrives from '@salesforce/apex/RPL_StudentRegisterDriveController.getAllEligibleDrives';
import getAttachmentContent from '@salesforce/apex/RPL_StudentRegisterDriveController.getAttachmentContent';
import updateIsApplied from '@salesforce/apex/RPL_StudentRegisterDriveController.updateIsApplied';
import LightningConfirm from 'lightning/confirm';
import generateAdmitCard from '@salesforce/apex/RPL_AdmitCardTemplateController.generateAdmitCard';

//import getStudentRegistrationId from '@salesforce/apex/RPL_StudentRegisterDriveController.getStudentRegistrationId';
export default class Rpl_eligiblePlacementDrives extends LightningElement {
//userId = USER_ID;
studentId;
data;
error;
contactId;
wiredEligibleDrives;
isDriveAvailable = false;
studentRegDriveId;
isResult;
isEligibleDrives = true;
isSpinner = false;
columns = [
    {
        label: 'Drive Name',
        fieldName: 'driveName',
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'driveName' },
            name: 'viewResult',
            title: 'View Result',
            variant: 'base', // Use 'base' variant for a plain text look
            disabled: false, // Enable the button
            value: 'viewResult', // The value to be passed to the onrowaction event
        },
        cellAttributes: {
            class: 'slds-text-link', // Add SLDS class for text-like styling
        },
    },
    { label: 'Company Name', fieldName: 'companyName' },
    { label: 'Application Start Date', fieldName: 'eventStartDate', type : 'date'},
    { label: 'Application End Date', fieldName: 'eventEndDate', type: 'date' },
    { label: 'Event Date', fieldName: 'eventDate', type: 'date-time' },
    {
        label: 'Apply',
        type: 'button',
        initialWidth: 135,
        cellAttributes:{
            alignment: 'center'
        },
        typeAttributes: {
            label: { fieldName: 'applyLabel'},
            name: 'apply',
            title: 'Click to Apply',
            disabled: { fieldName: 'isApplied' },
            value: 'apply',
            variant: {fieldName : 'variant'},
        },
    },
    {
        label: 'Download',
        type: 'button',
        initialWidth: 135,
        cellAttributes:{
            alignment: 'center'
        },
        typeAttributes: {
            label: 'Download',
            name: 'download',
            title: 'Click to Dowmload',
            disabled: { fieldName: 'isDownloadDisable' },
            value: 'download',
            variant: 'brand',
        },
    }
];

@wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
userec({ error, data }) {
    if (error) {
    this.error = error;
    console.error('Error', error);
    } else if (data) {
    this.contactId = data.fields[CONTACT_ID.fieldApiName].value;
    console.log('ContactId For ELIGIBLE PLACEMENT DRIVESss', this.contactId);
    console.log('Data', data);
    }
}

@wire(getAllEligibleDrives, ({ contactId: '$contactId' }))
fetchAllEligibleDrive(result){
    console.log('Inside fetchAllEligibleDrives');
    this.wiredEligibleDrives = result;
    if(result.data){
        console.log('Got Data!!' + JSON.stringify(result.data));
        this.data = result.data.map(drive => {

            let applyLabel = '';
            let isApplied = true; 
            let isDownloadDisable = true;
           
            if (drive.Rpl_IsApplied__c) {
                applyLabel = 'Applied';
                isApplied = true;
                isDownloadDisable = false;
            } else if (!drive.Rpl_IsApplied__c && drive.Rpl_Placement_Drive__r && drive.Rpl_Placement_Drive__r.Rpl_Event_End_Date__c) {
                // Check if Rpl_Event_End_Date__c is defined before accessing its properties
                if (new Date(drive.Rpl_Placement_Drive__r.Rpl_Event_Date__c) > new Date()) {
                    applyLabel = 'Apply';
                    isApplied = true;
                    isDownloadDisable = true;
                }
                else if (new Date(drive.Rpl_Placement_Drive__r.Rpl_Event_End_Date__c) < new Date()) {
                    applyLabel = 'Closed';
                    isApplied = true;
                    isDownloadDisable = true;
                }
                else {
                    applyLabel = 'Apply';
                    isApplied = false; 
                    isDownloadDisable = true;                   
                }
            } else {
                applyLabel = 'Apply';
                isApplied = false;
                isDownloadDisable = true;
            }

            //If the student is blocked then we disable the Apply button.
            isApplied = (drive.Rpl_Student_Registration__r.Rpl_Is_Blocked__c)? true : isApplied;
            applyLabel = (drive.Rpl_Student_Registration__r.Rpl_Is_Blocked__c)?'Blocked':applyLabel;

            return {
                id: drive.Id,
                studentRegId: drive.Rpl_Student_Registration__c,
                driveId: drive.Rpl_Placement_Drive__c,
                driveName: (drive.Rpl_Placement_Drive__r) ? drive.Rpl_Placement_Drive__r.Name : undefined,
                companyName: (drive.Rpl_Placement_Drive__r && drive.Rpl_Placement_Drive__r.Rpl_Company_Name__r) ? drive.Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name : undefined,
                eventStartDate: (drive.Rpl_Placement_Drive__r) ? drive.Rpl_Placement_Drive__r.Rpl_Event_Date__c : undefined,
                eventEndDate: (drive.Rpl_Placement_Drive__r) ? drive.Rpl_Placement_Drive__r.Rpl_Event_End_Date__c : undefined,
                isApplied : isApplied,
                //isApplied: drive.Rpl_IsApplied__c && (!drive.Rpl_IsApplied__c && drive.Rpl_Placement_Drive__r.Rpl_Event_End_Date__c < new Date()),
                //applyLabel: (drive.Rpl_IsApplied__c) ? 'Applied' : (!drive.Rpl_IsApplied__c && drive.Rpl_Placement_Drive__r.Rpl_Event_End_Date__c < new Date()) ? 'Closed' : 'Apply'
                applyLabel : applyLabel,
                universityEmailId : (drive.Rpl_Student_Registration__r && drive.Rpl_Student_Registration__r.Rpl_University_Mail_ID__c) ? drive.Rpl_Student_Registration__r.Rpl_University_Mail_ID__c : '',
                isDownloadDisable : isDownloadDisable,
                eventDate: (drive.Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c) ? new Intl.DateTimeFormat('en-US', {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                }).format(new Date(drive.Rpl_Placement_Drive__r.Rpl_Event_Date_Time__c)) : undefined,
               
            };
        });
        this.isDriveAvailable = (this.data.length > 0)?true:false;
        console.log('DATA FOUND : ' + JSON.stringify(this.data));
    }
    else if(result.error){  
        console.log('No Data');
        console.log(JSON.stringify(result.error));
        this.error= result.error;
    }
}
handleOnClickBack(event){
    this.isResult = false;
    this.isEligibleDrives = true;
}

handleRowAction(event){
    const row = event.detail.row;
    const action = event.detail.action;
    console.log(action.name);
    if(action.name === 'apply'){
        console.log('Apply');
        this.showConfirmModal(row);
    }
    else if(action.name === 'download'){
        console.log("Download");
        this.showConfirmDownloadModule(row);
    }
    else if(action.name === 'viewResult'){
        this.studentRegDriveId = row.id;
        this.isResult = true;
        this.isEligibleDrives = false;
    }
}
async showConfirmDownloadModule(row) {
    console.log(JSON.stringify(row));
    const result = await LightningConfirm.open({
        message: 'Are you sure you want to download admit card this drive?',
        variant: 'headerless',
        label: 'Download',
        header: 'Download Confirmation', // Optional header for the modal
        type: 'success', // Optional type (error, warning, info), affects the icon
    });
    if (result) {
        console.log('downloaddeedddd');
        this.getAttachmentContentFromStudentRegDrive(row.id);
       //this.updateIsAppliedCheckBox(row.id,  row.driveName);
       //this.generateAndSendAdmitCard(row.id, row.driveName, row.universityEmailId);
    } else {
        // User clicked Cancel, do nothing
    }
}

async showConfirmModal(row) {
    console.log(JSON.stringify(row));
    const result = await LightningConfirm.open({
        message: 'Are you sure you want to apply for this drive?',
        variant: 'headerless',
        label: 'Apply',
        header: 'Apply Confirmation', // Optional header for the modal
        type: 'warning', // Optional type (error, warning, info), affects the icon
    });
    if (result) {
       this.updateIsAppliedCheckBox(row.id,  row.driveName, row);
       
    } else {
        // User clicked Cancel, do nothing
    }
}
updateIsAppliedCheckBox(studentRegistrationDriveId, driveName, row){
    this.isSpinner= true;
    console.log(studentRegistrationDriveId);
    updateIsApplied({studentRegistrationDriveId : studentRegistrationDriveId})
    .then(result => {
        console.log(result);
        if(result === 'true'){      
            this.generateAndSendAdmitCard(row.id, row.driveName, row.universityEmailId);      
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Applied Successfully',
                    message: `You Have Been Applied For The Drive : ${driveName}`,
                    variant: 'success',
                    })
            )
            this.isSpinner= false;
            refreshApex(this.wiredEligibleDrives);
            
        }
        else{
            this.isSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Apply Failed',
                    message: `Your Application For The Drive : ${driveName} Was Failed`,
                    variant: 'warning',
                    })
            )
        }           
    })
    .catch(error =>{
        this.isSpinner = false;
        console.log(JSON.stringify(error));
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Apply Failed',
                message: error,
                variant: 'warning',
                })
        )
    })
}

generateAndSendAdmitCard(studentRegDriveId , driveName, universityEmailId){
    console.log("Inside generateAndSendAdmitCard");
    generateAdmitCard({studentRegDriveId : studentRegDriveId, universityEmailId:universityEmailId})
    .then(res => this.dispatchEvent(
        new ShowToastEvent({
            title: 'Admit Card Attached Successfully',
            message: `Your Admit Card Have Been Generated For The Drive : ${driveName} Successfully`,
            variant: 'success',
            })
    ))
    .catch(error => {
        console.log(JSON.stringify(error));
        console.log(error.body.message);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Admit Card Generation Failed',
                //message: error.body.message,
                variant: 'warning',
                })
        )
    })
}

getAttachmentContentFromStudentRegDrive(studentRegistrationDriveId){
    getAttachmentContent({studentRegistrationDriveId : studentRegistrationDriveId })
    .then(res => {
        if(res != 'false'){
            this.downloadPDF(res);
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No Admit Card To Download',
                    //message: error.body.message,
                    variant: 'warning',
                    })
            )
        }       
    })
    .catch(err => console.log(JSON.stringify(err)))
}

downloadPDF(pdfContent) {
    const blob = this.base64ToBlob(pdfContent);
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = 'AdmitCard.pdf';
    link.click();
}

base64ToBlob(base64) {
    const byteCharacters = atob(base64);
    const byteNumbers = new Array(byteCharacters.length);
    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    return new Blob([new Uint8Array(byteNumbers)], { type: 'application/pdf' });
}

}