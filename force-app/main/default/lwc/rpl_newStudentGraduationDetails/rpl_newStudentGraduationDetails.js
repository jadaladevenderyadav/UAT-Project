import { LightningElement, track, wire, api } from "lwc";
import RevaLogo from '@salesforce/resourceUrl/REVA_LOGO';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
/*STUDENT REGISTRATION OBJECT SCHEMA */
import STUDENT_REGISTRATION_OBJECT from "@salesforce/schema/Rpl_Student_Registration__c";
/*UG STREAM,INTERESTED IN PLACEMENT,BRANCH NAME AND GENDER DETAILS SCHEMA */
import INTERESTED_IN_PLACEMENT from "@salesforce/schema/Rpl_Student_Registration__c.Rpl_Interested_in_placement__c";
import UG_STREAM from "@salesforce/schema/Rpl_Student_Registration__c.Rpl_UG_Stream__c";
import COURSE_NAME from "@salesforce/schema/Rpl_Student_Registration__c.Course_Name__c";
/*Apex call*/
import fetchContactDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getContactDetails';
import fetchStudentRegDetailsfrom from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails'
import updateDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.updateStudentRegDetails';
/*Get Contact Details Based on the User Login*/
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rpl_newStudentGraduationDetails extends  NavigationMixin(LightningElement) {
    @api studentRegRecordId;
    @track studentRegform = {}; // Variable for storing the data into the object.
    showStudentDetails = true;
    isStudentDetails = "slds-section slds-is-close";
    showAcidemicDetails = true;
    show10DetailsAccordion = true;
    isAcidemicDetails = "slds-section slds-is-close";
    is10DetailsAccordion = "slds-section slds-is-close";
    contactId;
    isTenthDocumentUpload;
    show12DetailsAccordion =true;
    is12DetailsAccordion = "slds-section slds-is-close";
    isNotEmpty=false;
    showBtechDetails = false;
    isBtechDetails = "slds-section slds-is-close";
    showMtechDetails = true;
    isMtechDetails = "slds-section slds-is-close";
    isUGDetails = "slds-section slds-is-close";
    showUGDetails = false;
    isSaveTrue = true;
    showmbaDetails=false;
    isMBADetails = "slds-section slds-is-close"
    @track logo = RevaLogo;
    Btech1stsemreq = false;
    acitveSemester;
    @track semRequiredList = [];
      isSubmitButtonDisabled = false;


    //studentRegform.Rpl_UG_Stream__c
  
    /*Define a mapping of selectedName to the corresponding property in studentRegform*/
    fieldMapping = {
      'Name': "Name",
      "Personal Mail ID"  : "Rpl_Personal_Mail_ID__c",
      "University Mail Id": "Rpl_University_Mail_ID__c",
      "10th Percentage"   :"Rpl_10th_Percentage__c",
      "10th Board Name"   : "Rpl_10th_Board_Name__c",
      "10th Year of passing":"Rpl_10th_Year_of_passing__c",
      "Interested In Placement":"Rpl_Interested_in_placement__c",
      "Branch":"Rpl_Branch__c",
      "12th Percentage":"Rpl_12th_Percentage__c",
      "12th Board Name":"Rpl_12th_Board_Name__c",
      "12th Year of passing":"Rpl_12th_Year_of_passing__c",
      "Course Name":"Course_Name__c",
      "Sem 1st CGPA":"Rpl_Sem_1_CGPA__c",
      "Sem 2nd CGPA":"Rpl_Sem_2_CGPA__c",
      "Sem 3rd CGPA":"Rpl_Sem_3_CGPA__c",
      "Sem 4th CGPA":"Rpl_Sem_4_CGPA__c",
      "Sem 5th CGPA":"Rpl_Sem_5_CGPA__c",
      "Sem 6th CGPA":"Rpl_Sem_6_CGPA__c",
      "Sem 7th CGPA":"Rpl_Sem_7_CGPA__c",
      "Sem 8th CGPA":"Rpl_Sem_8_CGPA__c",
      "Pan Card No":"Rpl_Pan_Card_No__c",
      "UG Board Name/University Name":"Rpl_UG_Board_Name_University_Name__c",
      "UG College Name":"Rpl_UG_College_Name__c",
      "UG Degree":"Rpl_UG_Degree__c",
      "UG Year of Graduation":"Rpl_UG_Year_of_Graduation__c",
      "UG CGPA":"Rpl_UG_CGPA__c",
      "UG Stream":"Rpl_UG_Stream__c",
      "PG 1st Sem CGPA":"Rpl_PG1_Sem_CGPA__c",
      "PG 2nd Sem CGPA":"Rpl_PG2_Sem_CGPA__c",
      "PG 3rd Sem CGPA":"Rpl_PG3_Sem_CGPA__c",
      "Current Backlogs": "Rpl_Current_Backlogs__c",
      "PG 4th Sem CGPA":"Rpl_PG4_Sem_CGPA__c",
      "Diploma College Name":"Rpl_DiplomaName__c",
      "Diploma Percentage":"Rpl_Diploma_Number__c",
      "Current Backlogs" : "Rpl_Current_Backlogs__c",
      "Cleared Backlogs" : "Rpl_Cleared_Backlogs__c",
      "Total Backlogs" : "Rpl_Total_Backlogs__c",
      "Education Gap" : "Rpl_Education_Gap__c"
    };


   @wire(getObjectInfo, { objectApiName: STUDENT_REGISTRATION_OBJECT })
   objectInfo;

   /**Wire Calling for Interested In Placement Picklist Values */
   @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId", // pass id dynamically
    fieldApiName: INTERESTED_IN_PLACEMENT,
  })
  interestedinplacement;

   /**Wire Calling for Branch */
   @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId", // pass id dynamically
    fieldApiName: COURSE_NAME,
  })
  courseName;
  
  /**Wire Calling for Stream */
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId", // pass id dynamically
    fieldApiName: UG_STREAM,
  })
  ugStreamValues;
    /*Create a mapping of section IDs to their respective state properties*/
    toggleSectionName = {
      studentDetails: "isStudentDetails",
      acidemicDetails: "isAcidemicDetails",
      tenInputsDetails:"is10DetailsAccordion",
      twelveInputsDetails : "is12DetailsAccordion",
      BtechDetails:"isBtechDetails",
      MtechDetails : "isMtechDetails",
      UGDetails:"isUGDetails",
      MBADetails :"isMBADetails"
    }; 
   
    // constructor(){
    //     super();
    //     this.fetchStudentRegDetailsfrom1('0031e00000PDjTlAAL');
    // }
  
    renderedCallback(){
       this.toggleSection;
    }
     /**Wire Calling of Object Picklist Values */
     @wire(getObjectInfo, { objectApiName: STUDENT_REGISTRATION_OBJECT })
     objectInfo;
  
    /*Get Login User Id*/
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    userec({ error, data }) {
      if (error) {
        this.error = error;
        console.error('Error', error);
      } else if (data) {
        this.contactId = data.fields[CONTACT_ID.fieldApiName].value;
        
        this.fetchStudentRegDetailsfrom1(this.contactId);
        console.log('ContactId', this.contactId);
      }
    }

    checkoffCourseName(){
      console.log('courseName'+JSON.stringify(this.studentRegform.Course_Name__c));
      let courseName = this.studentRegform.Course_Name__c;
      if(courseName.includes("BTech")){
         console.log('');
          this.showBtechDetails = true;
          this.showMtechDetails = false;
          this.showmbaDetails = false;
          this.showUGDetails = false;
      }
      else if(courseName.includes('MTech')){
        console.log('MTech DETAILS'+this.studentRegform.Course_Name__c);
            this.showMtechDetails = true;
            this.showBtechDetails =false;
            this.showmbaDetails = false;
            this.showUGDetails = false;
      }
      else if(courseName.includes('MBA')){
        console.log('MBA DETAILS'+this.studentRegform.Course_Name__c);
            this.showmbaDetails = true;
            this.showMtechDetails = false;
            this.showBtechDetails =false;
            this.showUGDetails = false;
            console.log('showmbaDetails'+this.showmbaDetails);
      }
      else if(courseName.includes("UG")){
           console.log('UG DETAILS'+this.studentRegform.Course_Name__c);
            this.showUGDetails = true;
            this.showmbaDetails = false;
            this.showMtechDetails = false;
            this.showBtechDetails =false; 
      }
      
    }
  
  
  /*Handle Change of the InputFields */
    handleAllFieldChange(event) {
      const fieldName = this.fieldMapping[event.target.label];
      if (fieldName) {
        this.studentRegform[fieldName] = event.target.value;      
      console.log('event.details.page'+JSON.stringify(this.studentRegform));
      console.log('ContactId'+this.contactId);
      console.log("Show Details",this.showMtechDetails ,this.showBtechDetails );
      console.log('this.studentRegform.Rpl_UG_Year_of_Graduation__c.le'+this.studentRegform.Rpl_UG_Year_of_Graduation__c.length);
    }
  }
   
  
    toggleSection(event) {
      let selectedToggle = this.toggleSectionName[event.currentTarget.dataset.id];
      console.log('selectedToggle'+selectedToggle);
      if (selectedToggle != undefined) {
        this[selectedToggle] =this[selectedToggle] === "slds-section slds-is-close"? "slds-section slds-is-open": "slds-section slds-is-close";
        console.log('selectedToggle'+this[selectedToggle]);
      }
    }
    
  


  validateRequiredFields() {
    this.isNotEmpty = false;
    switch (this.studentRegform.Course_Name__c) {
        case 'MTech':
        case 'MBA':
          this.checkRequiredFields([
            'Rpl_UG_Board_Name_University_Name__c',
                'Rpl_UG_College_Name__c',
                'Rpl_UG_Degree__c',
                'Rpl_UG_Year_of_Graduation__c',
                'Rpl_UG_CGPA__c',
                'Rpl_UG_Stream__c',
          ])
          break;
        case 'MSC':
        case 'MCA':
        case 'MTech/MSC/MCA':
            this.checkRequiredFields([
                'Rpl_UG_Board_Name_University_Name__c',
                'Rpl_UG_College_Name__c',
                'Rpl_UG_Degree__c',
                'Rpl_UG_Year_of_Graduation__c',
                'Rpl_UG_CGPA__c',
                'Rpl_UG_Stream__c',
                'Rpl_PG1_Sem_CGPA__c'
                // 'Rpl_PG2_Sem_CGPA__c',
                // 'Rpl_PG3_Sem_CGPA__c',
                // 'Rpl_PG4_Sem_CGPA__c'
            ]);
            console.log('student Ref CHECK ', typeof(this.studentRegform.Rpl_UG_Year_of_Graduation__c.toString()))
            let yearOfGraduation = this.studentRegform.Rpl_UG_Year_of_Graduation__c.toString();
            if(yearOfGraduation.length!=4){
                  this.showToast('Year of Graduation must contains only 4 digits Value');
                  this.isNotEmpty = true;
            }
           else{
                 this.isNotEmpty  = false;
            }
            
            break;
        case 'BTech':
            this.checkRequiredFields([
                  'Rpl_Sem_1_CGPA__c',
                  'Rpl_Sem_2_CGPA__c',
                  'Rpl_Sem_3_CGPA__c',
                  'Rpl_Sem_4_CGPA__c'
                   // 'Rpl_Sem_5_CGPA__c',
                  // 'Rpl_Sem_6_CGPA__c',
                  // 'Rpl_Sem_7_CGPA__c',
                  // 'Rpl_Sem_8_CGPA__c'
              ]);
              break;
            //this.overPercentageCalculation(this.acitveSemester);
        case 'UG':
            this.checkRequiredFields([
                'Rpl_Sem_1_CGPA__c',
                'Rpl_Sem_2_CGPA__c',
                 'Rpl_Sem_3_CGPA__c'
                // 'Rpl_Sem_4_CGPA__c',
                // 'Rpl_Sem_5_CGPA__c',
                // 'Rpl_Sem_6_CGPA__c'
            ]);
            break;
        default:
            break;
    }
}

