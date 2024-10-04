// timeSlotComponent.js
import { LightningElement, track,wire,api } from 'lwc';
import fetchCustomMetadataMap from '@salesforce/apex/rewaTimeSlot.fetchCustomMetadataMap';
import fetchEventDetails from '@salesforce/apex/rewaCaseController.fetchEventDetails';
export default class TimeSlotComponent extends LightningElement {
    
    @track timeSlots = [];
    @track hideSlot=false;
    stringtimeSlot=[];
    @track selectedDate = '';
    minDate = new Date().toISOString().split('T')[0];
    currentDateTime = new Date().toISOString();
    @track selectedTimeSlot='';
    @track isSubmitButtonDisabled = true;
    @track showRewaBookEvent = false;
    @track showParentComponent = true;
    @track year='';
    @track month='';
    @track day='';
    @track starthours='';
    @track startminutes='';
    @track endhours='';
    selectDate='';
    formatDate='';
    @api selectContact='';
    @api selectedAppointmentType;


    handleDateChange(event) {
        this.selectedDate = event.target.value;
        this.stringtimeSlot = [];
        console.log(this.selectedDate);
        console.log('selectedContactafter'+this.selectContact);
        //this.isSubmitButtonDisabled = !this.selectedDate;
        this.updateSubmitButtonState();
        this.hideSlot=false;
        
    }
    updateSubmitButtonState() {
        const today = new Date().toISOString().split('T')[0];
        console.log('Selected Date: ' + this.selectedDate);
        this.isSubmitButtonDisabled = this.selectedDate < today;
    }
    

    handleButtonClick() {
        this.hideSlot=true;
        // Call the Apex method to fetch all time slots
        fetchCustomMetadataMap()
        .then(result => {
            // Process the result here
            const hourToCMDTMap = result;
            console.log('result*****'+JSON.stringify(result));
            console.log('hourToCMDTMap*****'+JSON.stringify(hourToCMDTMap));
            // Flatten the map into an array for rendering in the UI
            this.timeSlots = [];
            for (const [hourKey, cmdtRecords] of Object.entries(hourToCMDTMap)) {
                console.log('inside for loop*****');
                console.log('hourKey*****'+hourKey);
                console.log('cmdtRecords*****'+cmdtRecords);
                console.log('timeSlots 42*****'+JSON.stringify(this.timeSlots));
                this.timeSlots.push({ hourKey, cmdtRecords });
                console.log('timeSlots*****'+JSON.stringify(this.timeSlots));
            }

            console.log('timeSlots outside loop*****'+JSON.stringify(this.timeSlots));
            if(this.selectedDate != null){
                console.log('insidebuttonclick');
                console.log('times',JSON.stringify(this.timeSlots));
                
                this.timeSlots.forEach(slot => {
                    console.log('stringtimeSlot*****'+this.stringtimeSlot);
                    const stringtimeSlot5 =this.stringtimeSlot.join(',');
                    console.log('stringtimeSlot5***'+stringtimeSlot5);
                    console.log('slot.hourKey*****'+slot.hourKey);
                    var bookedslots = stringtimeSlot5.split(',');
                    console.log('bookedslotsstringfy*****'+JSON.stringify(bookedslots));
                    console.log('bookedslots*****'+bookedslots);
                   // slot.disabled = this.stringtimeSlot.includes(slot.hourKey);
                    slot.disabled = false;
                    console.log('slot.disabled initial'+slot.disabled);

                    //console.log('bookedslots is empty');
    
                    if (JSON.stringify(bookedslots) == '[""]') {
    // Handle case where bookedslots is an empty array
    console.log('bookedslots is empty');
    slot.disabled = (this.doTimeSlotsOverlap1(slot.hourKey, this.selectedDate) || slot.disabled);
    console.log('slot.disabled' + slot.disabled);
} else {

                    bookedslots.forEach(bookedSlot => {
                    
                    console.log('bookedSlot1*****'+bookedSlot);
                    console.log('slot.hourKey*****'+slot.hourKey);
                    slot.disabled = ((this.doTimeSlotsOverlap(bookedSlot, slot.hourKey, this.selectedDate))||slot.disabled);
                    console.log('slot.disabled'+slot.disabled);
                });
}
                 
                    console.log('stringtimeSlot2-*****'+this.stringtimeSlot);
                });
            }
            else{

            }
        })
        .catch(error => {
            // Handle any errors here
            console.error('Error fetching time slots:', error);
        });

        
        
       
           
}
    

