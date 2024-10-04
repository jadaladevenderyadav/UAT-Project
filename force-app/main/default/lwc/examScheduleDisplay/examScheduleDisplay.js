import { LightningElement, wire, track } from 'lwc';
import getExamScheduleItems from '@salesforce/apex/rveFacultyTimeTableController.getExamScheduleItems';
import updateExamScheduleItems from '@salesforce/apex/rveFacultyTimeTableController.updategetExamScheduleItems';
import getIAExamTimeTable from '@salesforce/apex/rveFacultyTimeTableController.getIAExamTimeTable';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ExamScheduleDisplay extends LightningElement {
    @track examScheduleItems=[];
    isEditing = false;
    @track showData = false;
    co;
    feedata = [];
    courseData;
    studentContacts;
    examtimetabledata;
    @track lineItemData;
    enrollProgramBatchId;
    activeSemester;
    ProgramBatchId;
    activeSemesterId;
    @track courseId;
    @track coursesName;
    @track courses;
    @track timeOptions = [];
    @track coursesDate = [];
    @track coursesStartTime = [];
    @track coursesEndTime = [];
    @track coursesEndTimeDetails;
    @track coursesStartTimeDetails;
    @track coursesDateDetails=[];
    @track courseData=[]
    fiterdata = [];
    isEdit = true;
    wiredResult;

    @wire(getExamScheduleItems)
    wiredExamSchedule(result) {

        this.wiredResult = result;
        if (result.data) {
            // Format the time fields
            this.courses = result.data;
            let k = 0;
            for (let i of this.courses) {
                        
            const course = {
                            index: k,
                            Id:i.Id,
                            hed_Start_Time__c: this.formatTime(i.hed_Start_Time__c),
                            hed_End_Time__c: this.formatTime(i.hed_End_Time__c),
                            startTimePreviousValue:this.formatTime(i.hed_Start_Time__c),
                            EndTimePreviousValue:this.formatTime(i.hed_End_Time__c),
                            hed_Date__c:i.hed_Date__c,
                            DatePreviousValue:i.hed_Date__c,
                            CourseId: i.Course__r.hed__Course_ID__c,
                            Name: i.Name,
                            IaType:i.Reva_Exam_Notification__r.hed_IA_Type__c
            };

                        // Check if the course already exists in examScheduleItems
            const courseExists = this.examScheduleItems.some(item => item.Id === course.Id);

            // If the course does not exist, push it to the examScheduleItems array
            if (!courseExists) {
            this.examScheduleItems.push(course);
            k++; // Increment index only when a new course is added
            }
            }

          //  console.log('57=> '+this.examScheduleItems.length)
            if (this.examScheduleItems.length === 0) {
                this.isEdit = true;

            }
            else {
                this.isEdit = false;

            }
            // alert(this.isEdit);

        } else if (result.error) {
            console.error('Error fetching exam schedule items:', result.error);
        }
    }

    @wire(getIAExamTimeTable)
    getIAExamTimeTables({ data, error }) {
        if (data) {
            this.examtimetabledata = data;

                let k = 0;
             for (let i of this.examtimetabledata) {

                        const course = {
                            index: k,
                            Id:i.Id,
                            hed_Start_Time__c: this.formatTime(i.hed_Start_Time__c),
                            hed_End_Time__c: this.formatTime(i.hed_End_Time__c),
                            startTimePreviousValue:this.formatTime(i.hed_Start_Time__c),
                            EndTimePreviousValue:this.formatTime(i.hed_End_Time__c),
                            hed_Date__c:i.hed_Date__c,
                            DatePreviousValue:i.hed_Date__c,
                            CourseId: i.Course__r.hed__Course_ID__c,
                            Name: i.Name,
                            IaType:i.Reva_Exam_Notification__r.hed_IA_Type__c
                        };
                        k++;
                        this.courseData.push(course);
                    }
                }

                if (this.courseData != null && this.courseData.length > 0) {
                    this.showData = true;

                }
                else {
                    this.showData = false;
                }
        }

    connectedCallback() {
        // Initialize time options when the component is connected to the DOM
        this.initializeTimeOptions();
    }

    // Format time for dropdown in "12:45:00 AM" format
    formatTimeForDropdown(hours, minutes) {
        const period = hours < 12 ? 'AM' : 'PM';
        const formattedHours = hours % 12 || 12; // Convert 0 to 12
        const formattedMinutes = String(minutes).padStart(2, '0');
        return `${formattedHours}:${formattedMinutes}:00 ${period}`;
    }
    initializeTimeOptions() {
        for (let hours = 0; hours < 24; hours++) {
            for (let minutes = 0; minutes < 60; minutes += 15) {
                const formattedTime = this.formatTimeForDropdown(hours, minutes);
                this.timeOptions.push({ label: formattedTime, value: formattedTime });
            }
        }
    }

    handleEditClick() {
        this.isEditing = true;
    }

    handleSaveClick() {

    
                let updatedtimelineitem = [];

                for(let i of this.examScheduleItems)
                    {
                        if(i.hed_Date__c!=null && i.hed_Start_Time__c!=null && i.hed_End_Time__c!=null)
                        {
                        const newInstance = {
                            Id:i.Id,
                            StartTime:i.hed_Start_Time__c,
                            EndTime:i.hed_End_Time__c,
                            LineItemDate:i.hed_Date__c
                        }
                        updatedtimelineitem.push(newInstance);
                        }
                        else{
                            this.dispatchEvent(
                              new ShowToastEvent({
                              title: 'Success',
                              message: 'Please provide value for required fields',
                              variant: 'success'

                            })
                );
                        }
            
                    }

                if(updatedtimelineitem.length>0)
                {

                let SerializedTimeTableItem = JSON.stringify(updatedtimelineitem);
                console.log('SerializedTimeTableItem=> '+SerializedTimeTableItem);
                updateExamScheduleItems({JsonString:SerializedTimeTableItem})
                .then(result => {
                // Handle success
                console.log('Update successful:', result);

                this.isEditing = false;
                this.refreshData();

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'TimeTable Updated Successfully!!',
                        variant: 'success'

                    })
                );

                for(let i of this.examScheduleItems)
                    {
                        i.startTimePreviousValue = i.hed_Start_Time__c;
                        i.EndTimePreviousValue = i.hed_End_Time__c;
                        i.DatePreviousValue = i.hed_Date__c;
                    }

            }).catch(error => {
                // Handle error
                console.error('Error updating exam schedule items:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occurred While Updation of TimeTable',
                        variant: 'error'
                    })
                );
            });
                }

            
    }

    parseTime(timeStr) {
        const timeParts = timeStr.match(/(\d+):(\d+):(\d+) (AM|PM)/);
        if (!timeParts) {
            throw new Error('Invalid time format');
        }
        let [_, hours, minutes, seconds, period] = timeParts;
        hours = parseInt(hours, 10);
        minutes = parseInt(minutes, 10);
        seconds = parseInt(seconds, 10);
    
        if (period === 'PM' && hours < 12) {
            hours += 12;
        }
        if (period === 'AM' && hours === 12) {
            hours = 0;
        }
    
        const date = new Date();
        date.setHours(hours, minutes, seconds, 0);
    
        return date;
    }

    get isButtonDisabled() {
        let isDisabled = true; // Initially set the button as disabled
    
        const rows = this.template.querySelectorAll('tr'); // Select all table rows
        const currentDate = new Date().toISOString().split('T')[0]; // Get current date
    
        // Iterate through each row
        for (let i = 0; i < rows.length; i++) {
            const inputs = rows[i].querySelectorAll('lightning-input, lightning-combobox'); // Select all input and combobox elements within the row
            let startTime = null;
            let endTime = null;
            let date = null;
    
            // Iterate through each input field in the row
            for (let j = 0; j < inputs.length; j++) {
                const input = inputs[j];
    
                // Check if any input field is empty
                if (!input.value) {
                    return true; // No need to check further, exit the loop
                } else {
                    // Date Validation
                    if (input.name === 'date') {
                        date = input.value;
                        if (!input.value || input.value <= currentDate) {
                            input.setCustomValidity("Please select a future date.");
                            input.reportValidity();
                            return true; // Disable button if date is not a future date or no value is present
                        } else {
                            input.setCustomValidity("");
                        }
                    }
    
                    // Store the start time value
                    if (input.name === 'hed_Start_Time__c') {
                        startTime = input.value;
                    }
    
                    // Store the end time value
                    if (input.name === 'hed_End_Time__c') {
                        endTime = input.value;
                    }
                }
            
            // Validate start and end times
            if (startTime && endTime) {
                const startDateTime = this.parseTime(startTime);
                const endDateTime = this.parseTime(endTime);
    
                if (endDateTime < startDateTime) {
                 //   const endTimeInput = rows[i].querySelector('lightning-combobox[name="endTime"]');
                    input.setCustomValidity("End time cannot be earlier than start time.");
                    input.reportValidity();
                    return true; // Disable button if end time is earlier than start time
                } else {
                  //  const endTimeInput = rows[i].querySelector('lightning-combobox[name="endTime"]');
                    input.setCustomValidity("");
                }
            }
        }
        }
    
        return false; // Enable the button if all validations pass
    }

    refreshData() {
        console.log('refreshDataCalled');
        return refreshApex(this.wiredResult);

    }

    handleCancelClick() {
        // Reset the edited data and exit edit mode
        this.isEditing = false;
        if(this.examScheduleItems.length>0){
          for(let i of this.examScheduleItems)
            {
                console.log('StartTime=> '+i.hed_Start_Time__c+' PreviousValue=> '+i.startTimePreviousValue);
                console.log('EndTime=> '+i.hed_End_Time__c+' PreviousValue=> '+i.EndTimePreviousValue);
                console.log('Date=> '+i.hed_Date__c+' PreviousValue=> '+i.DatePreviousValue);
                i.hed_Start_Time__c = i.startTimePreviousValue!=null?i.startTimePreviousValue:i.hed_Start_Time__c;
                i.hed_End_Time__c = i.EndTimePreviousValue!=null?i.EndTimePreviousValue:i.hed_End_Time__c;
                i.hed_Date__c = i.DatePreviousValue!=null?i.DatePreviousValue:i.hed_Date__c;
            }
        }
       //  this.refreshData();
        // this.wiredExamSchedule({data: this.examScheduleItems });
    }

    formatTime(milliseconds) {
        const date = new Date(milliseconds);

        // Adjust for IST offset (5 hours and 30 minutes)
        const istOffset = 5 * 60 * 60 * 1000 + 30 * 60 * 1000;
        const istTime = new Date(date.getTime() - istOffset);

        // Set the time zone to Indian Standard Time (IST)
        const options = { timeZone: 'Asia/Kolkata', hour12: true };
        const formattedTime = istTime.toLocaleTimeString('en-US', options);

        return formattedTime;
    }
   
    handleDateChange(event) {
        const value = event.target.value;
        const index = parseInt(event.target.dataset.index);

        this.examScheduleItems.forEach(e => {
        if(e.index == index) {
            if(e.DatePreviousValue==null)
                {
                    e.DatePreviousValue = e.hed_Date__c;

                }
            e.hed_Date__c = value;
            console.log('Date=> '+e.hed_Date__c+' PreviousValue=> '+e.DatePreviousValue)
        }
        })
    }

    handleStartTimeChange(event) {
        let value = event.target.value;
        let index = parseInt(event.target.dataset.index);

        this.examScheduleItems.forEach(e => {
        if(e.index == index) {
            if(e.startTimePreviousValue==null)
                {
                    e.startTimePreviousValue = e.hed_Start_Time__c;

                }
            e.hed_Start_Time__c = value;

        }
        })
    }

    handleEndTimeChange(event) {

        const value = event.target.value;
        const index = parseInt(event.target.dataset.index);

        this.examScheduleItems.forEach(e => {
        if(e.index == index) {
            if(e.EndTimePreviousValue==null)
                {
                    e.EndTimePreviousValue = e.hed_End_Time__c;

                }
            e.hed_End_Time__c = value;
        }
        })
    }
}