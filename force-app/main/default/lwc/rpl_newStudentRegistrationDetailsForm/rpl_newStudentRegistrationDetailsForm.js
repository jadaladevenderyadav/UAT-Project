/*******************************************************************
 *description       : The component is used for Student Registration form
  author            : Vikranth Puvvadi
  Created Date      : 
  last modified on  : 31-08-2023
  last modified by  :
 ******************************************************************/
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
export default class Rpl_newStudentRegistrationDetailsForm extends NavigationMixin(LightningElement) {
  @api studentRegRecordId;
  @track studentRegform = {};
  //@track studentRegform1 = {};
  // Variable for storing the data into the object.
  @track showStudentDetails = true;
  @track isStudentDetails = "slds-section slds-is-close";
  @track showAcidemicDetails = true;
  @track show10DetailsAccordion = true;
  @track isAcidemicDetails = "slds-section slds-is-close";
  @track is10DetailsAccordion = "slds-section slds-is-close";
  @track contactId;
  @track isTenthDocumentUpload;
  @track show12DetailsAccordion = true;
  @track is12DetailsAccordion = "slds-section slds-is-close";
  @track isNotEmpty = false;
  @track showBtechDetails = false;
  @track isBtechDetails = "slds-section slds-is-close";
  @track showMtechDetails = false;
  @track isMtechDetails = "slds-section slds-is-close";
  @track isUGDetails = "slds-section slds-is-close";
  @track showUGDetails = false;
  @track isSaveTrue = true;
  @track showDipolmaDetailsAccordion = true;
  @track showImageUploadAccordion = true;
  @track isImageUploadAccordion = 'slds-is-open';
  @track acceptedFormats = ['.jpg', '.jpeg', '.png'];
  @track isDipolmaDetailsAccordion = "slds-section slds-is-close";
  @track logo = RevaLogo;
  allowedFormats = ['image'];
  validity = false;
  isSubmitButtonDisabled = false;
  /*Define a mapping of selectedName to the corresponding property in studentRegform*/
  fieldMapping = {
    'Name': "Name",
    "Personal Mail ID": "Rpl_Personal_Mail_ID__c",
    "University Mail Id": "Rpl_University_Mail_ID__c",
    "10th Percentage": "Rpl_10th_Percentage__c",
    "10th Board Name": "Rpl_10th_Board_Name__c",
    "10th Year of passing": "Rpl_10th_Year_of_passing__c",
    "Interested In Placement": "Rpl_Interested_in_placement__c",
    "Branch": "Rpl_Branch__c",
    "12th Percentage": "Rpl_12th_Percentage__c",
    "12th Board Name": "Rpl_12th_Board_Name__c",
    "12th Year of passing": "Rpl_12th_Year_of_passing__c",
    "Course Name": "Course_Name__c",
    "Sem 1 CGPA": "Rpl_Sem_1_CGPA__c",
    "Sem 2 CGPA": "Rpl_Sem_2_CGPA__c",
    "Sem 3 CGPA": "Rpl_Sem_3_CGPA__c",
    "Sem 4 CGPA": "Rpl_Sem_4_CGPA__c",
    "Sem 5 CGPA": "Rpl_Sem_5_CGPA__c",
    "Sem 6 CGPA": "Rpl_Sem_6_CGPA__c",
    "Sem 7 CGPA": "Rpl_Sem_7_CGPA__c",
    "Sem 8 CGPA": "Rpl_Sem_8_CGPA__c",
    "Pan Card No": "Rpl_Pan_Card_No__c",
    "UG Board Name/University Name": "Rpl_UG_Board_Name_University_Name__c",
    "UG College Name": "Rpl_UG_College_Name__c",
    "UG Degree": "Rpl_UG_Degree__c",
    "UG Year of Graduation": "Rpl_UG_Year_of_Graduation__c",
    "UG CGPA": "Rpl_UG_CGPA__c",
    "UG Stream": "Rpl_UG_Stream__c",
    "PG1 Sem CGPA": "Rpl_PG1_Sem_CGPA__c",
    "PG2 Sem CGPA": "Rpl_PG2_Sem_CGPA__c",
    "PG3 Sem CGPA": "Rpl_PG3_Sem_CGPA__c",
    "PG4 Sem CGPA": "Rpl_PG4_Sem_CGPA__c",
    "Diploma College Name": "Rpl_DiplomaName__c",
    "Diploma Percentage": "Rpl_Diploma_Number__c",
    "Current Backlogs": "Rpl_Current_Backlogs__c",
    "Cleared Backlogs": "Rpl_Cleared_Backlogs__c",
    "Total Backlogs": "Rpl_Total_Backlogs__c",
    "Education Gap": "Rpl_Education_Gap__c",
    "Diploma Graduation Year": "Rpl_Diploma_Graduation_Year__c",
    "Diploma University": "Rpl_Diploma_University__c",
    "Student Image": "Rpl_Student_Image__c",

  };
  /*Create a mapping of section IDs to their respective state properties*/
  toggleSectionName = {
    studentDetails: "isStudentDetails",
    acidemicDetails: "isAcidemicDetails",
    tenInputsDetails: "is10DetailsAccordion",
    twelveInputsDetails: "is12DetailsAccordion",
    BtechDetails: "isBtechDetails",
    MtechDetails: "isMtechDetails",
    UGDetails: "isUGDetails",
    dipolmaInputsDetails: "isDipolmaDetailsAccordion",
    imageUploadDetails: "isImageUploadAccordion"

  };