    // Handle custom box tile click
    handleTileClick(event) {

        this.selectedTimeSlot = event.currentTarget.dataset.timeslot;
        console.log('>>>> 0',this.selectedTimeSlot);
        this.showRewaBookEvent = true;
        //this.showParentComponent = false;
        const selectedDate = this.selectedDate;
        const timeSlot = this.selectedTimeSlot; // Replace with your selected time slot
        const [startTime, endTime] = timeSlot.split(' - ');
        console.log('startime', startTime);
        console.log('endtime', endTime);
        console.log('>>>> time slot',timeSlot);
        console.log('>>>> new date',selectedDate);

        // Split the selectedDate into day, month, and year
        var dateParts = selectedDate.split("-");
         this.year = dateParts[0];
        console.log('year*******'+this.year);
         this.month = dateParts[1];
        console.log('month*******'+this.month);
         this.day = dateParts[2];
        console.log('day*******'+this.day);

        // Split the startTime into hours and minutes

        var starttimeParts = startTime.split(":");
        var starttimeParts2 = starttimeParts[1].split(" ")
        console.log(starttimeParts);
         this.starthours = parseInt(starttimeParts[0]);
         this.startminutes = parseInt(starttimeParts2[0]);
        console.log('starthours******'+this.starthours);
        console.log('startminutes******'+this.startminutes);
        //var minutes = parseInt(timeParts[1].split(" ")[0]); // Remove AM/PM and get minutes
        //console.log('++++minutes'+minutes);
       // Adjust hours for PM if necessary

        if (startTime.includes("PM") && this.starthours < 12) {

            this.starthours += 12;
        console.log('++++'+this.starthours);
        }
        console.log('Test1*********');

        // // Create a JavaScript Date object with the components
        // var startjsDate = new Date(year, month - 1, day, starthours, 0);
        // console.log('startjsDate******'+startjsDate);
        // console.log("test2");
        // // Get the date and time components in the desired format
        // var startformattedDate = startjsDate.toISOString(); // ISO 8601 format with UTC offset
        // // Resulting Salesforce date-time field value
        // console.log(startformattedDate);

        // Split the endTime into hours and minutes

        var endtimeParts = endTime.split(":");
        var endtimeParts2 = starttimeParts[1].split(" ")
        console.log(endtimeParts);
         this.endhours = parseInt(endtimeParts[0]);
         this.endminutes = parseInt(endtimeParts2[0]);
        console.log('endhours*****'+this.endhours);
        //var minutes = parseInt(timeParts[1].split(" ")[0]); // Remove AM/PM and get minutes
        //console.log('++++minutes'+minutes);
       // Adjust hours for PM if necessary

        if (endTime.includes("PM") && this.endhours < 12) {

            this.endhours += 12;
        console.log('endhoursloop*****'+this.endhours);
        }

        // // Create a JavaScript Date object with the components
        // var endjsDate = new Date(year, month - 1, day, starthours, 0);
        // console.log(endjsDate);
        // // Get the date and time components in the desired format
        // var endformattedDate = endjsDate.toISOString(); // ISO 8601 format with UTC offset
        // // Resulting Salesforce end date-time field value
        // console.log(endformattedDate);


        // Remove the 'selected-input' class from all input elements
        const inputs = this.template.querySelectorAll('.custom-input-container');
        inputs.forEach(input => {
            input.classList.remove('selected-input');
        });

        // Add the 'selected-input' class to the clicked input element
        event.target.classList.add('selected-input');
    }

