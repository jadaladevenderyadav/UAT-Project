import { LightningElement, wire, track, api } from 'lwc';
import getHostelCustomMetadataValue from '@salesforce/apex/revaSWCustomMetadataController.getHostelCustomMetadata'; 
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

import { createRecord } from 'lightning/uiRecordApi';
import CASE_OBJECT from '@salesforce/schema/Case';
//import CATEGORY_FIELD from "@salesforce/schema/Case.hed__Category__c";
//import SUB_CATEGORY_FIELD from "@salesforce/schema/Case.Sub_Category__c";
import PRIORITY_FIELD from "@salesforce/schema/Case.Priority";
import { getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';


export default class RevaHostelRegistration extends NavigationMixin(LightningElement) {
    @track hostelDescription;
    @track customMetadataValue;
    @track termsAccepted = false;
    @track currentUserContact = {};
    @track showUserDetails = false;
    @track preferredRoomSharing = '';
    @track selectedRoomSharing;
    @track currentPursuingYear;
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
    showHostelRegistrationPage = false;
    //@track hasExistingHostelRequest = false;

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
            this.roomAlloted = data;
        } else if (error) {
            console.error('Error fetching existing hostel request:', error);
        }
    }
   //********************************************** */
    redirectToRevaMealBooking() {
        // Set showRevaMealBooking to true to render the child component
        this.showRevaMealBooking = true;
        this.showExistingHostelRequest=false;
        //this.showRevaMealBooking = !this.showRevaMealBooking;

        // Optionally, navigate to the child component using NavigationMixin
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c-revaMealBooking'
            }
        });
    }

    


    // to show the hostel description from custom metatadata
    @wire(getHostelCustomMetadataValue)
    wiredCustomMetadataValue({ error, data }) {
        if (data) {
            this.customMetadataValue = data;
            this.hostelDescription = data[0].Reva_Hostel_Description__c;
            console.log('Custom Metadata Data:', data);
            console.log('Hostel Description:', this.hostelDescription);
            
        } else if (error) {
            console.error('Error fetching custom metadata value', error);
        }
    }
    
    get roomSharingOptions() {
        let options = [
            { label: '4 Sharing', value: '4' },
            { label: '3 Sharing', value: '3' },
            { label: '2 Sharing', value: '2' },
            { label: 'Single Occupant', value: '1' }
        ];
    
       /* if ((this.currentUserContact.CurrentPusuingYear === '1st Year') || (this.currentUserContact.Gender === 'Female') ) {
            options = options.filter(option => option.value !== '8 Sharing' && option.value !== '6 Sharing');
        }*/
        if (this.isPremium) {
            options = options.filter(option => option.value === '1' || option.value === '2' || option.value === '4');
        }
        if (this.StudentBelongsToFinalYear==true) {
            options = options.filter(option => option.value === '4');
        
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
        this.StudentBelongsToFinalYear = data.StudentBelongsToFinalYear;
        console.log("data.StudentBelongsToFinalYear", data.StudentBelongsToFinalYear);
       // this.hasExistingHostelRequest = data.roomAlloted !== null && data.roomAlloted !== undefined;
        console.log('STUDENT ROOM = ',data.roomAlloted);
        if(this.StudentBelongsToFinalYear== true){
            this.shouldShowPremiumCheckbox = false; //added on 27-12
            this.isFinalYear=true;
        }
        console.log('Current User Contact:', data);
        console.log('Current Pursuing Year:', this.currentPursuingYear); // Add this line
        console.log('StudentBelongsToFinalYear::::'+this.StudentBelongsToFinalYear);
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
    @wire(calculateHostelFee, { roomType: '$preferredRoomSharing', isPremium: '$isPremium',isFinalYear:'$isFinalYear' })
        wiredHostelFee({ data, error }) {
        if (data) {
            console.log('Data:', data);
           console.log('hostelfeeeee::::'+data.hostelFee);
            this.totalHostelFee = data.hostelFee != null ? data.hostelFee : 0;
            //this.totalHostelFee = data.hostelFee !== null && data.hostelFee !== undefined ? data.hostelFee : 0;
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
        //console.log('preferredRoomSharing::::::'+this.preferredRoomSharing);
        //console.log(typeof(this.preferredRoomSharing));
        
    }
    
    handleCheckboxChange(event) {
        this.termsAccepted = event.target.checked;
    }

    handlePremiumCheckboxChange(event) {
        this.isPremium = event.target.checked;
        // Uncheck the Non-Premium checkbox if Premium is checked
        if (this.isPremium) {
           // this.isNonPremium = false;
    
            // Show the fee variation message in a toast
            const feeVariationMessage = 'The fee for Premium rooms may vary. Please check the fee details.';
            this.showToast('Premium Room Fee Variation', feeVariationMessage, 'info');
        }
    }
    /*handleFinalYearStudentCheckboxChange(event){
        this.isFinalYear = event.target.checked;
    }*/

    handlePaymentTypeChange(event){
        this.selectPaymentType = event.detail.value;
        console.log('selectedPayment:'+this.selectPaymentType);
    }
    get isNextButtonDisabled() {
        return !this.isNextButtonEnabled();
    }

    get isRegisterButtonDisabled() {
        return !this.termsAccepted;
    }

    
    handleRegisterClick() {
        if (this.termsAccepted) {
            this.showAcknowledgeAndRegister = false;
            this.showHostelRegistrationPage = true;
        } else {
        }
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
                /*return createStudentFeeRecord({
                    hostelRequestId: this.currentUserContact.Id,
                    paymentType: this.selectPaymentType
                });*/
                this.createStudentFeeRecordImperative();
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
        // Assuming the Aura component URL is '/c/FEE_StudentPayment'
        //window.location.href = '/c/FEE_StudentPayment';
        window.location.href = '/StudentPortal/s/student-fee';
       
    }

    redirectToRevaHostelLeavesPage() {
        // Assuming the Aura component URL is '/c/FEE_StudentPayment'
        //window.location.href = '/c/FEE_StudentPayment';
        window.location.href = '/StudentPortal/s/reva-hostel-leave-request/REVA_Hostel_Leave_Request__c/Default';
       
    }
    redirectToRevaHostelCasePage() {
        // Assuming the Aura component URL is '/c/FEE_StudentPayment'
        //window.location.href = '/c/FEE_StudentPayment';
        //window.location.href = '/StudentPortal/s/case/Case/Default';
        window.location.href = '/StudentPortal/s/case/Case/Default';
       
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
    showFeeDetails=true;
    showHostelSelection;

    handleStepClick(event) {
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
    }
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
   
}