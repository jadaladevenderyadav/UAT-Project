import { LightningElement, track, api, wire } from 'lwc';
import fetchStudentRegDetailsfrom from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails'
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
import getPlacementDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getPlacementDetails';
import Fill_Basic_Detail_Right_Column_Text from '@salesforce/label/c.RPL_Fill_Basic_Detail_Right_Column_Text_For_Student_Portal';
import Placement_Registration_Text from '@salesforce/label/c.RPL_Placement_Registration_Text_For_Student_Portal';
import RPL_Placement_Portal_Header_Paragraph from '@salesforce/label/c.RPL_Placement_Portal_Header_Paragraph';

// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";
import Static_Resources from '@salesforce/resourceUrl/RPL_Static_Resources';
const imageSources = {
    BW: {
        1: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/1.png',
        2: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/2.png',
        3: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/3.png',
        4: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/4.png',
        5: Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/5.png',
    },
    Orange: {
        1: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/1.png',
        2: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/2.png',
        3: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/3.png',
        4: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/4.png',
        5: Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/5.png',
    }
};
export default class Rpl_RevaPlacement extends LightningElement {
    @track currentStep = 1;
    @track stepNumber = 1;
    isSpinner;
    isStudentBasicDetailsSaveBtnDisabled = false;
    registerYourselfLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/1.png';
    verifyEmailOrSmsLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/2.png'
    fillBasicDetailsLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/3.png'
    educationDetailsLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/4.png'
    approvalStatusLogoBW = Static_Resources + '/Reva_Placement_Static_Resources/Icons/B&W/5.png'
    registerYourselfLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/1.png';
    verifyEmailOrSmsLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/2.png';
    fillBasicDetailsLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/3.png';
    educationDetailsLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/4.png';
    approvalStatusLogoOrange = Static_Resources + '/Reva_Placement_Static_Resources/Icons/Orange/5.png';
    svgImage = Static_Resources + '/Reva_Placement_Static_Resources/Icons/svgImage.png';
    @api studentregrecordid;
    wiredData;
    contactId;
    isApprovalSuccess;
    isFirstStep;
    isThirdStep;
    isSecondStep;
    isFourthStep;
    isFifthStep;
    isRecordUnderApprovalProcess;
    isThirdStepEventTriggered;
    isOtpVerified;
    wiredContact;
    keyForWire=1;
    isPlacementRegistrationStarted = false;
    alreayChecked = false;
    placementRegistrationText = Placement_Registration_Text;
    fillBasicDetailsRightColText  = Fill_Basic_Detail_Right_Column_Text;
    headerText = RPL_Placement_Portal_Header_Paragraph;

