import { LightningElement, wire, track } from 'lwc';
import getHostelCustomMetadataValue from '@salesforce/apex/revaSWCustomMetadataController.getHostelCustomMetadata'; 
import  getCurrentNonTeachingContact  from '@salesforce/apex/RevaHostelRequestController.getCurrentNonTeachingContact';
import  revaHostelRoomAllotment  from '@salesforce/apex/RevaHostelRequestAndAllotment.RevaHostelRoomAllotment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExistingHostelRequest from '@salesforce/apex/RevaHostelRequestController.getExistingHostelRequest';

import checkHostelRequestExists from '@salesforce/apex/RevaHostelRequestController.checkHostelRequestExists';
import updateVacationDate from '@salesforce/apex/RevaHostelRequestController.updateVacationDate';
import REVAHostelImage from '@salesforce/resourceUrl/REVAHostelImage';


export default class RevaNonTeachingStaffQuartersRegistration extends LightningElement {
    @track hostelDescription;
    @track customMetadataValue;
    @track termsAccepted = false;
    @track currentUserContact = {};
    @track showUserDetails = false;
    @track preferredRoomSharing = '';
    @track selectedRoomSharing;
    @track isPremium = false;
    @track customSettingsData = [];
    @track showToasts = false;
    showRegistrationPage;
    @track totalHostelFee ;
    //@track existingHostelRequest = false;
    @track showCancelButton = false;
    @track joiningDate;
    @track showCancelConfirmation = false;
    @track existingHostelRequest;
    @track showEndDateInput = false;
    @track endDate;
    @track roomAlloted;
    @track roomAlloted = false;
    @track showRevaMealBooking = false;
    @track showVacatingDateModal = false;
    @track isShowModal = false;
    revaHostelImageUrl = REVAHostelImage;
    showAcknowledgeAndRegister = false;
    showHostelRegistrationPage = false;
    @track cancellationReason = '';
    get floorOptions() {
        return [{ label: '4', value: '4' },
        { label: '3', value: '3' },
        { label: '2', value: '2' },
        { label: '1', value: '1' }]
    }

   
    @wire(getHostelCustomMetadataValue)
    wiredCustomMetadataValue({ error, data }) {
    if (data && data.length > 0) {
        this.customMetadataValue = data;
        this.hostelDescription = data[0].Reva_Hostel_Description__c;
        console.log('Custom Metadata Data:', data);
        console.log('Hostel Description:', this.hostelDescription);
    } else if (error) {
        console.error('Error fetching custom metadata value', error);
    } else {
        // Handle the case where data is either null or an empty array
        console.error('No data received from the wire method');
    }
}

    
    get roomSharingOptions() {
        let options = [
             { label: '4 Sharing Extra Space', value: '4ExtraSpace' },
            { label: '4 Sharing', value: '4' },
            { label: '3 Sharing', value: '3' },
            { label: '2 Sharing', value: '2' }
        ];      
        if (this.currentUserContact.Gender === 'Female') {
            options = options.filter(option => option.value !== '8' && option.value !== '6' && 
            option.value !== '2' && option.value !== '4ExtraSpace');
        }
        if (this.currentUserContact.Gender === 'Male') {
            options = options.filter(option => option.value !== '8' && option.value !== '6' && 
            option.value !== '1' );
        }
        if(this.isPremium && this.currentUserContact.Gender === 'Female'){
            options = options.filter(option => option.value === '1' || option.value === '4');
        };
        if(this.isPremium && this.currentUserContact.Gender === 'Male'){
            options = options.filter(option => option.value === '2' || option.value === '4');
        };
        return options;
    }
    
    // for current user contact details
    @wire(getCurrentNonTeachingContact)
    wiredCurrentUserContact({ error, data }) {
    if (data) {
        this.currentUserContact = data;
       
        console.log('Current User Contact:', data);
        /***added om 28082024 */
        /*if(data.Gender  == 'Male'){
            this.Checkgender = 'Boys'
            console.log('Checkgende::r', this.Checkgender);
        } if(data.Gender == 'Female'){
           this.Checkgender= 'Girls'
           console.log('Checkgende::r', this.Checkgender);
        }*/
        /**************/
    } else if (error) {
        console.error('Error fetching current user contact', error);
    }
}

@wire(getExistingHostelRequest)
wiredExistingHostelRequest({ error, data }) {
    if (data) {
        console.log("data1", data);
         if (data.length === 0) {
            this.showAcknowledgeAndRegister = true;
            return;
        }

        if (data.length > 0 && data[0]) {
            this.existingHostelRequest = data[0];
            console.log('this.existingHostelRequest', JSON.stringify(this.existingHostelRequest));

            this.showCancelButton = data[0].Room_Number__c && data[0].Status__c === 'Approved';
        } 

    } else if (error) {
        console.error('Error fetching existing hostel request', error);
    }
}

    
    // Add a method to handle preferred room sharing value selection
    handlePreferredRoomSharingChange(event) {
        this.preferredRoomSharing = event.detail.value;
        console.log('preferredRoomSharing::::::'+this.preferredRoomSharing);
    }

    handleCheckboxChange(event) {
        this.termsAccepted = event.target.checked;
    }

