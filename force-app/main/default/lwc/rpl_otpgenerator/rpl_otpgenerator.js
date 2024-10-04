import { LightningElement, track ,wire,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchContactDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getContactDetails';
import updateOtpDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.updateTheOtpDetails';
/*Get Contact Details Based on the User Login*/
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
import getRevaPlacementDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getPlacementDetails';
/*Insert the Student Details*/
import insertDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.insertStudentRegDetails';

export default class OtpModal extends LightningElement {
    @api showModal = false;
    @track showVerifyModal = false;
    @track emailValue = '';
    @track otpValue = '';
    @track otpGenerator={};
    @track contactId;
    @track studentRegform ={};
    @track studentRegRecordId;
    @track minutes = 1; // Set the initial minutes
    @track seconds = 60; // Set the initial seconds
    @track isResendOTP = true;
    @track isSubmitOTP = false
    @track revaPlacementId;

    timerInterval;


    constructor(){
        super();
        this.getRevaPlacementDetails();
    }

    openModal() {
        this.showModal = true;
        this.startTimer();
    }

    renderedCallback(){
        if(this.minutes==0&&this.seconds==0){
            this.isResendOTP =false;
            this.emailReturnOtp ='';
        }
    }

    startTimer() {
        this.timerInterval = setInterval(() => {
            if (this.seconds > 0) {
                this.seconds--;
            } else {
                if (this.minutes > 0) {
                    this.minutes--;
                    this.seconds = 59;
                } else {
                    clearInterval(this.timerInterval);
                }
            }
        }, 1000);        
    }

    handleResendOtp() {
        // Add logic to resend OTP here
        this.minutes = 1; // Reset minutes
        this.seconds = 60; // Reset seconds
        clearInterval(this.timerInterval); // Clear the previous timer interval
        this.openVerifyModal()
    }

    closeModal() {
        this.showModal = false;
        clearInterval(this.timerInterval); // Clear the timer interval when modal is closed
    }
    
    /*Get Login User Id*/
  @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
  userec({ error, data }) {
    if (error) {
      this.error = error;
      console.error('Error', error);
    } else if (data) {
      this.contactId = data.fields[CONTACT_ID.fieldApiName].value;
      console.log('ContactId', this.contactId);
      this.getContactDetails(this.contactId);
      console.log('Data', data);
    }
  }

  getRevaPlacementDetails(){
     getRevaPlacementDetails()
     .then(result => {
       console.log('getRevaPlacementDetails Result *'+JSON.stringify(result));
       this.conIdList = result.conList;
       this.revaPlacementId = result.revaPlacementId;
     })
     .catch(error => {
         console.log('error'+JSON.stringify(error));
     });
}

  getContactDetails(contactId){
    console.log('ContactId, Inside the getContactDetails');
    fetchContactDetails({ contactId : contactId})
    .then(result => {
        console.log(result[0].Primary_Academic_Program__r.Rpl_Placement_Vertical_Head__c)
        console.log('result'+JSON.stringify(result));
        result.forEach(element => {
          this.studentRegform.Rpl_SRN__c = element.SRN_Number__c;
          this.studentRegform.Name = element.Name;
          this.studentRegform.Rpl_Gender__c = element.hed__Gender__c;
          this.studentRegform.Rpl_Date_of_Birth__c = element.Birthdate;
          this.studentRegform.Rpl_Contact_No__c = element.MobilePhone;
          this.studentRegform.Rpl_School__c = element.School_Name__c;
          this.otpGenerator.Personal_Email__c = element.Personal_Email__c;
          this.studentRegform.Contact__c = contactId;
          this.studentRegform.Rpl_Personal_Mail_ID__c =  element.Personal_Email__c;
          this.studentRegform.VH__c = element.Primary_Academic_Program__r.Rpl_Placement_Vertical_Head__c;
          //this.studentRegform.Course_Name__c = element.Program_Name__c;
          this.studentRegform.Course_Name__c = element.Primary_Academic_Program__r.Program_Type__c =="UG"?"UG":element.Program_Name__c;
        });
        console.log('result'+JSON.stringify(this.studentRegform));
        this.checkoffCourseName();
    })
    .catch(error => {
        console.log('error'+JSON.stringify(error));
    });
  }
  //B. Tech in Agriculture Engineering
  
  checkoffCourseName(){
    //console.log('courseName'+JSON.stringify(this.studentRegform.courseName));
    this.studentRegform.Rpl_Specialization_c__c =  this.studentRegform.Course_Name__c;
    if(this.studentRegform.Course_Name__c.includes('B. Tech')){
       this.studentRegform.Course_Name__c = 'BTech';
       // I need to add the specialization for particular Course Name
    }
    else if(this.studentRegform.Course_Name__c.includes('M. Tech') || this.studentRegform.Course_Name__c.includes('Master of Science')){
        this.studentRegform.Course_Name__c = 'MTech'
    }
    else if(this.studentRegform.Course_Name__c.includes('Master of Business Administration')||this.studentRegform.Course_Name__c.includes('MBA')){
        this.studentRegform.Course_Name__c = 'MBA'
    }
    else if(this.studentRegform.Course_Name__c.includes('UG')){
        this.studentRegform.Course_Name__c = 'UG'
    }
}

connectedCallback() {
        // Assume you receive the email from backend, and it's stored in a variable called 'emailFromBackend'
        const emailFromBackend = 'example@example.com';
        this.emailValue = emailFromBackend;
    }

    
    handleSuccessfulVerification() {
        console.log('otp'+this.otpValue);
        if(this.otpValue==''){
            const evt = new ShowToastEvent({
                title: 'Warning!',
                message: 'Please enter the OTP Number.',
                variant: 'Error'
            });
            this.dispatchEvent(evt);
            return '';
        }
         if(this.emailReturnOtp===this.otpValue){
            console.log('inside handle input change');
            this.studentRegform.Rpl_IsOtpVerified__c = true;
            this.insertheStudentField();
            this.showVerifyModal = false;
             this.showModal= false;
            const evt = new ShowToastEvent({
                title: 'Success!',
                message: 'Verification successful.',
                variant: 'success'
            });
            this.dispatchEvent(evt);
        }else if(this.emailReturnOtp==''){
            const evt = new ShowToastEvent({
                title: 'Warning!',
                message: 'Invalid OTP Number',
                variant: 'Error'
            });
            this.dispatchEvent(evt);
        }else{
            const evt = new ShowToastEvent({
                title: 'Warning!',
                message: 'Please verify the OTP Number',
                variant: 'Error'
            });
            this.dispatchEvent(evt);
        }
       
        // Close the verification modal if needed
        
        this.otpValue='';
    }

   insertheStudentField(){
        this.studentRegform.Reva_Placement__c = this.revaPlacementId;
        insertDetails({stdRegDetails:this.studentRegform})
        .then(result => {
        console.log('result student registration id '+result);
        this.studentRegRecordId = result;
        this.handleStudentRegistration(result);
        this.isSaveTrue = false;
        this.studentRegform={};
        })
        .catch(error => {
            console.log('error**********88'+JSON.stringify(error));
        });
   }
    openModal() {
        this.showModal = true;
    }

   handleClose(){
    this.showModal = false;
    this.showVerifyModal = false;
    this.studentRegRecordId = false;
    this.communicateParentStudentButton();
    console.log('checkcommunicationParentButton');
   }



   handleEmailValue(event){
        
       let email = event.target.value;
       this.otpGenerator.Personal_Email__c = email;
   }

    openVerifyModal() {
         console.log('Personal  Email Veriry'+ this.otpGenerator.Personal_Email__c );
        this.startTimer();
        updateOtpDetails({personEmailId:this.otpGenerator.Personal_Email__c})
        .then(result => {
            console.log('result'+result);
            if(result!=null){
                this.showVerifyModal = true;
                this.emailReturnOtp = result;
            }
            
        })
        .catch(error => {
            this.showVerifyModal = false;
            console.log('error'+JSON.stringify(error));
        });
      
    }

    closeVerifyModal() {
        this.showVerifyModal = false;
        this.showModal= false;
    }

    handleInputOtpChange(event) {
        this.otpValue = event.target.value;
       
    }

    validateOtp() {
        return /^\d{4}$/.test(this.otpValue);
    }

    handleStudentRegistration(studentId){
        console.log('studentId'+studentId);
        //this.template.querySelector('c-rpl_-student-registration-form').fetchStudentRegDetailsfrom1(studentId);
    }

    studentRegistrationButton(event){
            console.log('studentRegistrationButton'+event.detail);
    }

    communicateParentStudentButton() {
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("changeisbutton", {
          detail: true
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }


   
    
}