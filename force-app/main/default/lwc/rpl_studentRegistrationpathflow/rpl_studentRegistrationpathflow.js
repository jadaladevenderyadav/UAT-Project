import { LightningElement, track, api, wire } from 'lwc';
import fetchStudentRegDetailsfrom from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails'
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord, getFieldValue } from "lightning/uiRecordApi"
// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";

import renderPage from './rpl_studentRegistrationpathflow.html';
export default class Rpl_studentRegistrationpathflow extends LightningElement {
  @api studentregrecordid;
  contactId
  isApprovalSuccess = false;
  @track isStudentDetailsPage;
  @track is10thUploadDetailsPage;
  @track isGraduationPage;
  @track isResumeUploadComplete;
  recordId;
  @track studentRegform = {};
  isRegistrationComplete;
  @track currentStep;
  checkisRecord;
  isRecordUnderApprovalProcess = false;
  @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
  userec({ error, data }) {
    if (error) {
      this.error = error;
      console.error('Error', error);
    } else if (data) {
      this.contactId = data.fields[CONTACT_ID.fieldApiName].value;

      this.fetchStudentRegDetailsfrom1(this.contactId);
      console.log('ContactId bar', this.contactId);

      console.log('Data', data);
    }
  }

  fetchStudentRegDetailsfrom1(studentId) {
    console.log('ContactId, Inside the getContactDetails Bar' + studentId);
    fetchStudentRegDetailsfrom({ recordId: studentId })
      .then(result => {
        console.log('result Bar Status' + JSON.stringify(result));
        //Program_Name__c
        this.studentregrecordid = result[0].Id;
        this.studentRegform.Rpl_isStudentDetailsComplete__c = result[0].Rpl_isStudentDetailsComplete__c;
        this.studentRegform.Rpl_isTwelveUpload__c = result[0].Rpl_isTwelveUpload__c;
        this.studentRegform.IsTenUpload__c = result[0].IsTenUpload__c;
        this.studentRegform.RPL_IsGraduationComplete__c = result[0].RPL_IsGraduationComplete__c;
        this.studentRegform.isUnderStatus__c = result[0].isUnderStatus__c;
        this.studentRegform.Rpl_IsResumeUpload__c = result[0].Rpl_IsResumeUpload__c;
        this.studentRegform.Rpl_Is_Under_Approval_Process__c = result[0].Rpl_Is_Under_Approval_Process__c;
        this.isRecordUnderApprovalProcess = result[0].Rpl_Is_Under_Approval_Process__c;
        this.isApprovalSuccess = result[0].Rpl_Status__c === 'Registration Successfully' ? true : false;
        if(!this.isRecordUnderApprovalProcess){
          this.isStudentDetailsPage = true;
          this.currentStep = 'Student Details';
        }else{
          this.isRegistrationComplete = true;
          this.currentStep = 'Approval Status';

        }
        console.log('JSON Check Student Detials' + JSON.stringify(this.studentRegform), 'Id' + this.studentregrecordid);
        //this.checkforacondition();

        console.log('Json Stringfy' + JSON.stringify(this.studentRegform));
        //console.log('Client Name'+this.clientNameArr);
      })
      .catch(error => {
        console.log('INSIDE ERROR' + JSON.stringify(error));
      });
  }


  checkforacondition() {
    console.log('====================== Inside CheckForAcondition ==================');
    if (this.studentRegform.Rpl_isStudentDetailsComplete__c == false) {
      this.currentStep = 'Student Details';
      this.isStudentDetailsPage = true;
      this.isGraduationPage = false;
      this.is10thUploadDetailsPage = false;
      this.isRegistrationComplete = false;
      console.log('Check inside the student Reg form', this.isStudentDetailsPage);
    }
    else if (this.studentRegform.RPL_IsGraduationComplete__c == false) {
      console.log('this.RPL_IsGraduationComplete__c' + this.studentRegform.RPL_IsGraduationComplete__c);
      this.isStudentDetailsPage = false;
      this.is10thUploadDetailsPage = false;
      this.isGraduationPage = true;
      this.isRegistrationComplete = false;
      this.currentStep = 'Graduation Details';
    }
    else if (this.studentRegform.IsTenUpload__c == false || this.studentRegform.Rpl_isTwelveUpload__c == false) {
      console.log('check Inside the studentRegform');
      this.currentStep = 'File Upload Stage';
      this.isGraduationPage = false;
      this.is10thUploadDetailsPage = true;
      this.isRegistrationComplete = false;
    }
    else if (this.studentRegform.Rpl_IsResumeUpload__c == false) {
      this.currentStep = 'Resume Upload Stage';
      this.isGraduationPage = false;
      this.is10thUploadDetailsPage = false;
      this.isResumeUploadComplete = true;
      this.isRegistrationComplete = false;
    } else {
      this.currentStep = 'Student Registration Status';
      this.isGraduationPage = false;
      this.is10thUploadDetailsPage = false;
      this.isResumeUploadComplete = false;
      this.isRegistrationComplete = true;
    }
  }

