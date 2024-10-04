import { LightningElement,track,api,wire } from 'lwc';
import searchProgramBatch from '@salesforce/apex/rveFacultyTimeTableController.searchProgramBatch';
import getActiveSemester from '@salesforce/apex/rveFacultyTimeTableController.getActiveSemester';
import getCourses from '@salesforce/apex/rveFacultyTimeTableController.getCourses';
import IATimeTableCreation from '@salesforce/apex/rveFacultyTimeTableController.IATimeTableCreation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'
export default class RveIATimeTableUpdated extends NavigationMixin(LightningElement) {

    @track searchKey = '';
    @track recordsList;
    @api selectedRecordId;
    @api selectedValue;
    @track message;
    @track semesterOptions = [];
    @track value;
    @track courses=[];
    @track coursesDate=[];
    @track coursesEndTime = [];
    @track coursesStartTime = [];
    @ track defaultValue;
    @track examDatevalue;
    @track endtimeValue
    @track starttimeValue
    @ track isDisabled=true;
    currentDate;

    get IAtypeOptions() {
        return [
            { label: 'IA 1', value: 'IA 1' },
            { label: 'IA 2', value: 'IA 2' }
           
        ];
    }

    handleIAType(event) {
        this.defaultValue = event.detail.value;
    }

    removeRecordOnLookup(event) {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.value = null;
        this.coursesDateDetails=null;
        this.coursesStartTimeDetails=null;
        this.coursesEndTimeDetails=null;
        this.defaultValue = null;
        //this.isDisabled = true;
        this.onSeletedRecordUpdate();
    }
    handleChange(event) {
        this.value = event.target.value;
    }

    handleKeyChange(event) {
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        searchProgramBatch({ searchKey: this.searchKey })
        .then((result) => {
            if (result.length === 0) {
                this.recordsList = [];
                this.message = "No Records Found";
            } else {
                this.recordsList = result;
                this.message = "";
            }
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.recordsList = undefined;
        });
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        console.log('Semester=> '+this.selectedRecordId);
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        if (this.selectedRecordId && this.selectedValue) {
            const selectedProgram = this.recordsList.find(route => route.Id === this.selectedRecordId)
        }

        const passEventr = new CustomEvent('recordselection', {
            detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
        });
        this.dispatchEvent(passEventr);
    }

    onSeletedRecordUpdate() {
        if (this.selectedRecordId && this.selectedValue) {
            const selectedProgram = this.recordsList.find(route => route.Id === this.selectedRecordId)
        }

        const passEventr = new CustomEvent('recordselection', {
            detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
        });
        this.dispatchEvent(passEventr);
    }

    @wire(getActiveSemester, { selectedValue: '$selectedRecordId' })
    wiredSemester({ data, error }) {
        if (data) {

            this.semesterOptions = data.map(hed__Term__c => ({
                label: hed__Term__c.Name,
                value: hed__Term__c.Id

            }));
        }

        if (error) {
        }
    }

    @wire(getCourses, { activeSemester: '$value' })
    wiredCourses({ data, error }) {
        if (data) {
          //  this.courses = data;
          let k=0;
            for(let i of data)
                {
                  const courseInstance = {
                    index:k,
                    CourseId: i.hed__Course__c,
                    CourseIdName : i.hed__Course__r.hed__Course_ID__c,
                    CourseName: i.hed__Course__r.Name,
                    ExamDate: null,
                    StartTime:null,
                    EndTime:null
                    
                  }
                  k++;
                  this.courses.push(courseInstance);
                }

        }
        if (error) {
        }
    }

    handleStartTimeChange(event){
        const fieldValue = event.target.value;
        const index = parseInt(event.target.dataset.index);
        this.courses.forEach(e => {
           if(e.index == index)
            {
                e.StartTime = fieldValue
            }
        })
    }

    handleEndTimeChange(event){
        const target= event.target;
        const fieldValue = event.target.value;
        const index = parseInt(event.target.dataset.index);
        console.log('index=> '+index);

        if(fieldValue < this.courses[index].StartTime)
        {
            event.target.value = this.courses[index].StartTime;
            target.setCustomValidity("End time cannot be earlier than start time.");
            target.reportValidity();
        }
        else if(this.courses[index].StartTime == null){
            
            event.target.setCustomValidity("Please select start time.");
            event.target.reportValidity();
        }
        else{

            event.target.setCustomValidity("");
            this.courses.forEach(e => {
                if(e.index == index)
                 {
                     e.EndTime = fieldValue
                 }
             })
        }
      
    }

    handleInputChange(event) {
        const target = event.target;
        const fieldValue = event.target.value;
        const index = parseInt(event.target.dataset.index);
        const currentDate = new Date().toISOString().split('T')[0]; // Get current date
        if (!fieldValue || fieldValue <= currentDate) {
            // Prevent the user from selecting a previous date or if no value is present
            target.setCustomValidity("Please select a future date.");
            target.reportValidity();
            return true; // Disable button if date is not a future date or no value is present
        } else {
            // Clear any previous validation message for date field
            target.setCustomValidity("");
            this.courses.forEach(e => {
                if(e.index == index)
                 {
                     e.ExamDate = fieldValue
                 }
             })
        }
       
    }

handleSubmit(){
    let checkNull;
    for(let i of this.courses)
        {
            if(i.StartTime!=null && i.EndTime!=null && i.ExamDate!=null)
                checkNull = true;
        }
    if(checkNull)
        {
            let TimeTableData = this.courses.filter(course => !(course.ExamDate == null && course.StartTime == null && course.EndTime == null));

            let TimeTableDataApex = JSON.stringify(TimeTableData);
            console.log('TimeTableData=> '+TimeTableDataApex);
            console.log('NotificationName=> '+this.selectedValue+' semester=> '+this.value+' program=> '+this.selectedRecordId+' IAtype=> '+this.defaultValue)
            IATimeTableCreation({
                notificationName: this.selectedValue,
                semesterActive: this.value,
                programBatch: this.selectedRecordId,
                TimeTableData:TimeTableDataApex,
                Iatypevalue:this.defaultValue
            })
            .then(res=>{
                console.log('Res=> '+res);
                if(res=='success')
                    {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'IA TimeTable Created Successfully!!',
                                variant: 'success'
                    
                            })
                        );

                       this[NavigationMixin.Navigate]({
                       type: 'standard__navItemPage',
                       attributes: {
                        apiName: 'Exam_Schedule_Time_Table'
                       }
                       })
                    }
                    else{
                        this.showtoast('Something went wrong......');
                    }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occurred While Creation of IA TimeTable',
                        variant: 'error'
                    })
                );
            }) 
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Provide Value',
                    variant: 'error'
                })
            );
        }
}

showtoast(variant){
    

    //navigate to exam schedule time table
    
}
}