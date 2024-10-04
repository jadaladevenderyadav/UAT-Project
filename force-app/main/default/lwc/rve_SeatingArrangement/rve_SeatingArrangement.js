import { LightningElement, wire, track, api } from 'lwc';
// Import from Apex
 import getActivePrograms from '@salesforce/apex/rveSeatingArrangementUpdated.getActivePrograms';
 import getRelatedSchool from '@salesforce/apex/rveSeatingArrangementUpdated.getRelatedSchool';
 import createOrUpdateAllotment from '@salesforce/apex/rveSeatingArrangementUpdated.createOrUpdateAllotment';
 import getRevaExamNotifications from '@salesforce/apex/rveSeatingArrangementUpdated.getRevaExamNotifications';
 import getAllStudents from '@salesforce/apex/rveSeatingArrangementUpdated.getAllStudents';
 import updateFacilities from '@salesforce/apex/rveSeatingArrangementUpdated.updateFacilities';
 import checkProgramBatchAllotment from '@salesforce/apex/rveSeatingArrangementUpdated.checkProgramBatchAllotment'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Rve_SeatingArrangement extends LightningElement {

    // Variables related to account and school
    @track parentAccountId;
    @track ProgramBatch;
    @track ProgramOption = [];
    
    // Variables related to facilities and seating arrangements
    @track DisplayFacility=false;
    @track facilitiesList = [];
    @track seatingArrangements = [];
    @track seatingArrangementParent = [];
    @track finalAllotment = [];
    @track isModalOpen = false;
    @track showModal = false;
    @track valueToPass;
    
    // Variables related to exam details
    @track DateOfExam;
    @track IAType;
    @track Session;
    @track AllotmentDate;
    @track AllotmentTime;

    // Variables related to UI state and functionality
    @track secondcmp = false;
    @track variable1 = true;
    @track variable2 = true;
    @track EnableAllotmentButton = true;
    @track hasAvailableDates = false;

    // Variables related to time and date
    @track TimeTableDates = [];
    @track TimeTableTimes = [];
    @track timeMap = new Map();
    @track hours;
    @track DateByIA;
    @track mapData;
    @track variable=true
    @track EnableSubmitButton=true;
    @track ExamTime;
    @track EligibleStudentsCount;
    @track InEligibleStudentsCount;
    @track TotalStudents=0;
    @track DisplayStudents=false;
    @track dateMap={};
    @track morningShiftMap = {};
    @track afternoonShiftMap = {};

    // Variables related to seating display
    @track SelectedSeats=0;
    @track NeededSeats=0;
    @track previousCapacity=0;
    @track previouscapacitymap = new Map();
    @track isCapacityAdded={};

    get IATypesOptions() {
        return [
            { label: 'IA 1', value: 'IA 1' },
            { label: 'IA 2', value: 'IA 2' }
        ];
    }

    SessionOptions = [
        { label: 'Morning', value: 'Morning' },
        { label: 'Afternoon', value: 'Afternoon' }
    ];

    ModalOptions = [
        { label: 'Attendance Sheet', value: 'Attendance' },
        { label: 'Notice Board', value: 'Notice Board' }
    ];

     @wire(getActivePrograms)
    wiredAccounts({ error, data }) {
         if (data) {
            for(let i=0; i<data.length; i++) {
                 this.ProgramOption = [...this.ProgramOption ,{value: data[i].Id , label: data[i].Name}];                                   
             }
            this.error = undefined;
         } else if (error) {
             this.error = error;
             this.ProgramOption = undefined;
         }
     }

    // Function for handling program batch for Active Exam Notification
    SelectedProgramBatch(event){
             this.ProgramBatch = event.target.value;
    }

    // Function for handling IAType
    handleIATypeChange(event) {
        try{
            this.IAType = event.target.value;
            const IAType = event.target.value;
            this.seatingArrangements.forEach(e => {
                            
            e.IA_Type__c = IAType;
            });
            if(this.IAType!=null && this.Session!=null)
            {
            this.handleDateBasedOnIAChange();
            }   
        }
        catch(error){
        } 
    }

    // Function for handling date and time picklist onchange
        SelectedDate(event){
            this.EnableSubmitButton = false
            this.DateOfExam = event.target.value;
            this.TimeTableTimes = [];

           // Check if the DateOfExam exists as a key in the dateMap
          // Check if the DateOfExam exists as a key in the morningShiftMap or afternoonShiftMap
            if (this.morningShiftMap[this.DateOfExam] || this.afternoonShiftMap[this.DateOfExam]) {
    // Extract the times associated with the DateOfExam from the appropriate map
            let timesForDate = this.morningShiftMap[this.DateOfExam] || this.afternoonShiftMap[this.DateOfExam];

    // Iterate over the times and add them to the TimeTableTimes array
            timesForDate.forEach(time => {
        // Check if the time already exists in the TimeTableTimes array
            if (!this.TimeTableTimes.some(e => e.value === time)) {
            // If not, add it to the array
            this.TimeTableTimes = [...this.TimeTableTimes, { value: time, label: time }];
            }
        });

    // Sort the TimeTableTimes array after adding the times
            this.TimeTableTimes.sort((a, b) => {
            return new Date('1970/01/01 ' + a.value) - new Date('1970/01/01 ' + b.value);
            });
          }
        }

        // Function for handling the Shift
        handleSession(event){
          
            this.Session = event.target.value;
            getRevaExamNotifications({
                IAType:this.IAType,
                Session:this.Session,
                ProgramId:this.ProgramBatch
            }).then(res=>{
            if(res.length>0)
            {
                this.DateByIA = '';
                this.TimeTableDates=[];
                this.TimeTableTimes = [];
                this.timeMap.clear();
            
                for (let i = 0; i < res.length; i++) {
                    const date = res[i].hed_Date__c;
                    const time = res[i].hed_Start_Time__c;
                    const exists = this.TimeTableDates.find(entry => entry.value === date);
                
                    // Check if the date exists in the map, if not, initialize an empty array
                    if (!this.dateMap[date]) {
                        this.dateMap[date] = [];
                    }
                
                    // Add the date to the TimeTableDates if it does not exist
                    if (!exists) {
                        this.TimeTableDates = [...this.TimeTableDates, { value: date, label: date }];
                    }
                
                    // Parse the time string (assuming time is in HH:MM:SS format)
                    let hours = Math.floor(time / (1000 * 60 * 60));
                    let minutes = Math.floor((time % (1000 * 60 * 60)) / (1000 * 60));
                    let seconds = Math.floor((time % (1000 * 60)) / 1000);
            
                
                    // Add leading zeros if necessary
                    hours = (hours < 10) ? "0" + hours : hours;
                    minutes = (minutes < 10) ? "0" + minutes : minutes;
                    seconds = (seconds < 10) ? "0" + seconds : seconds;
                
                    // Add AM or PM based on hours
                    let ampm = (hours >= 12) ? "PM" : "AM";
                    hours = (hours % 12 === 0) ? 12 : hours % 12; // Convert 0 to 12 for 12-hour format
                
                    // Construct the formatted time string
                    let formattedTime = hours + ":" + minutes + ":" + seconds + " " + ampm;
                
                    // Add the time to the appropriate map based on AM/PM
                    if (ampm === 'AM') {
                        if (!this.morningShiftMap[date]) {
                            this.morningShiftMap[date] = [];
                        }
                        if (!this.morningShiftMap[date].includes(formattedTime)) {
                            this.morningShiftMap[date].push(formattedTime);
                        }
                    } else {
                        if (!this.afternoonShiftMap[date]) {
                            this.afternoonShiftMap[date] = [];
                        }
                        if (!this.afternoonShiftMap[date].includes(formattedTime)) {
                            this.afternoonShiftMap[date].push(formattedTime);
                        }
                    }
                
                    // Check if the time already exists in the array for the date, if not, add it
                    if (!this.dateMap[date].includes(formattedTime)) {
                        this.dateMap[date].push(formattedTime);
                    }
                }
                
       
            }
            else{
                this.DateByIA=''
                this.TimeTableDates=[];
                this.TimeTableTimes=[];
                this.timeMap.clear();
                this.ToastEvent('No Active Time Table with selected Input','warning');

            }
        })
        }

        handleTime(event){
          this.AllotmentTime = event.target.value;
        }

        // Function for searching the students and facilities and also validation for existing program batch
        SearchFacility() {
        console.log('this.ProgramBatch',this.ProgramBatch+' Date=> '+this.DateOfExam)
        console.log('Session=> ',this.Session+' Date=> '+this.AllotmentTime)
        if (this.ProgramBatch && this.DateOfExam && this.Session && this.AllotmentTime) {
            console.log('this.ProgramBatch',this.ProgramBatch)
        checkProgramBatchAllotment({
            ActiveProgramBatch: this.ProgramBatch,
            dateOfExam: this.DateOfExam,
            shift: this.Session,
            examTime: this.AllotmentTime
        })
        .then(res => {
            if (res === 'found') {
                this.ToastEvent('Program Batch Already Allotted', 'error');
            } else {
                getAllStudents({
                    ActiveProgramBatch: this.ProgramBatch
                })
                .then(res => {
                    this.DisplayStudents = true;
                    this.EligibleStudentsCount = res.EligibleStudents.length;
                    this.InEligibleStudentsCount = res.InEligibleStudents.length;
                    this.TotalStudents = this.EligibleStudentsCount + this.InEligibleStudentsCount;
                   
                })
                .catch();

                this.seatingArrangements = [];
                getRelatedSchool({
                    ProgramBatchId: this.ProgramBatch,
                    IAType: this.IAType,
                    Session: this.Session,
                    DateOfExam: this.DateOfExam,
                    ExamTime: this.AllotmentTime
                })
                .then(res => {
                    this.facilitiesList = res;
                    this.facilitiesList.sort((a, b) => {
                     // Convert RoomNo (Name) to an integer for proper numerical sorting
                    return parseInt(a.RoomNo) - parseInt(b.RoomNo);
                    });

                    let k = 0; // Initialize index counter
                    let sortedFacility = []; // Array to store sorted facility arrangements

                    for (let i of this.facilitiesList) {
                        this.DisplayFacility = true;
                        k++;

                        const seatArrang = {
                            index: k,
                            Id: i.FacilityId,
                            Name: i.RoomNo,
                            IA_Type__c: this.IAType,
                            Room__c: i.RoomNo,
                            Block__c: i.Block,
                            Floor__c: i.Floor,
                            hed__Capacity__c: i.Capacity,
                            Remaining_Capacity__c: i.RemainingCapacity,
                            Capacity_Needed__c: i.RemainingCapacity,
                            Active__c: false,
                            rveShift__c: i.rveShift__c,
                            Ischanged: false
                        };
                        sortedFacility.push(seatArrang);
                    }
                    this.seatingArrangements = sortedFacility;

                })
                .catch();
            }
        })
        .catch();
    } else {
        this.ToastEvent('Please provide valid required fields', 'warning');
    }
}

// Function for delaying the capacity needed onchange

handledebounce(event) {
    try {
        let value = event.target.value;
        let indexid = event.target.dataset.id;
        let eventtarget = event.target;
        window.clearTimeout(this.timer);
    /*    this.timer = setTimeout(() => {*/
            this.handleInputChange(value, indexid, eventtarget);
     //   }, 1500);
    } catch (error) {
        // Handle the error gracefully
      
    }
}

// Function for handling capacity needed onchange
 handleInputChange(value,index,eventtarget){ 
    try {
    this.seatingArrangements.forEach(e => {
        if(e.index == index) {
            let oldcapacity=0;
            let parseIndex = parseInt(index);
            let selectedseats = parseInt(this.SelectedSeats);
            let totalstudents = parseInt(this.TotalStudents);
            let capacityneededInt = parseInt(e.Capacity_Needed__c);
            let previousValue = e.Capacity_Needed__c ? parseInt(e.Capacity_Needed__c) : 0;
            e.Capacity_Needed__c = value;


            if(selectedseats>=totalstudents && e.Active__c==true){
            selectedseats -= previousValue;
            this.SelectedSeats = selectedseats;
            this.NeededSeats = totalstudents - selectedseats; 
            }

            else if(previousValue!=0 && selectedseats>0 && e.Active__c==true)
                {
                    this.SelectedSeats-=previousValue;
                    this.NeededSeats = totalstudents - this.SelectedSeats; 

                }

            let capacityneeded = e.Capacity_Needed__c;

          
            if(!isNaN(capacityneeded) && capacityneeded!=='' && e.Active__c==true)
            {
                let previouscapacity=0;


                oldcapacity = capacityneededInt
                previouscapacity = this.SelectedSeats+parseInt(e.Capacity_Needed__c)
                this.previouscapacitymap.set(parseIndex,oldcapacity);
                if(this.TotalStudents>=previouscapacity)
                    {

                        this.SelectedSeats = previouscapacity;
                        this.NeededSeats = totalstudents - parseInt(this.SelectedSeats);
                    }
                    else{
                      //  this.SelectedSeats = selectedseats-previousValue;
                     //   e.Capacity_Needed__c = previousValue;
                        this.ToastEvent('You cannot select seats more than students','warning');
                    }
            }
          
            // Check if the value is a valid number
            if (isNaN(capacityneeded) && capacityneeded ==='' && e.Active__c==true) {
                if(this.previouscapacitymap.size!==0)
                {
                this.SelectedSeats = this.SelectedSeats-this.previouscapacitymap.get(parseIndex);

                }

                this.ToastEvent('Please enter a valid number', 'error');
                eventtarget.setCustomValidity('Invalid input');
                this.EnableSubmitButton = true;
                return;
            } else {
                eventtarget.setCustomValidity('');
            }
            
            if (capacityneeded > e.hed__Capacity__c) {
                eventtarget.setCustomValidity('Capacity Exceeded');
                this.EnableSubmitButton = true;
            } else {
                e.Ischanged = true;
    
                if (capacityneeded === '' || capacityneeded == 0) {
                    e.Remaining_Capacity__c = parseInt(e.hed__Capacity__c);
                    eventtarget.setCustomValidity('');
                }
                if (capacityneeded != 0) {
                    e.Remaining_Capacity__c = parseInt(e.hed__Capacity__c) - e.Capacity_Needed__c;
                    if (isNaN(e.Remaining_Capacity__c)) {
                        this.ToastEvent('Please enter a valid number', 'error');
                    }
                    else{
                        this.EnableSubmitButton = false;
                    }
                }
            }
                eventtarget.reportValidity();

                }
});
}
catch(error){
}
}
    // Function for handling select room checkbox
    handleActiveCheckBoxChange(event) {
        try{
        const Active = event.target.checked;
        const index = event.target.dataset.id;
        this.seatingArrangements.forEach(e => {
                if(e.index == index) {
                        e.Active__c = Active;
                        let previouscapacity=0;
                        // Check if Capacity_Needed__c is not null and is a number

                        if (e.Capacity_Needed__c != null && !isNaN(e.Capacity_Needed__c) && Active==true && e.Capacity_Needed__c!=='') {
                            previouscapacity=this.SelectedSeats+parseInt(e.Capacity_Needed__c);
                            if (parseInt(this.TotalStudents) >= parseInt(previouscapacity)) {
                                this.SelectedSeats =previouscapacity;
                                this.NeededSeats = parseInt(this.TotalStudents) - parseInt(this.SelectedSeats);
                                this.isCapacityAdded[index]=previouscapacity;
                            } else {
                            
                                this.ToastEvent('You cannot select seats more than students','warning');
                                this.isCapacityAdded[index]=0;
                            }
                            
                        }
                        
                        else{
                            if(parseInt(e.Capacity_Needed__c)>0 && !isNaN(parseInt(e.Capacity_Needed__c))){

                                    if(this.isCapacityAdded[index]!=0)
                                        {
                                    this.SelectedSeats -=parseInt(e.Capacity_Needed__c);
                                    this.NeededSeats = parseInt(this.TotalStudents) - parseInt(this.SelectedSeats);
                                        }

                            
                            }
                        }

                }
        });
    }
    catch(error){
    }
}
    // Function for handling if somebody restarts the process from IA then this will work

    handleDateBasedOnIAChange(){
        getRevaExamNotifications({
            IAType:this.IAType,
            Session:this.Session,
            ProgramId:this.ProgramBatch
        }).then(res=>{
        if(res.length>0)
        {
            this.DateByIA=''
            this.timeMap.clear();    
            for(let i=0;i<res.length;i++)
            {
                const exists = this.TimeTableDates.find(entry => entry.value === res[i].hed_Date__c);

                if (!exists) {
                    this.TimeTableDates = [...this.TimeTableDates, { value: res[i].hed_Date__c, label: res[i].hed_Date__c }];

                }
                this.timeMap.set(res[i].hed_Date__c, res[i].hed_Start_Time__c);
            }
        }
        else{
            this.DateByIA=''
            this.timeMap.clear();
            this.ToastEvent('No Active Time Table with selected Input','warning');
        }
    })
    }

    //Function for calling apex to create room allotments and validation 

    handleSubmit() {
        // Filter out inactive facilities and calculate total room capacities
        let finalSeatingArrangement = this.seatingArrangements.filter(facility => facility.Active__c);
        let roomCapacities = 0;
        let capacityneeded=0;
        let conditionsatisfied = false;
        
        // Create a map to store facility Ids with their updated capacities
        let facilityMap = new Map();
    
        // Populate facilityMap and calculate total room capacities
        for (let facility of finalSeatingArrangement) {
            // Check if the facility capacity has changed
          //  if (facility.Ischanged) {
                let capacity = parseInt(facility.Capacity_Needed__c);
                if (!isNaN(capacity)) {
                    capacityneeded+= capacity;
                    facilityMap.set(facility.Id, capacity);
                    roomCapacities += capacity;
                } else {
                }
       
            delete facility.Ischanged;
        }
        
        // Perform updates if there are facilities with updated capacities
        if (facilityMap.size > 0 &&  (roomCapacities==this.TotalStudents)) {
            conditionsatisfied = true
            updateFacilities({
                FacilityWithUpdatedCapacity: facilityMap,
                ProgramBatchId: this.ProgramBatch
            })
            .then(res => {
            });
        }
        else if(roomCapacities<this.TotalStudents){

            this.ToastEvent('Room capacities should not less than students','error');
        }
        else{
            this.ToastEvent('Room capacities should not more than students','error');

        }
            
        if(conditionsatisfied){
        // Fetch student data
        getAllStudents({
            ActiveProgramBatch: this.ProgramBatch
        })
        .then(res => {
            
            let EligibleStudents = [...res.EligibleStudents];
            let InEligibleStudents = [...res.InEligibleStudents];
           
            // Proceed if there are enough rooms for students
            if (res.SizeOfStudents <= roomCapacities) {
                // Get the selected exam date and format it
                let dateObject = new Date(this.DateOfExam);
                let formattedDate = dateObject.toISOString().substring(0, 10);
    
                // Determine shift type based on the exam time
                let ShiftType = '';
                if (this.timeMap.has(formattedDate)) {
                    let hours = Math.floor(this.timeMap.get(formattedDate) / (1000 * 60 * 60));
                    ShiftType = hours < 12 ? 'Morning' : 'Afternoon';
                }
                
                // Create or update room allotments
                createOrUpdateAllotment({
                    ActiveProgramBatch: this.ProgramBatch,
                    UpdateExistingCapacity: Array.from(facilityMap),
                    facilityList: finalSeatingArrangement,
                    EligibleStudents: EligibleStudents,
                    InEligibleStudents: InEligibleStudents,
                    dateOfExam: dateObject,
                    shift: this.Session,
                    examTime: this.AllotmentTime
                })
                .then(res => {
                    if (res === 'Record Exist') {
                        this.ToastEvent('Room allotment already exists', 'error');
                    } else if (res === 'Allotments created or updated successfully') {
                        this.ToastEvent('Room allotted successfully', 'success');
                        setTimeout(() => {
                            window.location.reload();
                        }, 2000);
                    } else {
                        this.ToastEvent('Something went wrong', 'error');
                    }
                })
                .catch(error => {
                    console.log('586=> ')

                    this.ToastEvent(error, 'error');
                });
                
                this.EnableAllotmentButton = false;
            } else {
                this.ToastEvent('Selected room capacity is not enough for students', 'error');
            }
        
        })
        .catch(error => {
            console.log('596=> ')
            this.ToastEvent(error, 'error');
        });
    }
    
    }
        ToastEvent(msg,variant){
            const event = new ShowToastEvent({
                                    title: 'Seating Room Status',
                                    message: msg,
                                    variant: variant
                                });
                                this.dispatchEvent(event);
          }
            openModal() {  
        this.showModal = true;
    }
    
       handleDataPassed(event) {
       this.showModal = event.detail.data;
        // Do something with passedData
    }  

    // Function for Download Allotment button
    openVfPage() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
    
    // Parameter(Date) for vf page
    handleAllotmentDate(event){
        this.AllotmentDate = event.target.value
    }

    // Function for B-form
    RenderAttendancePdf(){
        const vfPageUrl = '/apex/RoomAllotmentPdf?renderAs=pdf&DatePass=' + encodeURIComponent(this.AllotmentDate)+ '&TimePass=' 
    + encodeURIComponent(this.AllotmentTime);
        // Open the URL in a new browser window
        window.open(vfPageUrl, '_blank');
    }

    // Function for NoticeBoard sheet
    RenderNoticeBoardPdf(){
        const vfPageUrl = '/apex/NoticeBoardPdf?renderAs=pdf&DatePass=' + encodeURIComponent(this.AllotmentDate)+ '&TimePass=' 
    + encodeURIComponent(this.AllotmentTime);
        // Open the URL in a new browser window
        window.open(vfPageUrl, '_blank');
    }
    }