checkRequiredFields(fields) {
    console.log('check For Requried Fields'+fields);
    for (const field of fields) {
        if (this.studentRegform[field] === undefined) {
            this.showToast('Please populate the required fields');
            this.isNotEmpty = true;
        }
    }
  }

  
    showToast(fieldName) {
        const event = new ShowToastEvent({
            title: 'Error',
            message:fieldName,
        });
        this.dispatchEvent(event);
  }  
 
  showToastSuccess(fieldName) {
    const event = new ShowToastEvent({
      message: fieldName,
      variant: 'success'
    });
    this.dispatchEvent(event);
  }


  /*Save Button Functionality  */
  handleSaveButton(event){
    this.validateRequiredFields();
    if(this.isNotEmpty==false){ // Here are updating the Student Registration Records
      this.studentRegform.RPL_IsGraduationComplete__c = true;
      this.overAllPercentageCalculation(this.studentRegform.Course_Name__c);
      updateDetails({stdRegDetails:this.studentRegform})
      .then(result => {
        console.log('result'+result);
        this.studentRegRecordId = result;
        this.showToastSuccess('Graduation Detail Saved Successfully');
        this.handleGraduationDetailsComplete();       
      })
      .catch(error => {
          console.log('error'+JSON.stringify(error));
      });
    }
  }


  handleCancelButton(){
      this.studentRegform.RPL_IsGraduationComplete__c = false;
      //this.studentRegform.Rpl_isStudentDetailsComplete__c = false;
      console.log('Inside the HANDLE Cancel Button ********',JSON.stringify(this.studentRegform));
      //this.validateRequiredFields();
      /*Child to Parent Communicating from Graduation to Student Detail */
      //if(this.isNotEmpty==true){return null};
     /*  updateDetails({stdRegDetails:this.studentRegform})
           .then(result => {
              console.log('result'+result);
              this.studentRegRecordId = result;
              this.isSaveTrue = true;
      })
             .catch(error => {
             console.log('error'+JSON.stringify(error));
       }); */

       this.handleGraduationPreviousPage();

  }

  /*Communicating from Graduation Component to Path Component */
  handleGraduationDetailsComplete() {
    const factor = true;
    this.dispatchEvent(new CustomEvent('graduationprocesscomplete', {
      detail: {message:factor}
    }));
  }

  /*Communicating from Graduation Component to Path Component Page*/
  handleGraduationPreviousPage(){
    const factor = false;
    this.dispatchEvent(new CustomEvent('graduationpreviouspage', {
      detail: {message:factor}
    }));
  }


  //fetch the Details

  fetchStudentRegDetailsfrom1(studentId){
    fetchStudentRegDetailsfrom({ recordId :studentId})
    .then(result => {
        console.log('result'+JSON.stringify(result));
        //Program_Name__c
        result.forEach(element => {
          this.studentRegform.Id = element.Id
          this.studentRegform.Rpl_SRN__c = element.Rpl_SRN__c;
          this.studentRegform.Name = element.Name;
          this.studentRegform.Rpl_Gender__c = element.Rpl_Gender__c;
          this.studentRegform.Rpl_Date_of_Birth__c = element.Rpl_Date_of_Birth__c;
          this.studentRegform.Rpl_Contact_No__c = element.Rpl_Contact_No__c;
          this.studentRegform.Rpl_School__c = element.Rpl_School__c;
          this.studentRegform.Rpl_Personal_Mail_ID__c = element.Rpl_Personal_Mail_ID__c;
          this.studentRegform.Course_Name__c = element.Course_Name__c;
          this.studentRegform.Rpl_University_Mail_ID__c = element.Rpl_University_Mail_ID__c;
          this.studentRegform.Rpl_10th_Percentage__c = element.Rpl_10th_Percentage__c;
          this.studentRegform.Rpl_10th_Board_Name__c = element.Rpl_10th_Board_Name__c;
          this.studentRegform.Rpl_10th_Year_of_passing__c = element.Rpl_10th_Year_of_passing__c;
          this.studentRegform.Rpl_Interested_in_placement__c = element.Rpl_Interested_in_placement__c;
          this.studentRegform.Rpl_Branch__c = element.Rpl_Branch__c;
          this.studentRegform.Rpl_12th_Percentage__c = element.Rpl_12th_Percentage__c;
          this.studentRegform.Rpl_Sem_1_CGPA__c = element.Rpl_Sem_1_CGPA__c;
          this.studentRegform.Rpl_Sem_2_CGPA__c = element.Rpl_Sem_2_CGPA__c;
          this.studentRegform.Rpl_Sem_3_CGPA__c = element.Rpl_Sem_3_CGPA__c;
          this.studentRegform.Rpl_Sem_4_CGPA__c  = element.Rpl_Sem_4_CGPA__c;
          this.studentRegform.Rpl_Sem_5_CGPA__c  = element.Rpl_Sem_5_CGPA__c;
          this.studentRegform.Rpl_Sem_6_CGPA__c  = element.Rpl_Sem_6_CGPA__c;
          this.studentRegform.Rpl_Sem_7_CGPA__c  = element.Rpl_Sem_7_CGPA__c;
          this.studentRegform.Rpl_Sem_8_CGPA__c  = element.Rpl_Sem_8_CGPA__c;
          this.studentRegform.Rpl_Pan_Card_No__c = element.Rpl_Pan_Card_No__c;
          this.studentRegform.Rpl_UG_College_Name__c = element.Rpl_UG_College_Name__c;
          this.studentRegform.Rpl_UG_Degree__c = element.Rpl_UG_Degree__c;
          this.studentRegform.Rpl_UG_Year_of_Graduation__c = element.Rpl_UG_Year_of_Graduation__c;
          this.studentRegform.Rpl_UG_CGPA__c = element.Rpl_UG_CGPA__c;
          //this.studentRegform.Rpl_UG_Stream__c = element.Rpl_UG_Stream__c;
          // this.studentRegform.Rpl_PG1_Sem_CGPA__c = element.Rpl_PG1_Sem_CGPA__c;
          // this.studentRegform.Rpl_PG2_Sem_CGPA__c = element.Rpl_PG2_Sem_CGPA__c;
          // this.studentRegform.Rpl_PG3_Sem_CGPA__c = element.Rpl_PG3_Sem_CGPA__c;
          // this.studentRegform.Rpl_PG4_Sem_CGPA__c = element.Rpl_PG4_Sem_CGPA__c;
          this.studentRegform.Rpl_Current_Backlogs__c = element.Rpl_Current_Backlogs__c;
          this.studentRegform.Rpl_12th_Board_Name__c = element.Rpl_12th_Board_Name__c;
          this.studentRegform.Rpl_12th_Year_of_passing__c = element.Rpl_12th_Year_of_passing__c;
          this.studentRegform.Rpl_Father_Name__c = element.Rpl_Father_Name__c;
             this.studentRegform.Rpl_Mother_Name__c = element.Rpl_Mother_Name__c;
             this.studentRegform.Rpl_Current_Address__c = element.Rpl_Current_Address__c;
             this.studentRegform.RPL_Permanent_Address__c = element.RPL_Permanent_Address__c;
             this.studentRegform.Rpl_Cleared_Backlogs__c = element.Rpl_Cleared_Backlogs__c;
             this.studentRegform.Rpl_Total_Backlogs__c = element.Rpl_Total_Backlogs__c;
             this.studentRegform.Rpl_Education_Gap__c = element.Rpl_Education_Gap__c;
             this.studentRegform.Rpl_UG_Board_Name_University_Name__c = element.Rpl_UG_Board_Name_University_Name__c;
             this.studentRegform.Rpl_PG1_Specialization__c = element.Rpl_PG1_Specialization__c;
             this.studentRegform.Rpl_PG2_Specialization__c = element.Rpl_PG2_Specialization__c;
             this.studentRegform.Rpl_PG1_Sem_CGPA__c = element.Rpl_PG1_Sem_CGPA__c;
             this.studentRegform.Rpl_PG2_Sem_CGPA__c = element.Rpl_PG2_Sem_CGPA__c;
             this.studentRegform.Rpl_PG3_Sem_CGPA__c = element.Rpl_PG3_Sem_CGPA__c;
             this.studentRegform.Rpl_PG4_Sem_CGPA__c = element.Rpl_PG4_Sem_CGPA__c;
             this.studentRegform.Rpl_UG_Stream__c = element.Rpl_UG_Stream__c;
             this.studentRegform.Rpl_DiplomaName__c = element.Rpl_DiplomaName__c;
             this.studentRegform.Rpl_Diploma_Number__c = element.Rpl_Diploma_Number__c;
             this.acitveSemester = element.Rpl_Acitve_Semester__c;
             this.studentRegform.Course_Name__c = element.Course_Name__c;
             this.studentRegform.Rpl_Is_Graduation_Details_Verified__c = element.Rpl_Is_Graduation_Details_Verified__c;
             this.studentRegform.Rpl_PG_Overall_Percentage__c = element.Rpl_PG_Overall_Percentage__c;
             this.studentRegform.Rpl_UG_OverAll_Percentage__c = element.Rpl_UG_OverAll_Percentage__c;
        });
                this.isSubmitButtonDisabled = this.studentRegform.Rpl_Is_Graduation_Details_Verified__c;

        this.checkoffCourseName();  
    })
    .catch(error => {
        console.log('error'+JSON.stringify(error));
    });
  }


  /*Over Percentage Calculation form */
 /*  overPercentageCalculation(activeSem){
      let semDetails = activeSem.split('-');
      let semNumber =  semDetails[semDetails.length-1];
      console.log('semNumber'+ semNumber);
      let requiredField = [];
      for(let i=1;i<parseInt(semNumber);i++)   {
               let value = 'Rpl_Sem_'+i+'_CGPA__c';
              console.log('String value',value);
              requiredField.push(value);
      }
      if(requiredField.length==0){return} 
      this.checkRequiredFields(requiredField);
      console.log(' Over ALL requiredField',requiredField);
      //this.checkRequiredFields(requiredField);

  } */

  overAllPercentageCalculation(course) {
    console.log('Course Name ' + this.studentRegform.Course_Name__c);
    console.log('Over all Percentage Calculation ' + course);
    let numberOfUgSem = 0;
    let numberOfPgSem = 0;
    let ugOverallSum = 0;
    let pgOverallSum = 0;

    if (course === 'UG') {
        for (let i = 1; i <= 6; i++) {
            let semCGPA = this.studentRegform[`Rpl_Sem_${i}_CGPA__c`];
            if (semCGPA !== undefined) {
                numberOfUgSem += 1;
                ugOverallSum += parseFloat(semCGPA);
            }
        }
        this.studentRegform.Rpl_UG_Overall_Percentage__c = (ugOverallSum / numberOfUgSem).toFixed(1);
    }

    // BTECH Fields
    else if (course === 'BTech') {
        console.log('In Btech');
        for (let i = 1; i <= 8; i++) {
            let semCGPA = this.studentRegform[`Rpl_Sem_${i}_CGPA__c`];
            console.log(semCGPA);
            if (semCGPA !== undefined) {
                numberOfUgSem += 1;
                ugOverallSum += parseFloat(semCGPA);
            }
        }
        console.log('CHECK AVR', typeof ugOverallSum / numberOfUgSem);
        console.log('CHECK FOR ', this.studentRegform.Rpl_UG_Overall_Percentage__c);
        this.studentRegform.Rpl_UG_Overall_Percentage__c = (ugOverallSum / numberOfUgSem).toFixed(1);
        console.log(this.studentRegform.Rpl_UG_Overall_Percentage__c);
    }

    // MBA Fields
    else if (course === 'MBA' || course === 'Mtech/MSC/MCA') {
        this.studentRegform.Rpl_UG_OverAll_Percentage__c = this.studentRegform.Rpl_UG_CGPA__c;
        for (let i = 1; i <= 4; i++) {
            let semCGPA = this.studentRegform[`Rpl_PG${i}_Sem_CGPA__c`];
            if (semCGPA !== undefined) {
                numberOfPgSem += 1;
                pgOverallSum += parseFloat(semCGPA);
            }
        }
        this.studentRegform.Rpl_PG_Overall_Percentage__c = (pgOverallSum / numberOfPgSem).toFixed(1);
    }
}



}