  // constructor(){
  //     super();
  //     this.fetchStudentRegDetailsfrom1('0031e00000PDjTlAAL');
  // }

  /**Wire Calling of Object Picklist Values */
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


  /*Get Login User Id*/
  @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
  userec({ error, data }) {
    if (error) {
      this.error = error;
      console.error('Error', error);
    } else if (data) {
      this.contactId = data.fields[CONTACT_ID.fieldApiName].value;

      this.fetchStudentRegDetailsfrom1(this.contactId);
      //console.log('ContactId', this.contactId);

      //console.log('Data', data);
    }
  }

  fetchStudentRegDetailsfrom1(studentId) {
    //console.log('ContactId, Inside the getContactDetails'+studentId);
    fetchStudentRegDetailsfrom({ recordId: studentId })
      .then(result => {
        console.log('result' + JSON.stringify(result));
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
          this.studentRegform.Rpl_Sem_4_CGPA__c = element.Rpl_Sem_4_CGPA__c;
          this.studentRegform.Rpl_Sem_5_CGPA__c = element.Rpl_Sem_5_CGPA__c;
          this.studentRegform.Rpl_Sem_6_CGPA__c = element.Rpl_Sem_6_CGPA__c;
          this.studentRegform.Rpl_Sem_7_CGPA__c = element.Rpl_Sem_7_CGPA__c;
          this.studentRegform.Rpl_Sem_8_CGPA__c = element.Rpl_Sem_8_CGPA__c;
          this.studentRegform.Rpl_Pan_Card_No__c = element.Rpl_Pan_Card_No__c;
          this.studentRegform.Rpl_UG_College_Name__c = element.Rpl_UG_College_Name__c;
          this.studentRegform.Rpl_UG_Degree__c = element.Rpl_UG_Degree__c;
          this.studentRegform.Rpl_UG_Year_of_Graduation__c = element.Rpl_UG_Year_of_Graduation__c;
          this.studentRegform.Rpl_UG_CGPA__c = element.Rpl_UG_CGPA__c;
          this.studentRegform.Rpl_Diploma_Graduation_Year__c = element.Rpl_Diploma_Graduation_Year__c;
          this.studentRegform.Rpl_Diploma_University__c = element.Rpl_Diploma_University__c;

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
          this.studentRegform.Rpl_UG_Stream__c = element.Rpl_UG_Stream__c;
          this.studentRegform.Rpl_PG1_Specialization__c = element.Rpl_PG1_Specialization__c;
          this.studentRegform.Rpl_PG2_Specialization__c = element.Rpl_PG2_Specialization__c;
          this.studentRegform.Rpl_PG1_Sem_CGPA__c = element.Rpl_PG1_Sem_CGPA__c;
          this.studentRegform.Rpl_PG2_Sem_CGPA__c = element.Rpl_PG2_Sem_CGPA__c;
          this.studentRegform.Rpl_PG3_Sem_CGPA__c = element.Rpl_PG3_Sem_CGPA__c;
          this.studentRegform.Rpl_PG4_Sem_CGPA__c = element.Rpl_PG4_Sem_CGPA__c;

          this.studentRegform.Rpl_DiplomaName__c = element.Rpl_DiplomaName__c;
          this.studentRegform.Rpl_Diploma_Number__c = element.Rpl_Diploma_Number__c;
          this.studentRegform.Rpl_Student_Image__c = element.Rpl_Student_Image__c;
          this.studentRegform.Rpl_Is_Student_Details_Verified__c = element.Rpl_Is_Student_Details_Verified__c;
          this.studentRegform.Rpl_Is_Graduation_Details_Verified__c = element.Rpl_Is_Graduation_Details_Verified__c;
        });
        this.validity = this.studentRegform.Rpl_Student_Image__c ? true : false;
        this.isSubmitButtonDisabled = this.studentRegform.Rpl_Is_Student_Details_Verified__c;
        //this.checkoffCourseName();
        //console.log('Client Name'+this.clientNameArr);
      })
      .catch(error => {
        console.log('error' + JSON.stringify(error));
      });
  }

  validateRequiredFields() {
    //console.log('this.studentRegform.Rpl_Personal_Mail_ID__c'+this.studentRegform.Rpl_Personal_Mail_ID__c);
    if (this.studentRegform.Rpl_Personal_Mail_ID__c == undefined || this.studentRegform.Rpl_University_Mail_ID__c == undefined) {
      this.showToast('Please Populate the Mail ID');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_Interested_in_placement__c == undefined) {
      this.showToast('Please populate the interested in placement');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_Pan_Card_No__c == undefined) {
      this.showToast('Please populate the Pan Card No');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_Pan_Card_No__c.length > 12) {
      this.showToast('INVALID PAN NUMBER');
      this.isNotEmpty = true;
    }

    else if (this.studentRegform.Rpl_Cleared_Backlogs__c == undefined) {
      this.showToast('Please Populate Cleared Backlogs');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_Current_Backlogs__c == undefined) {
      this.showToast('Please Populate Current Backlogs');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_Total_Backlogs__c == undefined) {
      this.showToast('Please Populate Total Backlogs');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_Education_Gap__c == undefined) {
      this.showToast('Please Populate Education Gap');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_10th_Percentage__c == undefined) {
      this.showToast('Please populate 10th Percentage field ');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_10th_Board_Name__c == undefined) {
      this.showToast('Please Populate 10th Board Name');
      this.isNotEmpty = true;
    }
    else if (this.studentRegform.Rpl_10th_Year_of_passing__c == undefined) {
      this.showToast('Please Populate 10th Year of passing');
      this.isNotEmpty = true;
    }
    // else if(this.studentRegform.Rpl_Diploma_Graduation_Year__c.length!=4){
    //   this.showToast('Year of Diploma Graduation must contains only 4 digits Value');
    //   this.isNotEmpty = true;
    //}
    //     else if(this.studentRegform.Rpl_UG_Board_Name_University_Name__c==undefined){
    //       this.showToast('Please Populate UG Board Name University Name');
    //       this.isNotEmpty =  true;
    //   }
    //   else if(this.studentRegform.Rpl_UG_College_Name__c==undefined){
    //     this.showToast('Please Populate UG College Name');
    //     this.isNotEmpty =  true;
    // }



    /* else if(this.studentRegform.Rpl_12th_Percentage__c==undefined){
            this.showToast('Please Populate 12th Percentage');
          this.isNotEmpty = true;
      }
      else if(this.studentRegform.Rpl_12th_Board_Name__c==undefined){
            this.showToast('Please Populate 12th  Board Name');
            this.isNotEmpty = true;
      }
      else if(this.studentRegform.Rpl_12th_Year_of_passing__c == undefined){
          this.showToast('Please Populate 12 Year of Passing');
            this.isNotEmpty = true;
      }*/
    else {
      this.isNotEmpty = false;
    }
  }

  handleSaveButton(event) {
    //console.log('Inside the Handle Save Button');

    //console.log('StudentDeatsil',JSON.stringify(this.studentRegform));
    this.validateRequiredFields();
    if (this.validity == false) {
      this.showToast('Please upload your passport size image');
    }
    else if (this.isNotEmpty == false && this.validity == true) {
      this.studentRegform.Rpl_isStudentDetailsComplete__c = true;

      updateDetails({ stdRegDetails: this.studentRegform })
        .then(result => {
          //console.log('result'+result); 
          this.studentRegRecordId = result;
          this.isSaveTrue = false;
          this.showToastSuccess('Student Details Successfully Saved');
          this.handleStudentDetailsComplete();
        })
        .catch(error => {
          console.log('error' + JSON.stringify(error));
        });
    }
  }
  toggleSection(event) {

    let selectedToggle = this.toggleSectionName[event.currentTarget.dataset.id];
    console.log('selectedToggle' + selectedToggle);
    if (selectedToggle != undefined) {
      this[selectedToggle] = this[selectedToggle] === "slds-section slds-is-close" ? "slds-section slds-is-open" : "slds-section slds-is-close";
    }
  }
  /*Handle Change of the InputFields */
  handleAllFieldChange(event) {
    console.log(JSON.stringify(event.target.value));
    const fieldName = this.fieldMapping[event.target.label];
    console.log(fieldName);
    if (fieldName) {
      const richText = this.template.querySelector(".student-image");
      try {
        let value = event.target.value;
        if (fieldName === 'Rpl_Student_Image__c') {
          const modifiedHtml = this.modifyHtmlString(event.target.value);
          this.studentRegform[fieldName] = modifiedHtml;
          this.validity = true;

        } else {
          this.studentRegform[fieldName] = value;
          if(fieldName === 'Rpl_Current_Backlogs__c' || fieldName ===  'Rpl_Cleared_Backlogs__c' ){
        if( this.studentRegform['Rpl_Current_Backlogs__c'] &&  this.studentRegform['Rpl_Cleared_Backlogs__c']){
          this.studentRegform['Rpl_Total_Backlogs__c'] =  parseFloat(this.studentRegform['Rpl_Current_Backlogs__c']) +  parseFloat(this.studentRegform['Rpl_Cleared_Backlogs__c']);
        }
        else if(this.studentRegform['Rpl_Current_Backlogs__c']){
          this.studentRegform['Rpl_Total_Backlogs__c'] =  this.studentRegform['Rpl_Current_Backlogs__c'];
        }
        else if(this.studentRegform['Rpl_Cleared_Backlogs__c']){
          this.studentRegform['Rpl_Total_Backlogs__c'] =this.studentRegform['Rpl_Cleared_Backlogs__c'];
        }
      }
        }

      } catch (error) {
        // Handle the custom validation error
        console.log('FIELD ' + richText);
        console.log(error.message)
        this.showToast(error.message);
        this.validity = false;

      }
    }
  }

  modifyHtmlString(inputHtml) {
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = inputHtml;

    // Find all img tags inside the div
    const imgTags = tempDiv.querySelectorAll('img');
    console.log(imgTags);
    // Check the number of img tags
    if (imgTags.length > 1) {
      // Set a custom validation message
      throw new Error('More than one image is not allowed.');
    }

    else if (imgTags.length == 0) {
      // Set a custom validation message
      throw new Error('Please upload your passport size image.');
    }

    // If there's only one img tag, add the style attribute
    if (imgTags.length === 1) {
      const imgTag = imgTags[0];
      imgTag.setAttribute('style', 'height: 135px; width: 135px;');
    }

    // Return the modified HTML
    return tempDiv.innerHTML;
  }

  showToast(fieldName) {
    const event = new ShowToastEvent({
      title: 'Error',
      message: fieldName,
      variant: 'destructive'
    });
    this.dispatchEvent(event);
  }

  showToastSuccess(fieldName, Title) {
    const event = new ShowToastEvent({
      title: Title,
      message: fieldName,
      variant: 'success'
    });
    this.dispatchEvent(event);
  }

  /* 
   * Communicating to the student detail page to Student Path Page
  */
  handleStudentDetailsComplete() {
    console.log('inside the Student Details Complete Method');
    const factor = true;
    this.dispatchEvent(new CustomEvent('studentprocesscomplete', {
      detail: { message: factor }
    }));
  }

  validateDate(event) {
    const inputDate = event.target.value;
    const today = new Date();
    console.log('today', today);
    today.setHours(0, 0, 0, 0);
    const inputDateTime = new Date(inputDate);
    inputDateTime.setHours(0, 0, 0, 0);

    // Get the name of the input field (e.g., "Rpl_10th_Year_of_passing__c" or "Rpl_12th_Year_of_passing__c")
    const fieldName = event.target.name;

    //console.log('fieldName***********************'+event.target.name);

    if (inputDateTime >= today && fieldName === "Rpl_10th_Year_of_passing__c") {
      event.target.setCustomValidity("Please select a date in the past.");
    } else {
      event.target.setCustomValidity(""); // Reset custom validity
      // Check if it's the 12th Year of passing field and validate against the 10th Year of passing fiel
    }
    if (fieldName === "Rpl_12th_Year_of_passing__c") {
      const year10th = new Date(this.studentRegform.Rpl_10th_Year_of_passing__c);
      //console.log('year10th********',year10th);
      year10th.setHours(0, 0, 0, 0);

      if (inputDateTime < year10th) {
        event.target.setCustomValidity("12th Year of passing date should not be earlier than 10th Year of passing date.");
      }
      // Add validation for a minimum difference of two years between 10th and 12th Year of passing
      const twoYearsAgo = new Date(year10th);
      twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() + 2);

      if (inputDateTime < twoYearsAgo) {
        event.target.setCustomValidity("There should be a minimum difference of two years between 10th and 12th Year of passing.");
      }
    }
    event.target.reportValidity(); // Trigger validation message
  }
}