    @track studentRegDetails = {} // this variable is used for storing the student reg details
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CONTACT_ID]
    })
    userec(result) {
        
        this.wiredContact = result;
        if (result.error) {
            this.error =result.error;
            console.error('Error', result.error);
             this.isSpinner = false;
        } else if (result.data) {
            this.contactId = result.data.fields[CONTACT_ID.fieldApiName].value;
           
        }
    }

    async getPlacementDetails(){
        getPlacementDetails({contactId: this.contactId})
        .then(res => {
            this.isPlacementRegistrationStarted  = res && res.isPreOrFinalYear ? res.isPreOrFinalYear : false;
            if(this.isPlacementRegistrationStarted && !this.alreayChecked){
                this.keyForWire ++;
            }
            this.alreayChecked =true;
        })
        .catch(error => {
            this.isSpinner = false;
            const event = new ShowToastEvent({
                title : 'Error when processing ',
                message : error.body.message
            })
            this.dispatchEvent(event);
            return false;
        })
    }

    connectedCallback(){
        this.isSpinner = true;
    }

    updateStyles() {
        let iconStep = 1;
        let textStep = 2;
        let progressStep = 3;

        for (let i = 1; i <= 5; i++) {
            const icon = this.template.querySelector(`.div${iconStep}  img`);
            const text = this.template.querySelector(`.div${textStep} `);
            const progress = this.template.querySelector(`.div${progressStep}`);

            if (i < this.currentStep) {
                // Step completed
                icon.src = imageSources.BW[i];
                text.style.color = 'black';
                progress.style.backgroundColor = '#19a734';
            } else if (i === this.currentStep) {
                // Current step
                icon.src = imageSources.Orange[i];
                text.style.color = '#f57f26';
                progress.style.backgroundColor = '#f57f26';
            } else {
                // Upcoming steps
                icon.src = imageSources.BW[i];
                text.style.color = 'black';
                progress.style.backgroundColor = '#6F6F6F';
            }
            iconStep += 3;
            textStep += 3;
            progressStep += 3;
        }
    }

    handleOtpVerified() {
        this.showStepThree();
        this.keyForWire++;

    }
    @wire(fetchStudentRegDetailsfrom, {recordId: '$contactId', key:'$keyForWire'})
    async wiredStudentRecord(result){

        if(this.contactId){
            const isPlacementCreated = await this.getPlacementDetails();
        }
       
        this.isSpinner = true;
        this.wiredData = result;
        if(result.data && this.isPlacementRegistrationStarted){
              if (result.data.length > 0) {
                    this.isOtpVerified = true;
                    //Program_Name__c
                    this.studentregrecordid = result.data[0].Id;
                    if(this.isThirdStepEventTriggered){
                        this.isThirdStepEventTriggered = false;
                        this.showStepFour();
                        this.isSpinner = false;
                        return;
                    }
                    this.isStudentBasicDetailsSaveBtnDisabled = result.data[0].Rpl_Is_Student_Details_Verified__c;
                    this.isRecordUnderApprovalProcess = result.data[0].Rpl_Is_Under_Approval_Process__c;
                    this.isApprovalSuccess = result.data[0].Rpl_Status__c === 'Registration Successfully' ? true : false;
                    if(this.isApprovalSuccess){
                         this.isSpinner = false;
                        return;
                    } 
                    if (!this.isRecordUnderApprovalProcess) {
                       this.showStepThree();
                    } else {
                        this.showStepFive();
                    }
                }else{
                    this.showStepOne();
                }
        }else if(result.error){
        }
        this.isSpinner = false;
    }

    handleBasicDetailsCompleted(event) {
        this.isThirdStepEventTriggered = true;
        this.keyForWire ++;
    }



    handleDocumentUploadCompleted() {
        this.showStepFour();
    }

    handleStepClick(event) {
        const stepNumber = event.target.dataset.stepNumber;
        this.currentStep = parseInt(stepNumber);
        const selectedLabel = event.target.label;
       
       
        switch (stepNumber) {
            case '1':
                if(this.isOtpVerified){
                    this.showErrorToastMessage('Already Registered', 'You have already registered for placement');
                    break;
                }
                if(this.isRecordUnderApprovalProcess){
                    this.showErrorToastMessage('Record Under Review', 'We appreciate your submission. However, your record is currently under review, and editing is temporarily disabled. Thank you for your understanding.');
                    break;
                }
                this.showStepOne();
                break;
            case '2':
                 if(this.isOtpVerified){
                    this.showErrorToastMessage('Already Verified', 'You have already verified your email and mobile number');
                    break;
                }
                if(this.isRecordUnderApprovalProcess){
                    this.showErrorToastMessage('Record Under Review', 'We appreciate your submission. However, your record is currently under review, and editing is temporarily disabled. Thank you for your understanding.');
                    break;
                }
                 if(this.isOtpVerified){
                    this.showStepTwo();
                    break;
                }
                this.showErrorToastMessage('Please Do Register For Placement' , 'Please Do Register For Placement Before Verifying OTP');               
                break;
            case '3':
                 if(this.isRecordUnderApprovalProcess){
                    this.showErrorToastMessage('Record Under Review', 'We appreciate your submission. However, your record is currently under review, and editing is temporarily disabled. Thank you for your understanding.');
                    break;
                }
                 if(this.isOtpVerified){
                    this.showStepThree();
                    break;
                }
                    this.showErrorToastMessage('Please Do Register For Placement' , 'Please Do Register For Placement Before Filling Out Basic Details');
                
                break;
            case '4':
                 if(this.isRecordUnderApprovalProcess){
                    this.showErrorToastMessage('Record Under Review', 'We appreciate your submission. However, your record is currently under review, and editing is temporarily disabled. Thank you for your understanding.');
                    break;
                }
                if(this.isOtpVerified){
                    this.showStepFour();
                    break;
                }
                this.showErrorToastMessage('Please Do Register For Placement' , 'Please Do Register For Placement Before Uploading Document');
                
                break;
            case '5':
                if(this.isOtpVerified){
                    this.showStepFive();
                    break;
                }
                    this.showErrorToastMessage('Please Do Register For Placement' , 'Please Do Register For Placement Before Submitting For Approval');
                
                break;
            default:
                // Default actions if needed
                break;
             
        }
    }

    showStepOne() {
        this.currentStep = 1;
        this.updateStyles()
        this.isFirstStep = true;
        this.isSecondStep = false;
        this.isThirdStep = false;
        this.isFourthStep = false;
        this.isFifthStep = false;
    }

    showStepTwo() {
        this.currentStep = 2;
        this.updateStyles()
        this.isFirstStep = false;
        this.isSecondStep = true;
        this.isThirdStep = false;
        this.isFourthStep = false;
        this.isFifthStep = false;
    }

    showStepThree() {
        this.currentStep = 3;
        this.updateStyles()
        this.isFirstStep = false;
        this.isSecondStep = false;
        this.isFourthStep = false;
        this.isFifthStep = false;
        this.isThirdStep = true;
    }

    showStepFour() {
        this.currentStep = 4;
        this.updateStyles()
        this.isFirstStep = false;
        this.isSecondStep = false;
        this.isThirdStep = false;
        this.isFourthStep = true;
        this.isFifthStep = false;
    }

    showStepFive() {
        this.currentStep = 5;
        this.updateStyles()
        this.isFirstStep = false;
        this.isSecondStep = false;
        this.isThirdStep = false;
        this.isFourthStep = false;
        this.isFifthStep = true;
    }
    handleApprovalSubmit(event) {
        this.showStepOne();
        location.reload();
    }

    showErrorToastMessage(title, message) {
        const evnt = new ShowToastEvent({
                message,
                variant: 'destructive',
                title,
            }
        )
        this.dispatchEvent(evnt);
    }

    handlestudentselfregister(event) {
        this.studentRegDetails = event.detail.message;
        this.showStepTwo();
    }


    handlerevaverifysms(event) {
        this.showStepThree();

    }
}