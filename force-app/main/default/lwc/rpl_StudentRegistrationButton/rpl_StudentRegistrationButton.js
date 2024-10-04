import { LightningElement,track,wire } from 'lwc';
/*Get Contact Details Based on the User Login*/
import RevaLogo from '@salesforce/resourceUrl/REVA_LOGO';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import { getRecord, getFieldValue } from "lightning/uiRecordApi"
import fetchCountSize from '@salesforce/apex/RPL_StudentRegistrationDetails.checkForTheStudentList';
import getStudentpresentYear from '@salesforce/apex/RPL_StudentRegistrationDetails.checkTheStudentPreFinalYear';
import getRevaPlacementDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getPlacementDetails';
import fetchStudentRegDetailsfrom from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails'
export default class Rpl_StudentRegistrationButton extends LightningElement {
  @track isButtonTrue=false; // Kiruba Hardcoded This To True, In Order To Work On Other Functionalities.
  @track showOtpPage = false;
  @track checkisRecord = false;
  @track checkisDataTable; 
  @track isOtpGenerator;
  @track  contactId ;
  @track conIdList;
  @track  logo = RevaLogo;
  @track revaPlacementId;
  @track studentRegform ={};
  @track checkForNoPlacement;
  @track checkIsOtpGenerator;
  @track checkForPathComplete;
  @track revaPlacementObj={};
  @track studentRegSize = 0;
  constructor(){
    super();
    
  }
  
@wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
userec({ error, data }) {
    if (error) {
      this.error = error;
      console.error('Error', error);
    } else if (data) {
      console.log('@Wire functionality Call');
      this.contactId = data.fields[CONTACT_ID.fieldApiName].value;
      console.log('ContactId', this.contactId);
      //this.getStudentSize(this.contactId);
      this.fetchStudentRegDetailsfrom1(this.contactId);
    }
}

handleStudentButton(event){
    this.isOtpGenerator = true
    this.isButtonTrue = false;
    this.showOtpPage = true;
}

openButtonchild(event){
console.log('check for event'+event.detail);
  this.isButtonTrue = event.detail;
}


//check for the PrefinalYearContact
checkForPreFinalYearStudent(contactId){
  console.log('Prefinal Final Year****************************');
  getStudentpresentYear({ contactId : contactId})
  .then(result => {
    console.log('Check for Prefinal Year Student Result'+JSON.stringify(result));   
  })
  .catch(error => {
      console.log('error'+JSON.stringify(error));
            this.checkForNoPlacement = true;
  });
}

getRevaPlacementDetails(){
     console.log('Inside the getRevaPlacement Details*** 67');
      getRevaPlacementDetails({contactId:this.contactId})
      .then(result => {
        console.log('getRevaPlacementDetails Result *'+JSON.stringify(result));
        //this.conIdList = result.conList;

        if(result.isPreOrFinalYear== true){
            this.revaPlacementObj = result;
            this.isButtonTrue = true;
        }else{
          this.checkForNoPlacement = true;
        }
       
      })
      .catch(error => {
          console.log('error'+JSON.stringify(error));
      });
}

fetchStudentRegDetailsfrom1(studentId){
  console.log('ContactId, Inside the getContactDetails Bar'+studentId);
  fetchStudentRegDetailsfrom({ recordId :studentId})
  .then(result => {
      this.studentRegSize = result.length;
      
      console.log('size'+this.studentRegSize);
      console.log('result Bar Status'+JSON.stringify(result));

      if(this.studentRegSize == 0){
        this.getRevaPlacementDetails();
      }else {
        this.isButtonTrue = false;
        this.checkForPathComplete =  true;
      }
      
      console.log('JSON Check Student Detials'+JSON.stringify(this.studentRegform),'Id'+this.studentregrecordid);
       
    
      
      console.log('Json Stringfy'+JSON.stringify(this.studentRegform));
      //console.log('Client Name'+this.clientNameArr);
  })
  .catch(error => {
      console.log('INSIDE ERROR'+JSON.stringify(error));
  });
}
  
  

}