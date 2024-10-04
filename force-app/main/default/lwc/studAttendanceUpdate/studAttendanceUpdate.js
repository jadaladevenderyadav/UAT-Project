import { LightningElement, track } from 'lwc';
import searchAttendanceRecords from '@salesforce/apex/StudAttendanceUpdate.searchAttendanceRecords';
import updateAttendanceRecords from '@salesforce/apex/StudAttendanceUpdate.updateAttendanceRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StudAttendanceUpdate extends LightningElement {
    @track srnInput = '';
    @track searchDate = '';
    @track records = [];
    @track selectedRows = new Set();  // Store selected row IDs
    isLoading = false;
    attendanceRecords = [];

    @track selected_reason = ''; // Default value for the spinner
    options = [
        { label: 'Sports', value: 'Sports' },
        { label: 'NCC/NSS', value: 'NCC/NSS' },
        { label: 'Club Activities', value: 'Club Activities' },
        { label: 'Placement', value: 'Placement' },
        { label: 'Extra Curricular Activity', value: 'Extra Curricular Activity' },
        { label: 'Others', value: 'Others' }
    ];

    handleChange(event) {
        this.selected_reason = event.detail.value; // Set the selected value
        this.showToastMessage(this.selected_reason); // Show toast with the selected value
    }

    showToastMessage(selectedValue) {
        const evt = new ShowToastEvent({
            title: 'Selected Reason',
            message: `You selected: ${selectedValue}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleSrnChange(event) {
        this.srnInput = event.target.value;
        console.log('SRN :'+this.srnInput);
    }

    handleDateChange(event) {
        this.searchDate = event.target.value;
        console.log('Search Date :'+this.searchDate);
    }

    handleSearch() {        
        // let SRNinput = this.template.querySelector('.inputSRNnumber').value;
        // if(SRNinput == '' || SRNinput == null){
        if (this.srnInput && this.searchDate) {      
            this.isLoading = true;      
             // Split the input by commas and trim whitespace
            const srns = this.srnInput.split(',').map(srn => srn.trim()).filter(srn => srn !== '');
            console.log('Entered SRN1 :'+this.srnInput+" Date: "+this.searchDate);
            if (srns.length === 0) {
                this.showToast('Error', 'Please enter valid SRNs', 'error');
                this.isLoading = false;
                return;
            }
            searchAttendanceRecords({ srn: this.srnInput, searchDate: this.searchDate })
                .then(result => {
                    console.log('Length :'+result.length);
                  //  this.records = result;
                    this.isLoading = false;                   

                    if (result.length === 0) {
                        this.showToast('Info', 'Records are not available for the provided input', 'info');
                    } else {
                        this.records = result;
                    } 
                })
                .catch(error => {
                 //   this.showToast('Error', error.body.message, 'error');
                 // Check if error body is defined before accessing message
                    const message = error.body ? error.body.message : 'An unknown error occurred';
                    this.showToast('Error', message, 'error');
                    this.isLoading = false; // Ensure loading is stopped in case of error
                });
        } else {
            this.showToast('Error', 'SRN and Date are required', 'error');
        }
    }

    updateTime(){
        // if (this.records) {
        //     this.attendanceRecords = this.records.map(record => {
        //         return {
        //             ...record,
        //             startTime: this.formatTime(record.Course_Offering_Schedule__r.hed__Start_Time__c),
        //             endTime: this.formatTime(record.Course_Offering_Schedule__r.hed__End_Time__c)
        //         };
        //     });
        // }
        // console.log('update Record :'+this.attendanceRecords[0].startTime +" : "+this.attendanceRecords[0].endTime +" : "+this.attendanceRecords[0].Slot__c+" : "+this.attendanceRecords[0].SRN__c); 
        if (this.records) {
            this.attendanceRecords = this.records.map(record => {
                return {
                    ...record,
                    startTime: this.convertUtcToIst(record.Course_Offering_Schedule__r.hed__Start_Time__c),
                    endTime: this.convertUtcToIst(record.Course_Offering_Schedule__r.hed__End_Time__c)
                };
            });
        }
        console.log('Formatted  :'+this.attendanceRecords[0].startTime +" : "+this.attendanceRecords[0].endTime+" && "+this.attendanceRecords[0].Slot__c+" : "+this.attendanceRecords[0].SRN__c); 
    }

    handleRowSelection(event) {
        const recordId = event.target.dataset.id;
        if (event.target.checked) {
            this.selectedRows.add(recordId);
        } else {
            this.selectedRows.delete(recordId);
        }
    }

    handleSelectAll(event) {
        const checkboxes = this.template.querySelectorAll('tbody input[type="checkbox"]');
        if (event.target.checked) {
            checkboxes.forEach(checkbox => {
                checkbox.checked = true;
                this.selectedRows.add(checkbox.dataset.id);
            });
        } else {
            checkboxes.forEach(checkbox => {
                checkbox.checked = false;
                this.selectedRows.delete(checkbox.dataset.id);
            });
        }
    }

    get isUpdateButtonVisible(){
        if(this.records.length > 0){
            return true;
        } 
       return false;
    }

    handleUpdateSelected() {        
        console.log('Selected handleUpdateSelected ');
        const selectedRecords = this.records.filter(record => this.selectedRows.has(record.Id));
      //  console.log('Selected records : '+selectedRecords);
     //   console.log('Selected attendence : '+selectedRecords[0].hed__Attendance_Type__c +"  "+selectedRecords[0].hed__Contact__r.Name);
        console.log('Pre +');
        // selectedRecords.forEach(record => {
        //     record.hed__Attendance_Type__c = 'Present'; // Set Attendance Type to 'Present'
        // });
        console.log('Length :'+this.selectedRows.size);
        let recordsToUpdate;
        if(this.selectedRows.size > 0){           
            if(!this.selected_reason) { 
                this.showToast('Error', 'Select Reason To Update', 'error');
            }else{    
                recordsToUpdate = selectedRecords.map(record => {
                    return {
                        Id: record.Id,
                        hed__Attendance_Type__c: 'Present',  // Update Attendance Type to 'Present'
                    //  SRN: record.SRN__c,
                        hed__Reason__c : this.selected_reason
                    };         
                });  
                
                
                console.log('Post ');
                console.log('recordsToUpdate :'+recordsToUpdate[0].Id);
                for(let i = 0 ; i < recordsToUpdate.length ; i++){
                    // console.log('Selected name : '+selectedRecords[i].SRN__c);
                //  selectedRecords[i].hed__Attendance_Type__c = 'Present';
                    console.log('Selected attendence : '+recordsToUpdate[i].hed__Attendance_Type__c +"  "+recordsToUpdate[i].Id+" "+recordsToUpdate[i].hed__Reason__c);
                } 

                this.isLoading = true;
                updateAttendanceRecords({ recordsToUpdate })
                    .then(() => {
                        this.isLoading = false;
                        this.showToast('Success', 'Selected records updated to Present', 'success');
                        this.selectedRows.clear(); // Clear selection after update
                        console.log('Result : Success');
                        // Refresh the records on the page to reflect changes
                        this.handleSearch(); // Optionally refresh search results after update
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log('Result : Failure');
                        this.showToast('Error', error.body.message, 'error');
                    });       
            }
        }else{            
            this.showToast('Error', 'Select Student Records to Update', 'error');
        }      
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    formatTime(timestamp) {
        if (timestamp) {
            console.log('timeStamp before convertUtcToIst : '+timestamp);
            this.convertUtcToIst(timestamp);
            // Convert milliseconds to a Date object
            const date = new Date(timestamp);
            // Format the time as desired (e.g., HH:MM AM/PM)
           // return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
         //  let newdate = date.addHours(-5).addMinutes(-30);
         //  console.log('Date :::'+newdate);
          
           return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
        }
        return '';
    }

    convertUtcToIst(utcDateString) {

        if (!utcDateString) {
            return '';
        }
    
        // Create a Date object from the UTC string
        const utcDate = new Date(utcDateString);
    
        // Convert to IST by adding 5 hours and 30 minutes
        const istOffset = - (5 * 60 + 30); // in minutes
        const istDate = new Date(utcDate.getTime() + istOffset * 60 * 1000);

        console.log('Date :::'+istDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true }));
    
        // Format the IST date as desired (e.g., HH:MM AM/PM)
        return istDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
    }
    
}