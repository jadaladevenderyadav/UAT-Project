import { LightningElement,wire,track } from 'lwc';
import REVA_LOGO_IMAGE from "@salesforce/resourceUrl/REVA_LOGO";
import ContactDetails from "@salesforce/apex/getContactDetails.ContactDetails";
export default class ExaminationPortalTab extends LightningElement {
    REVA_LOGO = REVA_LOGO_IMAGE;
   @track selectedTabValue;
    loginDetails;
    loginUserName;
    showCourseData = false;

    // Name of the key will match the name attribute of navigation-item.
    // selectedTab = {
    //     viewExamTab : true,
    //     viewNotifications : false,
    //     viewIAMarks : false,
    //     viewIAMarks_TT : false,
    //     viewIAMarks_HT : false,
    //     viewHallTicket : false
    // }
    selectedItem = 'Attendance';
    currentContent = 'Attendance';
    
    // @track viewExamTab = false;
    // @track viewNotifications = false;
    // @track otherTabs=false;
    // viewIAMarks = false;
    // viewHallTicket = false;
    // viewIAMarks_TT = false;
    // viewIAMarks_HT = false;

     handleTabActive(event) {
        this.selectedTabValue = event.target.label;
    }

     @wire(ContactDetails)
    getContactDetails({data,error}){
        if(data){
           // alert(JSON.stringify(data));
            this.loginUserName = data.Name;
            this.loginDetails = data;
            if(this.loginDetails.Record_Type_Name__c === 'Student') {
                this.showCourseData = true;
            }  
            else{
                this.showCourseData = false;
            }                     
        }
        if(error){
        }
    }

   

}