    handlegrandChildEvent(event) {
        this.messageReceived = event.detail;
    }

    @wire (fetchEventDetails,{ selectedDate: '$selectedDate' })
    
    fetchEventDetails({data,error}){
        if(data){
            console.log('>>>>>>',data);
            const stringtimeSlots = []; // Initialize as an empty array

            data.forEach(event => {
                const startDateTime = event.StartDateTime;
                const endDateTime = event.EndDateTime;

                console.log('startDateTime', startDateTime);
                console.log('endDateTime', endDateTime);

                const formatTime = (dateTime) => {
                    const options = { hour: 'numeric',minute: 'numeric', hour12: true };
                    return new Intl.DateTimeFormat('en-US', options).format(new Date(dateTime));
                };
                
                // Create time slot strings
                const startTimeSlot = formatTime(startDateTime);
                const endTimeSlot = formatTime(endDateTime);
                console.log('startTimeSlot', startTimeSlot);
                console.log('endTimeSlot', endTimeSlot);
                
                // Split the time into hours and AM/PM
                const startTimeParts = startTimeSlot.split(' ');
                const endTimeParts = endTimeSlot.split(' ');
                
                // Remove the minutes from the hours
                const formattedStartTime = startTimeParts[0] + ' ' + startTimeParts[1];
                const formattedEndTime = endTimeParts[0] + ' ' + endTimeParts[1];
                
                // Create a string for the time slot
                //this.stringtimeSlot = `${formattedStartTime} - ${formattedEndTime}`;
                stringtimeSlots.push(`${formattedStartTime} - ${formattedEndTime}`); // Push into the array    
                this.stringtimeSlot = stringtimeSlots;
                console.log('stringtimeslot', this.stringtimeSlot);            
        });
    }
        else if(error){
            console.log(error);
        }
    }

   // Function to check if two time slots overlap
    doTimeSlotsOverlap(slot1, slot2, selectedDate) {
    const [start1, end1] = slot1.split(' - ');
    const [start2, end2] = slot2.split(' - ');

    const convertToDateTime= (timeString) => {
        const [time, period] = timeString.split(' ');
    
        const [hours, minutes] = time.split(':').map(Number);
    
        let hours24 = hours;
        if (period.toLowerCase() === 'pm' && hours24 < 12) {
            hours24 += 12;
        } else if (period.toLowerCase() === 'am' && hours24 === 12) {
            hours24 = 0;
        }
    
        const date = new Date();
        date.setHours(hours24, minutes, 0, 0);
    
        return date;
    }

    const today = new Date();

const year = today.getFullYear();
const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
const day = String(today.getDate()).padStart(2, '0');

const formattedDate = `${year}-${month}-${day}`;

console.log("today---"+formattedDate);
//console.log("4 --->"+(formattedDate == currentDateTime));

    const currentDateTime = new Date();
    console.log("currentDateTime --->"+currentDateTime);
    const startDateTime1 = convertToDateTime(start1);
    console.log("startDateTime1 --->"+startDateTime1);
    const endDateTime1 = convertToDateTime(end1);
    console.log("endDateTime1 --->"+endDateTime1);
    const startDateTime2 = convertToDateTime(start2);
    console.log("startDateTime2 --->"+startDateTime2);
    const endDateTime2 = convertToDateTime(end2);
    console.log("endDateTime2 --->"+endDateTime2);
    console.log("1 --->"+(startDateTime1 < endDateTime2 && startDateTime1 >= startDateTime2));
    console.log("2 --->"+(endDateTime1 <= endDateTime2 && endDateTime1 > startDateTime2));
    console.log("3 --->"+(startDateTime1 <= startDateTime2 && endDateTime1 >= endDateTime2));
    console.log("4 --->"+(startDateTime2 <= currentDateTime));
    console.log("formattedDate == currentDateTime --->"+(formattedDate == selectedDate));

    if(formattedDate == selectedDate){
    return ((startDateTime1 < endDateTime2 && startDateTime1 >= startDateTime2)||(endDateTime1 <= endDateTime2 && endDateTime1 > startDateTime2)||(startDateTime1 <= startDateTime2 && endDateTime1 >= endDateTime2)||(startDateTime2 <= currentDateTime));
    }

    else {
        return ((startDateTime1 < endDateTime2 && startDateTime1 >= startDateTime2)||(endDateTime1 <= endDateTime2 && endDateTime1 > startDateTime2)||(startDateTime1 <= startDateTime2 && endDateTime1 >= endDateTime2));
        }
}



