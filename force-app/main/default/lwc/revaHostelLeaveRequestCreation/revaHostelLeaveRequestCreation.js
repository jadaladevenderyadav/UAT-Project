import { LightningElement,track,api,wire } from 'lwc';
import getHostelLeaveRequests from '@salesforce/apex/RevaHostelLeaveRequestController.getHostelLeaverequests';
import { NavigationMixin } from 'lightning/navigation';
import saveLeaveRequest from '@salesforce/apex/RevaHostelLeaveRequestController.saveLeaveRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import State from '@salesforce/schema/Lead.State';
export default class RevaHostelLeaveRequestCreation extends NavigationMixin(LightningElement) {

   // leaveRequests;
    error;
     showNewRequestForm = false;
     ReasonLeave = '';
     NoteApprover = '';
     StartDate = '';
     EndDate = '';
     VisitingAddress = '';
     TermsConditions = false;
     fileName = '';
     fileUploaded = false;
    fileContent;
    wiredLeaveRequestResult;
    @api leaveRequests;
    @api error;
    @api requestId;
    recordId;
    showDetailPage;
    showListView;

    handleShowNewCaseForm(){
     this.showNewRequestForm = true;
    }

   
    LeaveOptions = [
        { label: 'Going Home', value: 'Going Home' },
        { label: 'Other', value: 'Other' }
    ];
    
// get leave requests
    @wire(getHostelLeaveRequests)
    wiredLeaveRequests({ error, data }) {
        if (data) {
            this.leaveRequests = data;
            this.showListView = this.leaveRequests.length > 0;
            this.error = undefined;
            
        } else if (error) {
            this.error = error;
            this.leaveRequests = undefined;
        }
    }
//request creation
    handleLeaveOptions(event) {
        this.ReasonLeave = event.target.value;
    }

    handleNoteApprover(event) {
        this.NoteApprover = event.target.value;
    }

    handleStartDate(event) {
        const selectedDate = new Date(event.target.value);
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1); // Get tomorrow's date
        tomorrow.setHours(0, 0, 0, 0); // Set to start of tomorrow
       // selectedDate.setHours(0, 0, 0, 0);

        if (selectedDate < tomorrow) {
            this.dispatchEvent(
                new ShowToastEvent({
                  //  title: 'Error',
                    message: 'Start date must be from tomorrow onwards.',
                    variant: 'error',
                })
            );
            this.StartDate = ''; // Clear the invalid date
        } else {
            this.StartDate = event.target.value;
            console.log("this.startDate",this.StartDate);
           this.error = '';
        }
    }

    handleEndDate(event) {
        
        const endDate = new Date(event.target.value);
        const startDate = new Date(this.StartDate);
        console.log("startDate", startDate);

        if (endDate <= startDate) {
            this.dispatchEvent(
                new ShowToastEvent({
                   // title: 'Error',
                    message: 'End date cannot be before start date.',
                    variant: 'error',
                })
            );
            this.EndDate = ''; // Clear the invalid date
        } else {
            this.EndDate = event.target.value;
            console.log("this.EndDate", this.EndDate);
            this.error = '';
        }
    }
    handleVisitingAddress(event) {
        this.VisitingAddress = event.target.value;
    }
   /* handleTermsConditions(event) {
        this.TermsConditions = event.target.checked;
    }*/

    handleFileChange(event) {
        if (event.target.files.length > 0) {    
            const file = event.target.files[0];
            this.fileName = file.name;
            this.fileContent = file;
        }
    }

    handleCancel() {
        this.fileName = '';
        this.fileUploaded = false;
        this.fileContent = null;
    }
    
    handleSave() {

       // Validate required fields
       if (!this.ReasonLeave || !this.NoteApprover ||!this.StartDate || !this.EndDate ) {
            this.dispatchEvent(
                new ShowToastEvent({
                   // title: 'Error',
                    message: 'Please fill in all required fields '+
                    'or Start date must be from tomorrow onwards and End date cannot be before start date',
                    variant: 'error',
                })
            );
            return;
        }
       const fields = {
            ReasonLeave: this.ReasonLeave,
            NoteApprover: this.NoteApprover,
            StartDate: this.StartDate,
            EndDate: this.EndDate,
            VisitingAddress: this.VisitingAddress,
            FileName: this.fileName,
            FileContent: this.fileContent,
        };

        console.log('Saving leave request with fields:', fields);

        saveLeaveRequest({ requestDetails: fields })
            .then(() => {
             this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Leave request Created successfully',
                        variant: 'success',
                    })
                );
                this.handleReset();
                this.showNewRequestForm = false;
                // Refresh the page
                location.reload();
              
            })

            .catch(error => {
                console.log('Hello');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving leave request',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
                console.error('Error saving leave request:', error);
            }).finally(() => {
                this.saving = false; // Finish saving operation
            });
    }

    handleClose() {
        this.showNewRequestForm = false;
    }

    handleReset() {
        this.ReasonLeave = '';
        this.NoteApprover = '';
        this.StartDate = '';
        this.EndDate = '';
        this.TermsConditions = false;
        this.fileName = '';
        this.fileUploaded = false;
        this.fileContent = null;
    }
    handleNameClick(event) {

       const leaveRequestId = event.target.dataset.id;
       this.recordId = leaveRequestId;
       this.showListView = false;
       this.showDetailPage = true;

     //  alert(leaveRequestId);
       /* console.log('leaveRequestId::',leaveRequestId);
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "revahostelleaverequest",
                recordId: leaveRequestId
            }
        });   */
      
      
    }

    handleClickBack(){
        this.showDetailPage = false;
        this.showListView = true;
    }
}