import { LightningElement, wire, track, api } from 'lwc';
//import getHostelCustomMetadataValue from '@salesforce/apex/revaSWCustomMetadataController.getHostelCustomMetadata'; 
import  getCurrentStudentContact  from '@salesforce/apex/RevaHostelRequestController.getCurrentStudentContact';
import  revaHostelRoomAllotment  from '@salesforce/apex/RevaHostelRequestAndAllotment.RevaHostelRoomAllotment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import calculateHostelFee from '@salesforce/apex/revaSWCustomMetadataController.calculateHostelFee'; 
import getAllRoomPrices from '@salesforce/apex/revaSWCustomMetadataController.getAllRoomPrices';
import createStudentFeeRecord from '@salesforce/apex/RevaHostelRequestAndAllotment.createStudentFeeRecord';
import  getExistingHostelRequest  from '@salesforce/apex/RevaHostelRequestController.getExistingHostelRequest';
import { NavigationMixin } from 'lightning/navigation';
import getExistingRoomAllotedHostelRequest from '@salesforce/apex/RevaHostelRequestController.getExistingRoomAllotedHostelRequest';
//import createHostelRequest from '@salesforce/apex/revaHostelRequestController.createHostelRequest';

//import createStudentHostelAttachment from '@salesforce/apex/RevaHostelRequestController.createStudentHostelAttachment';
//import fetchProgramEndDate from '@salesforce/apex/RevaHostelRequestController.fetchProgramEndDate';
//import updateStudentVacationDate from '@salesforce/apex/RevaHostelRequestController.updateStudentVacationDate';
// import updateStudentHostelRequest from '@salesforce/apex/RevaHostelRequestController.updateStudentHostelRequest';
import { createRecord } from 'lightning/uiRecordApi';
import CASE_OBJECT from '@salesforce/schema/Case';
//import CATEGORY_FIELD from "@salesforce/schema/Case.hed__Category__c";
//import SUB_CATEGORY_FIELD from "@salesforce/schema/Case.Sub_Category__c";
import PRIORITY_FIELD from "@salesforce/schema/Case.Priority";
import { getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import BOOKING_AMOUNT_PREMIUM from '@salesforce/label/c.WithPremium';
import BOOKING_AMOUNT_NON_PREMIUM from '@salesforce/label/c.WithoutPremium';
import RevaHostelCautionFeeAmount from '@salesforce/label/c.Reva_Hostel_Caution_Fee_Amount';
import RejoingRequest from '@salesforce/apex/RevaHostelRequestController.RejoingRequest';
import REVAHostelImage from '@salesforce/resourceUrl/REVAHostelImage';
import getLoggedInUserProfile from '@salesforce/apex/RevaHostelRequestController.getLoggedInUserProfile';
import getStudentFeeAndPaymentDetails from '@salesforce/apex/RevaHostelRequestAndAllotment.getStudentFeeAndPaymentDetails';
import ProvisionalFeePaid from '@salesforce/apex/RevaHostelRequestController.ProvisionalFeePaid';
import getStudentDetails from '@salesforce/apex/RevaMealBookingController.getStudentDetails';

export default class RevaHostelRegistration extends NavigationMixin(LightningElement) {
    @track hostelDescription;
    @track customMetadataValue;
    @track termsAccepted = false;
    @track currentUserContact = {};
    @track showUserDetails = false;
    @track preferredRoomSharing = '';
    @track selectedRoomSharing;
    @track currentPursuingYear;
    @track programBatch;
    @track isPremium = false;
    @track showToasts = false;
    showStudentDetails=true;
    @track totalHostelFee ;
    @track error;
    @track selectPaymentType;
    @track customSettingsData = [];
    @track StudentBelongsToFinalYear;
    @track hostelRequestId;
    isFinalYear=false;
    @track existingHostelRequest;
    showExistingHostelRequest;
    @track roomAlloted;
    showAcknowledgeAndRegister = false;
    @track isHostelRequest=true;
    @track shouldShowPremiumCheckbox = true;// added on 27-12
    @track showRevaMealBooking = false;
    @track showRevaLeaveRequest = false;
    showHostelRegistrationPage = false;
    @track roomAlloted = false;
    @track bookingAmount;
    @track showBookingAmount=false;
    @track cautionFee ;
    @track Gender;
    @track Checkgender;
    showPartialPayment = false;
    @track applicantPortal = false;
    @track showButton=false;
    @track provisonPaid =true;
    //@track hasExistingHostelRequest = false;

    premiumBookingAmount = BOOKING_AMOUNT_PREMIUM;
    nonPremiumBookingAmount = BOOKING_AMOUNT_NON_PREMIUM;
    Reva_Hostel_Caution_Fee_Amount = RevaHostelCautionFeeAmount;
    revaHostelImageUrl = REVAHostelImage;

    connectedCallback() {
        this.checkApplicantPortal();
    }

    // Method to check if the user is in the applicant portal
    checkApplicantPortal() {
        getLoggedInUserProfile().then((profile) => {
            if (profile === 'Applicant Profile') {
                this.applicantPortal = true;
            } else {
                this.applicantPortal = false;
            }
        }).catch((error) => {
            console.error('Error fetching user profile:', error);
        });
    }

    @wire(getStudentFeeAndPaymentDetails)
    wiredStudentDetails({ error, data }) {
        if (data) {
            const studentFee = data.studentFees;
            const studentPayment = data.studentPayments;
            if (studentFee && studentPayment) { 
                    this.showButton = true;
                
            }
        } else if (error) {
            console.error(error);
        }
    }

    @wire(ProvisionalFeePaid)
    ProvisionAdmissionFee({error,data}){
      if(data){
         this.provisonPaid = false;
        } else  {
            this.provisonPaid = true;
            }
      
    }

    get floorOptions() {
        return [{ label: '4', value: '4' },
        { label: '3', value: '3' },
        { label: '2', value: '2' },
        { label: '1', value: '1' }]
    }
    //********************************************** */
    @wire(getExistingHostelRequest)
    wiredExistingHostelRequest({ error, data }) {
    if (data) {
        if(data.length == 0){
            this.showAcknowledgeAndRegister = true;
            return;
        }
        this.showExistingHostelRequest = true;
        this.existingHostelRequest=data[0];
        this.isHostelRequest = false;
        
    } else if (error) {
        // this.isHostelRequest=true;
        console.error('Error fetching existing hostel request', error);
        }
    }


     @wire(getExistingRoomAllotedHostelRequest)
    wiredExistingRoomAllotedHostelRequest({ error, data }) {
        if (data) {
            // Room is allotted, show the buttons
           //this.roomAlloted = data;
            this.roomAlloted = data.Status__c === 'Room Allotted';
            this.existingHostelRequest = data;
            //this.showExistingHostelRequest=false;
        } else if (error) {
            console.error('Error fetching existing hostel request:', error);
        }
    }
   //********************************************** */
    redirectToRevaMealBooking() {
        this.showRevaMealBooking = true;
        this.showExistingHostelRequest=false;
   
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                // componentName: 'c-revaMealBooking'
                componentName: 'c-revaHostelUITesting'
            }
        });
    }

    
    get roomSharingOptions() {
        let options = [
            { label: '4 Sharing Extra Space', value: '4ExtraSpace' }, /* 4S this one only changed by srinivasu04072024 */
            { label: '4 Sharing', value: '4' }, 
            { label: '3 Sharing', value: '3' },
            { label: '2 Sharing', value: '2' },
            { label: 'Single Occupant', value: '1' }

        ];
    
        if (this.Checkgender == 'Girls') {
            options = options.filter(option => option.value !== '4ExtraSpace');  /* 4S this one only changed by srinivasu04072024 */
        
        }
        if (!this.isPremium) {
            // Exclude option 2 when not premium
            options = options.filter(option => option.value !== '2');
        } else {
            // Only include option 2 when premium
            options = options.filter(option => option.value === '2');
        }
        
    
        return options;
    }
    get paymentTypeOptions(){
        let options = [
            { label: 'Full Payment', value: 'Full Payment' },
            { label: 'Booking Amount', value: 'Partial Payment' }
        ];
        return options;
    }
    
    // for current user contact details
    @wire(getCurrentStudentContact)
    wiredCurrentUserContact({ error, data }) {
    if (data) {
        console.log('data ', data);
        this.currentUserContact = data;
        this.currentPursuingYear = data.CurrentPusuingYear;
        this.programBatch = data.ProgramBatch;
        console.log("this.programBatch"+ this.programBatch);
        console.log("data.ProgramBatch"+ data.ProgramBatch);
        this.StudentBelongsToFinalYear = data.StudentBelongsToFinalYear;
        console.log("data.StudentBelongsToFinalYear"+ data.StudentBelongsToFinalYear);
       // this.hasExistingHostelRequest = data.roomAlloted !== null && data.roomAlloted !== undefined;
        console.log('STUDENT ROOM = ',data.roomAlloted);
        if(this.StudentBelongsToFinalYear== true){
            this.shouldShowPremiumCheckbox = false; //added on 27-12
            this.isFinalYear=true;
        }
        console.log('Current User Contact:', data);       
        console.log("this.currentUserContactGender===>",data.Gender);
        console.log('Current Pursuing Year:', this.currentPursuingYear); // Add this line
        console.log('StudentBelongsToFinalYear::::'+this.StudentBelongsToFinalYear);

        if(data.Gender  == 'Male'){
            this.Checkgender = 'Boys'
            console.log('Checkgende::r', this.Checkgender);
        } if(data.Gender == 'Female'){
           this.Checkgender= 'Girls'
           console.log('Checkgende::r', this.Checkgender);
        }
     //   console.log('Checkgende::r', Checkgender);

    } else if (error) {
        console.error('Error fetching current user contact', error);
    }
}
    @wire(getAllRoomPrices) 
    wiredCustomSettingsData({ error, data }) {
        if (data) {
            this.customSettingsData = data;
        } else if (error) {
            console.error('Error fetching custom settings data', error);
        }
    }
    // Update this section in your LWC code
    @wire(calculateHostelFee, { roomType: '$preferredRoomSharing', isPremium: '$isPremium',isFinalYear:'$isFinalYear'})
        wiredHostelFee({ data, error }) {
        if (data) {
            console.log('Data:', data);
            //console.log('preferredRoomSharing====>',roomType);
            function formatNumberWithCommas(number) {
                return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            }
           console.log('hostelfeeeee::::'+data.hostelFee);
            this.totalHostelFee = formatNumberWithCommas(data.hostelFee != null ? data.hostelFee : 0);
            //this.totalHostelFee = data.hostelFee !== null && data.hostelFee !== undefined ? data.hostelFee : 0;
            this.cautionFee = formatNumberWithCommas(RevaHostelCautionFeeAmount != null ? RevaHostelCautionFeeAmount : 0);
            console.log('hfee===', this.totalHostelFee);
        } else if (error) {
            console.error('Error fetching hostel fee', error);
            this.error = error;
        }
    }

    
    createStudentFeeRecordImperative() {
        console.log('Current User:', this.currentUserContact);
        console.log('Hostel Request ID:', this.currentUserContact.Id);
        console.log('Payment Type:', this.selectPaymentType);
      
        createStudentFeeRecord({ contactId: this.currentUserContact.Id, paymentType: this.selectPaymentType, 
                                 totalFee: this.totalHostelFee,isPremium: this.isPremium,
                                 hostelRequestId: this.hostelRequestId})
            .then((result) => {
                // Handle success if needed
                this.result = result;
                console.log('Student Fee Record Created Successfully:', result);
            })
            .catch((error) => {
                // Handle error if needed
                console.error('Error creating student fee record', error);
            });
    }
     

     isNextButtonEnabled() {
        return this.preferredRoomSharing && this.selectPaymentType;
    }
    // Add a method to handle preferred room sharing value selection
    handlePreferredRoomSharingChange(event) {
        this.preferredRoomSharing = event.detail.value;
        console.log('this.preferredRoomSharing==>',this.preferredRoomSharing);
        function formatNumberWithCommas(number) {
            return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }
        this.cautionFee = formatNumberWithCommas(RevaHostelCautionFeeAmount != null ? RevaHostelCautionFeeAmount : 0);
        
        
      
        
    }
    
    /*handleCheckboxChange(event) {
        this.termsAccepted = event.target.checked;
    }*/

    handlePremiumCheckboxChange(event) {
        this.isPremium = event.target.checked;
        console.log('isPremium:', this.isPremium);
        this.updateBookingAmount();
        // Uncheck the Non-Premium checkbox if Premium is checked
        if (this.isPremium) {
           
            const feeVariationMessage = 'The fee for Premium rooms may vary. Please check the fee details.';
            this.showToast('Premium Room Fee Variation', feeVariationMessage, 'Error');
        }
    }
    

    handlePaymentTypeChange(event){
        this.selectPaymentType = event.detail.value;
        
        console.log('selectedPayment:'+this.selectPaymentType);
        if(this.selectPaymentType==='Partial Payment'){
            this.showBookingAmount=true;
        } else if(this.selectPaymentType==='Full Payment'){
            this.showBookingAmount=false;
        }
        this.updateBookingAmount();
    }
    get isNextButtonDisabled() {
        return !this.isNextButtonEnabled();
    }

  /*  get isRegisterButtonDisabled() {
        return !this.termsAccepted;
    }*/

    
    handleRegisterClick() {
       // if (this.termsAccepted) {
            this.showAcknowledgeAndRegister = false;
            this.showHostelRegistrationPage = true;
      //  } else {
     //   }
    }

    handleSubmitEvent(event) {
        console.log('User Id:', this.currentUserContact.Id);
        console.log('Occupancy:', this.preferredRoomSharing.split(' ')[0]);
    
        revaHostelRoomAllotment({
                requestForId: this.currentUserContact.Id,
                occupancy: this.preferredRoomSharing.split(' ')[0],
                isPremium: this.isPremium
            })
            .then((result) => {
                console.log('Result of revaHostelRoomAllotment:', result.Status);
                console.log('Result of revaHostelRoomAllotment:', result);
    
                if (result.Status == 'Request Created!') {
                    this.hostelRequestId = result.Id;
                    this.showHostelSelection = false;

                    // Wire methods automatically handle the promise resolution, no need for explicit handling
                    return calculateHostelFee({
                        roomType: this.preferredRoomSharing,
                        isPremium: this.isPremium,
                        isFinalYear:this.isFinalYear
                    });
                } else if (result.Status == 'Request already exists!') {
                    this.hostelRequestId = result.Id;
                    this.showToast('You have already submitted your request', 'You have already submitted your request', 'warning');
                    throw new Error('Already submitted');
                }
                else{
                    this.hostelRequestId = null;
                    this.showToast('Room not available of the requested category!', 'Room not available of the requested category!', 'Error');
                    throw new Error('Room Not Available');

                }
            })
            .then((feeResult) => {
                console.log('feersult:'+JSON.stringify(feeResult));
                // Update the totalHostelFee property with the calculated fee
                this.totalHostelFee = feeResult.hostelFee;
                console.log('Amount:', this.totalHostelFee);
                
                // Show the success toast
                this.showToast('Request Submitted Successfully', 'We have received your request', 'success');
                this.showToasts = true;
                this.showStudentDetails = false;
                
                this.createStudentFeeRecordImperative();
                //this.redirectToStudentFeePaymentComponent();
                /*adding the new condition for redirecting */
                 return getLoggedInUserProfile();

            })
            .then((userProfile) => {
                console.log('User Profile:', userProfile);
                if (userProfile === 'Applicant Profile') {
                    this.redirectToFeeLoggedInApplicantPayment();
                } else if (userProfile === 'Student Portal Profile' || userProfile === 'Student Profile') {
                    this.redirectToStudentFeePaymentComponent();
                } else {
                    console.error('Unknown user profile:', userProfile);
                }
            })
            .catch((error) => {
                this.error = error;
                console.log(JSON.parse(JSON.stringify(this.error)));
            });

           // this.wiredCreateStudentFeeRecord({});
    }
   
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);   
    }

    redirectToStudentFeePaymentComponent() {
        window.location.href = '/StudentPortal/s/student-fee';
    }

    redirectToFeeLoggedInApplicantPayment(){
           window.location.href = '/Admissions/s/?tabset-906eb=2';
        
    }
    
    redirectToRevaHostelLeavesPage() {    
       this[NavigationMixin.Navigate]({
        type: "standard__namedPage",
        attributes: {
            pageName: "revahostelleaverequestcreation"
        }
    });
    }

    redirectToRevaHostelCasePage() {
        
      //window.location.href = '/StudentPortal/s/case/Case/Default';
       this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Hostel_Support_Case_Request_List_View__c' 
            }
        });
   
    }

    // Create Case
    @track subject = '';
    @track description = '';

    @api objectApiName = CASE_OBJECT.objectApiName; // Change this to your desired object API name
    @api fieldApiName = 'Category__c'; // Change this to your desired field API name
    categoryValues = [];
    allSubCategories = [];
    activeSubCategories = [];
    urgency = [];
    @wire(getObjectInfo, {objectApiName:  'Case'}) caseInfo({data, error}) {
        console.log('objectApiName data',data);
        console.log('objectApiName error ',error);
    } caseObjectinfo;

    @wire(getPicklistValues, {
        recordTypeId: '0125j000000aQagAAE',
        fieldApiName: PRIORITY_FIELD
    }) 
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.urgencyValues = data.values;
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$caseObjectinfo.defaultRecordTypeId',
        fieldApiName: '$caseObjectinfo.fields.Category__c.apiName'
    }) 
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.categoryValues = data.values;
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }
    /*@wire(getPicklistValues, {
        recordTypeId: '0125j000000aQagAAE',
        fieldApiName: SUB_CATEGORY_FIELD
    }) */
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.allSubCategories = data.values;
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    handleDependentSubCategories(event) {
        let key = this.allSubCategories.controllerValues[event.target.value];

        this.activeSubCategories = this.allSubCategories.values.filter(opt => opt.validFor.includes(key));
    }

    handleCaseSubjectChange(event) {
        console.log(this.picklistValues);
        this.subject = event.target.value;
    }

    handleCaseDescriptionChange(event) {
        this.description = event.target.value;
    }

    async createCase() {
        const fields = {
            Subject: this.subject,
            Description: this.description,
            Status: 'New',
            Origin: 'Student Portal'
        };

        const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };

        try {
            await createRecord(recordInput);
            // Reset input fields after successful creation
            this.subject = '';
            this.description = '';
            // You can also add a success message or navigation logic here
        } catch (error) {
            console.error('Error creating case:', error.body.message);
            // Handle error, show error message, etc.
        }
    }
    //******************2003************//
    //showFeeDetails=true;
    showHostelSelection=true;

   /* handleRegisterClick(event) {
        const stepNumber = event.target.dataset.step;
        if(stepNumber == 1){
           this.showFeeDetails = true;
           this.showHostelSelection = false;
            this.updateStyles(stepNumber, 'tab');
 
        }else if(stepNumber ==2 ){
              this.showFeeDetails = false;
           this.showHostelSelection = true;
            this.updateStyles(stepNumber, 'tab');
        }
    }*/
       updateStyles(stepNumber, className) {
        const tabs = this.template.querySelectorAll(`.${className}`);
        tabs.forEach(tab => {
            const tabStepNumber = tab.dataset.step;
            if (tabStepNumber != stepNumber) {
                tab.style.backgroundColor = '#FEF3EA';
                tab.style.color = 'black';
            } else {
                tab.style.color = 'white';
                tab.style.backgroundColor = '#f07f07';
 
            }
        })
    }
    refreshPage() {
        // Reload the page
        window.location.reload();
    }
    get isHostelNotVacated() {
        console.log('HH::'+this.existingHostelRequest.Status__c);
        console.log("eeee", this.existingHostelRequest.Status__c !== 'Vacated' && this.existingHostelRequest.Status__c !== 'Booked' && this.existingHostelRequest.Status__c !== '' );
        return  this.existingHostelRequest.Status__c !== 'Vacated' && this.existingHostelRequest.Status__c !== 'Booked'  && this.existingHostelRequest.Status__c !== undefined;
    }
    
    
    
    updateBookingAmount() {
       if (this.selectPaymentType === 'Partial Payment') {
            function formatNumberWithCommas(number) {
                return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            }
            // Check if the premium checkbox is checked
            if (this.isPremium) {
                
                // Set the booking amount to the premium amount from the custom label
                this.bookingAmount = formatNumberWithCommas(BOOKING_AMOUNT_PREMIUM);
            } else {
                // Premium checkbox is not checked, set the booking amount to the non-premium amount
                this.bookingAmount = formatNumberWithCommas(BOOKING_AMOUNT_NON_PREMIUM);
            }
        } else {
            // If Full Payment or no payment type selected, set booking amount to null
            this.bookingAmount = null;
        }
    }
    


    /*rejoin funcationality */
    get isRejoinStatus() {
        return this.existingHostelRequest && this.existingHostelRequest.Status__c === 'Vacated';
    }

    /*vacating Approval Histroy functionlity  : Jadala Devender*/ 
    get isApprovedHistory(){
        return this.existingHostelRequest && (this.existingHostelRequest.Status__c === 'Vacated'||this.existingHostelRequest.Status__c === 'Vacating Initiated')                                    
    }
    

    handleRejoinClick() {
        this.dispatchEvent(new CustomEvent("clickback"));

        RejoingRequest({ recordId: this.recordId })
            .then(result => {
                // Handle success
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Rejoin request has been submitsd successfully!',
                        variant: 'success'
                    })
                );
                location.reload();
            })
            .catch(error => {
                // Handle error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    handlePartialPayClick() {
        this.showPartialPayment = true;
    }
    handleCloseModal() {
        this.showPartialPayment = false;
    }


 //////////////////////

 @track dueDays;
 @track pendingAmount;
 @track mealBookingAllowed = false;
 showBanner =false;
 

 @wire(getStudentDetails)
 wiredStudent({ error, data }) {
     if (data) {
         console.log('dataPendingAmount', data);
         this.dueDate = data[0].No_of_Days_Due__c;
         console.log('dueDate', this.dueDate);
         this.pendingAmount = data[0].Amount_Pending__c;
         console.log('pendingAmount', this.pendingAmount);
         this.checkMealBookingEligibility();
     } else if (error) {
         console.error(error);
     }
 }

 
 checkMealBookingEligibility() {
     this.canBookMeal = (this.dueDate > 30 && this.pendingAmount !== 0);
     console.log(" this.canBookMeal", this.canBookMeal);
 }

 handleMealBooking() {
     if (this.canBookMeal) {
         this.showToast('Meal Booking Restricted', 'You cannot book meals due to pending amount.', 'error');
     } else {
         this.redirectToRevaMealBooking();
     }
 }
 /*vacating Approval Histroy functionlity:- Jadala Devender*/ 
 handleVactingHistory(){
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'revahostelleavereqapprovalhistory' 
        },
        state: {
            recordId: this.existingHostelRequest.Id,
        }
    });

  }   
   



}