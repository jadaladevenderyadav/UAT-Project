import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelLeave from '@salesforce/apex/RevaHostelLeaveRequestController.cancelLeave';
import hasStatusUpdated from '@salesforce/apex/RevaHostelLeaveRequestController.hasStatusUpdated';
import { getRecord } from 'lightning/uiRecordApi';
import getLeaveRequestWithContact from '@salesforce/apex/RevaHostelLeaveRequestController.getLeaveRequestWithContact';

const FIELDS = [
    'REVA_Hostel_Leave_Request__c.Status__c',
    'REVA_Hostel_Leave_Request__c.Start_Date_and_Time__c',
    'REVA_Hostel_Leave_Request__c.Id'
];

export default class RevaHostelLeaveRequestDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track isSaveButtonVisible = false;
    @track status;
    @track Startdate;
    @track checkday = true;
    @track parentName;
    @track parentPhoneNumber;
    @track showscanner = false;
    @track visibleScan =false ;
    @wire(getLeaveRequestWithContact, { recordId: '$recordId' })
    wiredLeaveRequest({ error, data }) {
        if (data) {
            this.status = data.Status;
            this.parentName = data.ParentName;
            this.parentPhoneNumber = data.ParentPhoneNumber;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                   // title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    leaveRequest({ error, data }) {
        if (data) {
            this.status = data.fields.Status__c.value;
            this.Startdate = new Date(data.fields.Start_Date_and_Time__c.value);
            this.bookingIdSelected = data.fields.Id.value;
            console.log('this.bookingIdSelected::::'+this.bookingIdSelected);
            console.log('this.bookingIdSelected::::'+this.status);
             if(this.status ==='Check Out' || this.status ==='Approved'){

            this.visibleScan = true;
             }
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                  //  title: 'Error : Status not available',
                    message: 'Failed to retrieve leave request status.',
                    variant: 'error'
                })
            );
        }
    }

    get isCancelButtonVisible() {
        const today = new Date();
        const startDate = new Date(this.Startdate);
        startDate.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);
        return this.status === 'Approved' && today < startDate;
    }


    get isCancelDiabled() {
        return this.status === 'Cancelled';
    }

    handleBackClick() {
         if (this.status === 'Leave Requested') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Cancellation is not allowed at this stage',
                    variant: 'error'
                })
            );
            return;
        }
        this.dispatchEvent(new CustomEvent("clickback"));

        cancelLeave({ recordId: this.recordId })
            .then(result => {
                // Handle success
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Leave request has been cancelled successfully!',
                        variant: 'success'
                    })
                );
                location.reload();
            })
            .catch(error => {
                // Handle error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Modifications are not allowed when the status is in the requested stage.',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    handleChange() {
         if (this.status !== 'Approved') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Modifications are not allowed at this satge',
                    variant: 'error'
                })
            );
            return;
        }
        this.isSaveButtonVisible = true;
    }

    handleSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record has been updated successfully!',
                variant: 'success'
            })
        );
         location.reload();
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Modifications are not allowed when the status is in the requested stage.',
                message: event.detail.message,
                variant: 'error'
            })
        );
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        //fields.Status__c = 'Submitted'; // Example of setting a field value programmatically
        //this.template.querySelector('lightning-record-edit-form').submit(fields);

        const startDate = new Date(fields.Start_Date_and_Time__c);
        const endDate = new Date(fields.End_Date_and_Time__c);
        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(today.getDate() + 1);

        const startDateWithoutTime = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
        const tomorrowWithoutTime = new Date(tomorrow.getFullYear(), tomorrow.getMonth(), tomorrow.getDate());

        if (startDateWithoutTime.getTime() < tomorrowWithoutTime.getTime()) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Start date should be from tomorrow.',
                    variant: 'error'
                })
            );
        } else if (endDate <= startDate) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'End date should not be before the start date.',
                    variant: 'error'
                })
            );
        } else {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }
    handleScan(){
        this.showscanner =true;
    }

      closeModal() {
        this.showscanner = false;
    }

  //////////  
intervalId;

    connectedCallback() {
            this.startStatusCheck();
    }
          disconnectedCallback() {
        this.stopStatusCheck();
    }

    startStatusCheck() {
        // Check status every 5 seconds
        this.intervalId = setInterval(() => {
            this.checkStatusUpdate();
        }, 4000);
    }

    stopStatusCheck() {
        if (this.intervalId) {
        clearInterval(this.intervalId);
    }
    }

    checkStatusUpdate() {
        hasStatusUpdated({ selectedId: this.bookingIdSelected })
            .then((statusUpdated) => {
                console.log('Hello::'+ statusUpdated);
                if (statusUpdated) {
                    this.closeModal();
                    this.stopStatusCheck(); // Stop checking once the modal is closed
                }
            })
            .catch((error) => {
                console.error('Error checking status update:', error);
            });
    }
}