  /*Method is used for conforming the StudentProcess*/
  handleStudentComplete(event) {
    this.isGraduationPage = true;
    this.currentStep = 'Graduation Details';
    this.isStudentDetailsPage = false;
    console.log('Check for the Student Complete', event.detail.message)
  }

  /*Method Handles the Graduation Complete*/
  handleGraduationComplete(event) {
     this.currentStep = 'Documents Upload Stage';
        this.is10thUploadDetailsPage = true;
         this.isStudentDetailsPage = false;
         this.isGraduationPage = false;
         this.isResumeUploadComplete = false;
         this.isRegistrationComplete = false;
  }

  /*Method Handles the Upload file complete */
  handlefileUploadDetail(event) {
    console.log('Check for the Graduation Complete', event.detail.message);
    this.is10thUploadDetailsPage = false;
    this.isResumeUploadComplete = true;
    this.currentStep = "Resume Upload Stage";
  }


  handlefileresumefileupload(event) {
    console.log('Check for the resume file Complete', event.detail.message);
    this.is10thUploadDetailsPage = false;
    this.isResumeUploadComplete = false;
    this.isRegistrationComplete = true;
    this.currentStep = "Student Registration Status";

  }
  handleDocumentUploadCompleted(){
    console.log('------------------------------------------------------------------');
    this.currentStep = 'Document / Information Status';
         this.isStudentDetailsPage = false;
         this.isGraduationPage = false;
         this.is10thUploadDetailsPage = false;
         this.isResumeUploadComplete = true;
         this.isRegistrationComplete = false;
  }
  /*Handle the previous page*/
  handlePreviousGraduatioPage(event) {
    console.log('Check for the Previous Page', event.detail.message);
    this.currentStep = 'Student Details';
    this.isGraduationPage = false;
    this.isStudentDetailsPage = true;
  }

    handleStepClick(event) {
     
     console.log('In  event .....');
     const selectedLabel = event.target.label;
     console.log(selectedLabel);
     console.log('In Approval Process ? ' + this.isRecordUnderApprovalProcess);
      if(!this.isRecordUnderApprovalProcess){
         switch (selectedLabel) {
       case 'Student Details':
        this.currentStep = 'Student Details';
         this.isStudentDetailsPage = true;
         this.isGraduationPage = false;
         this.is10thUploadDetailsPage = false;
         this.isResumeUploadComplete = false;
         this.isRegistrationComplete = false;
         break;
       case 'Graduation Details':
        this.currentStep = 'Graduation Details';
         this.isStudentDetailsPage = false;
         this.isGraduationPage = true;
         this.is10thUploadDetailsPage = false;
         this.isResumeUploadComplete = false;
         this.isRegistrationComplete = false;
         break;
      case 'Documents Upload Stage':
        this.currentStep = 'Documents Upload Stage';
           this.is10thUploadDetailsPage = true;
         this.isStudentDetailsPage = false;
         this.isGraduationPage = false;
         this.isResumeUploadComplete = false;
         this.isRegistrationComplete = false;
        break;
       case 'Document / Information Status':
        this.currentStep = 'Document / Information Status';
         this.isStudentDetailsPage = false;
         this.isGraduationPage = false;
         this.is10thUploadDetailsPage = false;
         this.isResumeUploadComplete = true;
         this.isRegistrationComplete = false;
         this.checkisRecord = true;
         break;
       case 'Approval Status':
        this.currentStep = 'Approval Status';
         this.isStudentDetailsPage = false;
         this.isGraduationPage = false;
         this.is10thUploadDetailsPage = false;
         this.isResumeUploadComplete = false;
         this.isRegistrationComplete = true;
         break;
       default:
         // Default actions if needed
         break;
     }
      }else{
        this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: "Your record is under Approval Process, You can't modify your data currently.",
                    variant: 'error'
                })
            );
      }
     // Perform specific actions based on the clicked step label
    
   } 

   handleApprovalSubmit(event){
            this.currentStep = 'Student Details';

      this.isStudentDetailsPage = true;
         this.isGraduationPage = false;
         this.is10thUploadDetailsPage = false;
         this.isResumeUploadComplete = false;
         this.isRegistrationComplete = false;
         location.reload();
   }
}