 doTimeSlotsOverlap1( slot2, selectedDate) {
    //const [start1, end1] = slot1.split(' - ');
    const [start2, end2] = slot2.split(' - ');

    const convertToDateTime= (timeString) => {
        const [time, period] = timeString.split(' ');
    
        const [hours, minutes] = time.split(':').map(Number);
    
        let hours24 = hours;
        if (period.toLowerCase() === 'pm' && hours24 < 12) {
            hours24 += 12;
        } else if (period.toLowerCase() === 'am' && hours24 === 12) {
            hours24 = 0;
        }
    
        const date = new Date();
        date.setHours(hours24, minutes, 0, 0);
    
        return date;
    }

    const today = new Date();

const year = today.getFullYear();
const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
const day = String(today.getDate()).padStart(2, '0');

const formattedDate = `${year}-${month}-${day}`;

console.log("today new---"+formattedDate);
//console.log("4 --->"+(formattedDate == currentDateTime));

    const currentDateTime = new Date();
    console.log("currentDateTime --->"+currentDateTime);
   // const startDateTime1 = convertToDateTime(start1);
    //console.log("startDateTime1 --->"+startDateTime1);
   // const endDateTime1 = convertToDateTime(end1);
    console.log("start2 --->"+start2);
    const startDateTime2 = convertToDateTime(start2);
    console.log("startDateTime2 --->"+startDateTime2);
    const endDateTime2 = convertToDateTime(end2);
    console.log("endDateTime2 --->"+endDateTime2);
 
    console.log("4 --->"+(startDateTime2 <= currentDateTime));
    console.log("formattedDate == currentDateTime --->"+(formattedDate == selectedDate));

    if(formattedDate == selectedDate){
    return ((startDateTime2 <= currentDateTime));
    }

    
}

// // Step 3: Set the Time Component of the Date Objects
// startDateTime.setHours(parseInt(startHour, 10));
// startDateTime.setMinutes(parseInt(startMinute, 10));
// startDateTime.setSeconds(0); // Optionally, set seconds to 0
// console.log('>>>> startdatetimehrs',startDateTime.setHours);
// console.log('>>>> startdatetimemin',startDateTime.setMinutes);
// console.log('>>>> startdatetimesec',startDateTime.setSeconds(0));

 

// endDateTime.setHours(parseInt(endHour, 10));
// endDateTime.setMinutes(parseInt(endMinute, 10));
// endDateTime.setSeconds(0); // Optionally, set seconds to 0
// console.log('>>>> enddatetime',endDateTime.setHours);
// console.log('>>>> enddatetimemin',startDateTime.setMinutes);
// console.log('>>>> enddatetimesec',startDateTime.setSeconds(0));
        
    
    
    
    // Example usage
    //convertTimeslotToDatetime();
    

    // Redirect to the other page with the selected time slot as a parameter
    // redirectToOtherPage(selectedTimeSlot) {
    //     // Construct the URL for the other page
    //     //const otherPageUrl = `/StudentPortal/s/rewastudentinfo?SelectedTimeSlot=${selectedTimeSlot}`; // Replace with the actual URL
    //     //window.location.href = otherPageUrl; // Redirect to the other page
    // }
}