    get isRegisterButtonDisabled() {
        return !this.preferredRoomSharing 
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

    handleRegisterClick() {
        
           /* this.showUserDetails = true;
            this.customMetadataValue=false;
            this.checkExistingHostelRequests();
            this.existingHostelRequest =false;*/
            this.showAcknowledgeAndRegister = false;
            this.showHostelRegistrationPage = true;
            this.showRegistrationPage = true;
            console.log('this.showUserDetails============'+showUserDetails);
        
    }
    checkExistingHostelRequests() {
        // Call your Apex method to check if the logged-in user has existing hostel requests
        checkHostelRequestExists()
            .then(result => {
                // Set the existingHostelRequest property based on the result
               // this.existingHostelRequest = result;
                // Show user details if there are no existing records
                this.showUserDetails = !this.existingHostelRequest;
                this.showUserDetails = true;
            })
            .catch(error => {
                console.error('Error checking existing hostel requests:', error);
            });
    }
    handleCancelClick() {
        // Show the cancellation confirmation modal
        this.showCancelConfirmation = true;
    }
    showModalBox() {
        this.isShowModal = true;
    }

    // Method to hide the modal box
    closeModal() {
       // this.isShowModal = false;
        this.showEndDateInput=false;
    }
    // Method to handle cancellation confirmation
    handleCancelYesClick() {
        
        this.showCancelConfirmation = false;
        this.showEndDateInput = true;
        this.showVacatingDateModal = true;
    }

    // Method to handle cancellation denial
    handleCancelNoClick() {
        
        this.showCancelConfirmation = false;
        this.showEndDateInput = false;
    }
    handleEndDateChange(event) {
        // Get the selected end date value
        const selectedDate = new Date(event.target.value);

        // Get today's date
        const today = new Date();

        // Check if the selected date is prior to today's date
        if (selectedDate < today) {
            // Display an error message or prevent further action
            // For example, you can display a toast message
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'End date cannot be prior to today\'s date.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);

            // Reset the end date value
            this.endDate = null;
        } else {
            // Update the end date
            this.endDate = event.target.value;
        }
    }
    
   handleCancellationReasonChange(event) {
        this.cancellationReason = event.target.value;
    }

    
    handleSubmitEvent(event) {
        console.log('User Id:', this.currentUserContact.Id);
        console.log('Occupancy:', this.preferredRoomSharing.split(' ')[0]);
    
        revaHostelRoomAllotment({
            requestForId: this.currentUserContact.Id,
            occupancy: this.preferredRoomSharing.split(' ')[0],
            isPremium: this.isPremium,
            joiningDate:this.joiningDate
        })
        .then(result => {
            console.log('Result of revaHostelRoomAllotment:', result);
    
            if (result && result.Status === 'Request Created!') {
                // Check if the response status indicates a new record creation
                this.showToast('Success', 'Request Submitted Successfully', 'success');
                location.reload();
            } else {
                // Existing record found or other status
                this.showToast('Warning', 'You have already submitted your request', 'warning');
            }
        })
        .catch(error => {
            this.showToast('Error', 'An error occurred while processing your request', 'error');
            console.error(error);
        });  
        
       // window.location.href = '/NonTeachingStaff/s/quartersfornonteachingstaff';
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

    handleSubmitVacating(event) {
        // Handle submission of end date
        if (this.endDate && this.cancellationReason) {
            updateVacationDate({ recordId: this.existingHostelRequest.Id, vacationDate: this.endDate, cancellationReason:this.cancellationReason })
                .then(result => {
                    // Handle success
                    this.showToast('Success', 'Vacation date updated successfully.', 'success');
                    this.closeModal();
                    location.reload();
                    // Optionally, reset any form fields or navigate to another page
                })
                .catch(error => {
                    // Handle error
                    this.showToast('Error', error.body.message, 'error');
                    this.closeModal();
                    console.log('error.body.message===>' + error.body.message);
                });
        } else {
            // Handle if end date is not selected
            this.showToast('Error', 'Please select an end date.', 'error');
        }
    }
    /************Newly added for joining date****************/
    handleJoiningDateChange(event) {
        
        const selectedDate = new Date(event.target.value);

        const currentDate = new Date();
        this.joiningDate = event.target.value;

        /*if (selectedDate <= currentDate) {
                const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Please select a future date for joining.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);

            this.joiningDate = null;
        } else {
           
            this.joiningDate = event.target.value;
        }*/
    }
    /************************/
    
    get isRoomAllotted() {
        return this.existingHostelRequest && this.existingHostelRequest.Status__c === 'Room Allotted';
      
    }

    get isHostelNotVacated() {
        console.log('HH::'+this.existingHostelRequest.Status__c);
        console.log("eeee", this.existingHostelRequest.Status__c !== 'Vacated' && this.existingHostelRequest.Status__c !== 'Approved' && this.existingHostelRequest.Status__c !== '' );
        return  this.existingHostelRequest.Status__c !== 'Vacated' && this.existingHostelRequest.Status__c !== 'Approved'  && this.existingHostelRequest.Status__c !== undefined && this.existingHostelRequest.Status__c !== 'Booked';
    }

    redirectToRevaMealBooking() {
        // Set showRevaMealBooking to true to render the child component
        this.showRevaMealBooking = true;

        // Optionally, navigate to the child component using NavigationMixin
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c-revaHostelUITesting'
            }
        });
    }
    
    redirectToRevaMealBooking(){
        window.location.href = '/NonTeachingStaff/s/meal-booking';
    }
    redirectToRevaHostelCasePage(){
        window.location.href = '/NonTeachingStaff/s/recordlist/Case';
    }
}