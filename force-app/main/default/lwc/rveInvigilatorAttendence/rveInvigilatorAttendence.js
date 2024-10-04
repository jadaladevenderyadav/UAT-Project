import { LightningElement, wire, track,api } from 'lwc';
import getRoomDetails from '@salesforce/apex/rve_InvigilatorAttendenceController.getRoomDetails';
import getProgramBatchTimetableMap from '@salesforce/apex/rve_InvigilatorAttendenceController.getProgramBatchTimetableMap';
import getCustomSettings from '@salesforce/apex/rve_InvigilatorAttendenceController.getCustomSettings';
import insertAttendenceEvent from '@salesforce/apex/rve_InvigilatorAttendenceController.insertAttendenceEvent';
import updateAttendanceCheckbox from '@salesforce/apex/rve_InvigilatorAttendenceController.updateAttendanceCheckbox';
import timeconvertion from '@salesforce/apex/rve_InvigilatorAttendenceController.timeconvertion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class AttendanceComponent extends LightningElement {
    @track contactlist = [];
    @track hasRecords=false;
    Settingval;
    @api examdate;
    @api roomname;
    @api shift;
    @api starttime;
    @api endtime;
    @api millisecendtime;
    @api millisecstarttime;
    @api invigilatorrecordid;
    programBatchTimetableMap;
    @track mapData= [];
     @track mapDataconnection= [];
     @track contactCourseConnectionIdMap;
    
 
    roomIds = []; // Array to hold room Ids

    @wire(getCustomSettings)
    wiredgetCustomSettings({ error, data }) {
        if (data) {
            this.Settingval = data;

        } else if (error) {
        }
    }
    


    @wire(getRoomDetails, { examdate: '$examdate', shift: '$shift', roomname: '$roomname' , starttime: '$starttime' , endtime: '$endtime'})

    wiredRoomDetails({ error, data }) {
        if (data) { 
            if (data.length > 0) {
        this.hasRecords=true

         
                const groupedContacts = {};
                data.forEach(contact => {
                    if (!groupedContacts[contact.Program_Batch__r.Name]) {
                        groupedContacts[contact.Program_Batch__r.Name] = [];
                    }
                    groupedContacts[contact.Program_Batch__r.Name].push({
                        SRNNo: contact.SRN_Number__c,
                        cname: contact.Name,
                        Attendancecheckbox: true,
                        malpracticescheckbox: false,
                        description: '',
                        contactid: contact.Id
                    });

                });
                this.contactlist = Object.keys(groupedContacts).map(batchName => ({
                    batchName: batchName,
                    contacts: groupedContacts[batchName]
                }));

            this.roomIds = data.map(contact => contact.Id); // Populate room Ids array
            }
            else {
                this.hasRecords = false;
                // Handle error
            }
        }
    }
 
 
    @wire(getProgramBatchTimetableMap, { examdate: '$examdate', shift: '$shift', roomname: '$roomname' , starttime: '$starttime' , endtime: '$endtime'})

    wiredProgramBatchTimetableMap({ error, data }) {
        {
        if (data) {
            console.log('data**',JSON.stringify(data));

            this.programBatchTimetableMap = data;
            this.contactCourseConnectionIdMap = data.contactCourseConnectionIdMap;            
            this.programBatchCourseNameMap = data.programBatchCourseNameMap;

              for(var key in this.programBatchCourseNameMap){
                this.mapData.push({value:this.programBatchCourseNameMap[key], key:key});
            }
            for(var key in this.contactCourseConnectionIdMap){
                this.mapDataconnection.push({value:this.contactCourseConnectionIdMap[key], key:key});
            }
            // Process the map data as needed
        } else if (error) {
            console.log('error=> '+error);
        }
    }
    }

 
// Handle changes in attendance checkbox
handleAttendanceChange(event) {
    const batchIndex = event.target.dataset.batchIndex;
    const contactIndex = event.target.dataset.contactIndex;
    const checked = event.target.checked;
 
    this.contactlist[batchIndex].contacts[contactIndex].Attendancecheckbox = checked;
 
}

// Handle changes in Malpracticesattendance checkbox
handlemalpracticesChange(event) {
    const batchIndex = event.target.dataset.batchIndex;
    const contactIndex = event.target.dataset.contactIndex;
    const Malpracticeschecked = event.target.checked;
 
    this.contactlist[batchIndex].contacts[contactIndex].malpracticescheckbox = Malpracticeschecked;

}
 
 
// Handle changes in description input
handleDescriptionChange(event) {
    const batchIndex = event.target.dataset.batchIndex;
    const contactIndex = event.target.dataset.contactIndex;
    const description = event.target.value;
 
    this.contactlist[batchIndex].contacts[contactIndex].description = description;
 
} 
 
async saveAttendance() {    
            
      let attendanceEvent = [];
    // Create a new Date object representing the current date and time
    const currentDate = new Date();
     // Get only the date portion in "YYYY-MM-DD" format
    const formattedDate = currentDate.toLocaleDateString('en-US');
        const options = { timeZone: 'Asia/Kolkata', year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' };
      //  const formattedDate = currentDate.toLocaleString('en-IN', options);
     console.log('date >>>', JSON.stringify(formattedDate)); 


    this.contactlist.forEach(batchItem => {
    batchItem.contacts.forEach(contact => {
        console.log('0');

       // Find the corresponding connection ID from mapDataconnection
        let courseConnectionId = null;
        for (let key in this.contactCourseConnectionIdMap) {
            if (key === contact.contactid) {
                courseConnectionId = this.contactCourseConnectionIdMap[contact.contactid];
                console.log('course connection Id >>>', courseConnectionId);
                break;
            }
            console.log('key is',key);
             console.log('5',contact.Attendancecheckbox ? 'Present' : 'Absent');
             console.log('room',this.roomname);
            console.log('courseconnectionId',courseConnectionId);
             console.log('mal',contact.malpracticescheckbox);
              console.log('milisec',this.millisecstarttime);
                console.log(contact.description+' Date=> '+formattedDate);
               console.log('mili16',this.millisecendtime);
                            
        }

        attendanceEvent.push({
            
            hed_IA_Remarks__c: contact.description,
            hed__Contact__c: contact.contactid,
            hed__Date__c: formattedDate,
            hed__Attendance_Type__c: contact.Attendancecheckbox ? 'Present' : 'Absent',
            hed_Malpractice__c: contact.malpracticescheckbox,
            hed__Start_Time__c: this.millisecstarttime,
            hed__End_Time__c: this.millisecendtime,
            rve_Room_Number__c: this.roomname,
            hed__Course_Connection__c: courseConnectionId, // Add course connection ID
            Exam_Attendance__c: true
            
        });
    });
});

        console.log('6');
        console.log('attendance>>>', JSON.stringify(attendanceEvent));


    if (attendanceEvent.length > 0) {
        console.log('1');
        insertAttendenceEvent({ attendance: attendanceEvent })
            .then(result => {
 
                // Show success toast message
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Records inserted successfully',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
                location.reload();
 
            })
            .catch(error => {
                // Handle error
            });


            if(this.invigilatorrecordid != null){
                console.log('2');
                updateAttendanceCheckbox({ recordId: this.invigilatorrecordid })
              .then(result => {

           })
           .catch(error => {
                // Handle error
            });

            }
    }
}


}