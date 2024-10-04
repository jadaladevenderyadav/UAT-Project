import { LightningElement, track, api, wire } from 'lwc';
import fetchMealMenus from '@salesforce/apex/RevaMealBookingController.fetchMealMenus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import fetchContactsForBooking from '@salesforce/apex/RevaMealBookingController.fetchContactsForBooking';
// import fetchBookedMeals from '@salesforce/apex/RevaMealBookingController.fetchBookedMeal';
import checkExistingBooking from '@salesforce/apex/RevaMealBookingController.checkExistingBooking';
// import  callMissedMealsByTheUser  from '@salesforce/apex/RevaMealBookingController.missedMealsByTheUser'; 
import REVA_Hostel_Static_Resources from "@salesforce/resourceUrl/REVA_Hostel_Static_Resources";
import instantMealBooking from '@salesforce/apex/RevaMealBookingController.instantMealBooking'

export default class RevaHostelInstantMealBooking extends NavigationMixin(LightningElement) {
    timeZone = 'UTC';
    @track
    messMenuList = [];
    apexCallDone = false;
    objError;
    showError = false;
    showWarning = false; 
    strMessage = '';
    showSpinner = false;
    showBookingModal = false;
    clickedMenu;
    tickIcon;
//     calendarIcon;
//     mealIcon;
//     timeIcon;
//   forTeachingStaff = false;
@track selectedContactId;
    todaysDate;
    bookingSuccessMessage = 'Booked Meal Successfully!';
    @api disableBookMeal;
    @track showBookMealButton = false;
    @track bookedMeals = [];
    @track mealMenuId;
    
    
    contacts = [];
    get showTemplate() {
        return (this.messMenuList && this.messMenuList.length && this.messMenuList.length > 0) && !this.disableBookMeal;
    }

    
    
    

    async connectedCallback() {

                    this.tickIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/tick-mark.png";
                    this.calendarIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/calendar-icon.png";
                    this.mealIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/meal-booking.png";
                    this.timeIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/time-icon.png";
                   
      
            console.log('connectedCallback',);
            this.showSpinner = true;
            const objResult = await fetchMealMenus();
            console.log('fetchMealMenus',objResult);
            this.messMenuList = [...objResult];
            console.log('connectedCallback 2 menulist',this.messMenuList);
            if (this.messMenuList && !this.messMenuList.length) {
                this.setBannerMessage('', 'No Meal Menus Found');
            }
            if (this.disableBookMeal) {
                this.setBannerMessage('', 'You have missed more than 10 meals for the month, please pay the penalty to unlock the bookings!');
            }
            this.apexCallDone = true;
            this.showSpinner = false;
        
    }



    formatTime(milliseconds) {
        if (!milliseconds || isNaN(milliseconds)) {
          return "";
        }
    
        const date = new Date(milliseconds);
        let hours = date.getUTCHours();
        const minutes = date.getUTCMinutes();
        let ampm = hours >= 12 ? "PM" : "AM";
    
        // Convert hours from 24-hour format to 12-hour format
        hours = hours % 12;
        hours = hours === 0 ? 12 : hours; // Handle midnight (0:00) as '12:00 AM'
    
        const formattedTime = `${hours
          .toString()
          .padStart(2, "0")}:${minutes.toString().padStart(2, "0")} ${ampm}`;
    
        return formattedTime;
      }
 
    handleErrors(error) {
        this.objError = error;
    }
    setBannerMessage(error, warning) {
        if (error) {
            this.strMessage = error;
            this.showError = true;
        }
        if (warning) {
            this.strMessage = warning;
            this.showWarning = true;
        }
    }

    handleMealBooking(event) {
        this.mealMenuId = event.currentTarget.getAttribute('data-menuid');
        console.log("mealMenuId", this.mealMenuId);
        if (this.mealMenuId) {
            this.clickedMenu = this.mealMenuId;
            this.setTodaysDate();
            this.forTeachingStaff = false;
            this.showBookingModal = true;
            this.fetchStudentAndNonTeachingStaffContacts();
        }
        let currentMenuIndex = event.target.dataset.id;
        this.getButtonVisiblity(currentMenuIndex);
    }


    // handleMealBookingTeaching(event) {
    //     const mealMenuId = event.currentTarget.getAttribute('data-menuid');
    //     if (mealMenuId) {
    //         this.clickedMenu = mealMenuId;
    //         this.setTodaysDate();
    //        this.forTeachingStaff = true;
    //         this.showBookingModal = true;

    //         // Fetch professor contacts
    //         this.fetchProfessorContacts();
    //     }

    //     let currentMenuIndex = event.target.dataset.id;
    //     this.getButtonVisiblity(currentMenuIndex);
    // }
    
    fetchStudentAndNonTeachingStaffContacts() {
        Promise.all([
            fetchContactsForBooking({ contactRecordTypeName: 'Student' }),
            fetchContactsForBooking({ contactRecordTypeName: 'Non_Teaching' }),
            fetchContactsForBooking({ contactRecordTypeName: 'Professor' })
        ])
        .then(([studentContacts, nonTeachingStaffContacts, teachingStaffContacts]) => {
            this.contacts = [...studentContacts, ...nonTeachingStaffContacts, ...teachingStaffContacts];
        })
        .catch(error => {
            console.error('Error fetching contacts: ', error);
        });
    }

    // fetchProfessorContacts() {
    //     fetchContactsForBooking({ contactRecordTypeName: 'Professor' })
    //     .then(professorContacts => {
    //        this.contacts = professorContacts;
    //     })
    //     .catch(error => {
    //         console.error('Error fetching professor contacts: ', error);
    //     });
    // }
    
    getButtonVisiblity(currentMenuIndex) {
    const currentTime = new Date();
    console.log('Current Time:', currentTime);
    const hours = currentTime.getHours();
    const minutes = currentTime.getMinutes();
    const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes;
    let timeString = `${hours}:${formattedMinutes} AM`;

    if (hours >= 12) {
        const adjustedHours = hours === 12 ? hours : hours - 12;
        const period = hours < 12 ? 'AM' : 'PM';
        timeString = `${adjustedHours}:${formattedMinutes} ${period}`;
    }

    const currentDateTimeString = `${timeString}`;
    console.log("currentDateTimeString", currentDateTimeString);

    // Get current obj start and end time
    const startTime = this.formatTime(new Date(this.messMenuList[currentMenuIndex].Start_Time__c).getTime());
    const endTime = this.formatTime(new Date(this.messMenuList[currentMenuIndex].End_Time__c).getTime());
    console.log("startTime", startTime);
    console.log("endTime", endTime);
    console.log('OUTPUT Start and end time: ', startTime, ' End time - ', endTime);

    // Convert start and end time to 24-hour format for comparison
    const startTime24 = this.convertTo24HourFormat(startTime);
    const endTime24 = this.convertTo24HourFormat(endTime);
    const currentTime24 = this.convertTo24HourFormat(currentDateTimeString);

    // Compare current and object times
    if (currentTime24 >= startTime24 && currentTime24 <= endTime24) {
        this.showBookMealButton = true;
        console.log('Final Show Book Meal Button:', this.showBookMealButton);
    } else {
        this.showBookMealButton = false;
        console.log('OUTPUT : In else part');
    }
}

convertTo24HourFormat(timeString) {
    const [time, period] = timeString.split(' ');
    let [hours, minutes] = time.split(':');
    hours = parseInt(hours);
    minutes = parseInt(minutes);
    if (period === 'PM' && hours !== 12) {
        hours += 12;
    } else if (period === 'AM' && hours === 12) {
        hours = 0;
    }
    return hours * 60 + minutes;
}

    
    closeModal() {
        this.showBookingModal = false;
       this.forTeachingStaff = false;
    }

    handleContactSelection(event) {
        this.selectedContactId = event.target.value;
        console.log("selectedContactId",this.selectedContactId)
    }
    
    
 handleSubmit(event) {
        console.log("submit");
        console.log("this.mealMenuId", this.mealMenuId);
        this.showSpinner = true;
        event.preventDefault();// stop the form from submitting    
        checkExistingBooking({ menuId: this.mealMenuId, contactId: this.selectedContactId })
        .then(result => { 
            console.log("this.mealMenuId",this.mealMenuId)
            console.log("this.selectedContactId",this.selectedContactId)
            // Success logic...
            console.log('res of apex', result);
            if (result === true) {
                const fields = event.detail.fields;
                console.log('fields', fields);
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
            if (result === false) {
                const evt = new ShowToastEvent({
                    title: 'Booking Failed',
                    message: 'Duplicate Booking: You have already booked a meal during this scheduled time.',
                    variant: 'error'
                });
                this.dispatchEvent(evt);  
                location.reload();
            }
            
        })
        
        .catch(error => {
            // Error logic...
            console.log('error-----', error);
        });
}

handleSuccess(event) {
    try {
        //const updatedRecordId = event.detail.id;
        // Generate a URL to a User record page
        console.log('==============record id', event.detail.id);
        this.showBookSuccessNotification();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                actionName: 'view'
            }
        });
    } catch (error) {
        // console.log('error-----', error);
        this.handleError();
    }
}



setTodaysDate() {
    this.todaysDate = new Date().toISOString();
}
handleError() {
    this.showErrorNotification();
}
showBookSuccessNotification() {
    this.showSpinner = false;
    const evt = new ShowToastEvent({
        title: this.bookingSuccessMessage,
        message: 'Enjoy your meals',
        variant: 'success'
    });
    this.dispatchEvent(evt);
    this.closeModal();
}
showErrorNotification() {
    this.showSpinner = false;
    const evt = new ShowToastEvent({
        title: 'Booking Failed',
        message: 'Some Error Occured',
        variant: 'error'
    });
    this.dispatchEvent(evt);
}

}






// import { LightningElement, track, api, wire } from 'lwc';
// import fetchMealMenus from '@salesforce/apex/RevaMealBookingController.fetchMealMenus';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { NavigationMixin } from 'lightning/navigation';
// import fetchContactsForBooking from '@salesforce/apex/RevaMealBookingController.fetchContactsForBooking';
// // import fetchBookedMeals from '@salesforce/apex/RevaMealBookingController.fetchBookedMeal';
// import checkExistingBooking from '@salesforce/apex/RevaMealBookingController.checkExistingBooking';
// import REVA_Hostel_Static_Resources from "@salesforce/resourceUrl/REVA_Hostel_Static_Resources";
// import instantMealBooking from '@salesforce/apex/RevaMealBookingController.instantMealBooking';

// export default class RevaHostelInstantMealBooking extends LightningElement {
//     timeZone = 'UTC';
//     @track
//     messMenuList = [];
//     apexCallDone = false;
//     objError;
//     showError = false;
//     showWarning = false; 
//     strMessage = '';
//     showSpinner = false;
//     showBookingModal = false;
//     clickedMenu;
//     tickIcon;
//     calendarIcon;
//     mealIcon;
//     timeIcon;
// //   forTeachingStaff = false;
// @track selectedContactId;
//     todaysDate;
//     bookingSuccessMessage = 'Booked Meal Successfully!';
//     @api disableBookMeal;
//     @track showBookMealButton = false;
//     @track bookedMeals = [];
//     @track mealMenuId;
    
    
//     contacts = [];
//     get showTemplate() {
//         return (this.messMenuList && this.messMenuList.length && this.messMenuList.length > 0) && !this.disableBookMeal;
//     }

    

//     async connectedCallback() {
//         this.tickIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/tick-mark.png";
//         this.calendarIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/calendar-icon.png";
//         this.mealIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/meal-booking.png";
//         this.timeIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/time-icon.png";
       


      
//             console.log('connectedCallback',);
//             this.showSpinner = true;
//             const objResult = await fetchMealMenus();
//             console.log('fetchMealMenus',objResult);
//             this.messMenuList = [...objResult];
//             console.log('connectedCallback 2 menulist',this.messMenuList);
//             if (this.messMenuList && !this.messMenuList.length) {
//                 this.setBannerMessage('', 'No Meal Menus Found');
//             }
//             if (this.disableBookMeal) {
//                 this.setBannerMessage('', 'You have missed more than 10 meals for the month, please pay the penalty to unlock the bookings!');
//             }
//             this.apexCallDone = true;
//             this.showSpinner = false;
        
//     }



//     formatTime(milliseconds) {
//         if (!milliseconds || isNaN(milliseconds)) {
//           return "";
//         }
    
//         const date = new Date(milliseconds);
//         let hours = date.getUTCHours();
//         const minutes = date.getUTCMinutes();
//         let ampm = hours >= 12 ? "PM" : "AM";
    
//         // Convert hours from 24-hour format to 12-hour format
//         hours = hours % 12;
//         hours = hours === 0 ? 12 : hours; // Handle midnight (0:00) as '12:00 AM'
    
//         const formattedTime = `${hours
//           .toString()
//           .padStart(2, "0")}:${minutes.toString().padStart(2, "0")} ${ampm}`;
    
//         return formattedTime;
//       }
 
//     handleErrors(error) {
//         this.objError = error;
//     }
//     setBannerMessage(error, warning) {
//         if (error) {
//             this.strMessage = error;
//             this.showError = true;
//         }
//         if (warning) {
//             this.strMessage = warning;
//             this.showWarning = true;
//         }
//     }

//     handleMealBooking(event) {
//         this.mealMenuId = event.currentTarget.getAttribute('data-menuid');
//         console.log("mealMenuId", this.mealMenuId);
//         if (this.mealMenuId) {
//             this.clickedMenu = this.mealMenuId;
//             this.setTodaysDate();
//             this.forTeachingStaff = false;
//             this.showBookingModal = true;
//             this.fetchStudentAndNonTeachingStaffContacts();
//         }
//         let currentMenuIndex = event.target.dataset.id;
//         this.getButtonVisiblity(currentMenuIndex);
//     }

//     fetchStudentAndNonTeachingStaffContacts() {
//         Promise.all([
//             fetchContactsForBooking({ contactRecordTypeName: 'Student' }),
//             fetchContactsForBooking({ contactRecordTypeName: 'Non Teaching' }),
//             fetchContactsForBooking({ contactRecordTypeName: 'Professor' })
//         ])
//         .then(([studentContacts, nonTeachingStaffContacts, teachingStaffContacts]) => {
//             this.contacts = [...studentContacts, ...nonTeachingStaffContacts, ...teachingStaffContacts];
//         })
//         .catch(error => {
//             console.error('Error fetching contacts: ', error);
//         });
//     }

//     getButtonVisiblity(currentMenuIndex) {
//     const currentTime = new Date();
//     console.log('Current Time:', currentTime);
//     const hours = currentTime.getHours();
//     const minutes = currentTime.getMinutes();
//     const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes;
//     let timeString = `${hours}:${formattedMinutes} AM`;

//     if (hours >= 12) {
//         const adjustedHours = hours === 12 ? hours : hours - 12;
//         const period = hours < 12 ? 'AM' : 'PM';
//         timeString = `${adjustedHours}:${formattedMinutes} ${period}`;
//     }

//     const currentDateTimeString = `${timeString}`;
//     console.log("currentDateTimeString", currentDateTimeString);

//     // Get current obj start and end time
//     const startTime = this.formatTime(new Date(this.messMenuList[currentMenuIndex].Start_Time__c).getTime());
//     const endTime = this.formatTime(new Date(this.messMenuList[currentMenuIndex].End_Time__c).getTime());
//     console.log("startTime", startTime);
//     console.log("endTime", endTime);
//     console.log('OUTPUT Start and end time: ', startTime, ' End time - ', endTime);

//     // Convert start and end time to 24-hour format for comparison
//     const startTime24 = this.convertTo24HourFormat(startTime);
//     const endTime24 = this.convertTo24HourFormat(endTime);
//     const currentTime24 = this.convertTo24HourFormat(currentDateTimeString);

//     // Compare current and object times
//     if (currentTime24 >= startTime24 && currentTime24 <= endTime24) {
//         this.showBookMealButton = true;
//         console.log('Final Show Book Meal Button:', this.showBookMealButton);
//     } else {
//         this.showBookMealButton = false;
//         console.log('OUTPUT : In else part');
//     }
// }

// convertTo24HourFormat(timeString) {
//     const [time, period] = timeString.split(' ');
//     let [hours, minutes] = time.split(':');
//     hours = parseInt(hours);
//     minutes = parseInt(minutes);
//     if (period === 'PM' && hours !== 12) {
//         hours += 12;
//     } else if (period === 'AM' && hours === 12) {
//         hours = 0;
//     }
//     return hours * 60 + minutes;
// }

    
//     closeModal() {
//         this.showBookingModal = false;
//        this.forTeachingStaff = false;
//     }

//     handleContactSelection(event) {
//         this.selectedContactId = event.target.value;
//         console.log("selectedContactId",this.selectedContactId)
//     }
    
    
//  handleSubmit(event) {
//         console.log("submit");
//         console.log("this.mealMenuId", this.mealMenuId);
//         this.showSpinner = true;
//         event.preventDefault();// stop the form from submitting    
//         checkExistingBooking({ menuId: this.mealMenuId, contactId: this.selectedContactId })
//         .then(result => { 
//             console.log("this.mealMenuId",this.mealMenuId)
//             console.log("this.selectedContactId",this.selectedContactId)
//             // Success logic...
//             console.log('res of apex', result);
//             if (result === true) {
//                 const fields = event.detail.fields;
//                 console.log('fields', fields);
//                 this.template.querySelector('lightning-record-edit-form').submit(fields);
//             }
//             if (result === false) {
//                 const evt = new ShowToastEvent({
//                     title: 'Booking Failed',
//                     message: 'Duplicate Booking: You have already booked a meal during this scheduled time.',
//                     variant: 'error'
//                 });
//                 this.dispatchEvent(evt);
//             }
//         })
//         .catch(error => {
//             // Error logic...
//             console.log('error-----', error);
//         });
// }

// handleSuccess(event) {
//     try {
//         //const updatedRecordId = event.detail.id;
//         // Generate a URL to a User record page
//         console.log('==============record id', event.detail.id);
//         this.showBookSuccessNotification();
//         this[NavigationMixin.Navigate]({
//             type: 'standard__recordPage',
//             attributes: {
//                 recordId: event.detail.id,
//                 actionName: 'view'
//             }
//         });
//     } catch (error) {
//         // console.log('error-----', error);
//         this.handleError();
//     }
// }



// setTodaysDate() {
//     this.todaysDate = new Date().toISOString();
// }
// handleError() {
//     this.showErrorNotification();
// }
// showBookSuccessNotification() {
//     this.showSpinner = false;
//     const evt = new ShowToastEvent({
//         title: this.bookingSuccessMessage,
//         message: 'Enjoy your meals',
//         variant: 'success'
//     });
//     this.dispatchEvent(evt);
//     this.closeModal();
// }
// showErrorNotification() {
//     this.showSpinner = false;
//     const evt = new ShowToastEvent({
//         title: 'Booking Failed',
//         message: 'Some Error Occured',
//         variant: 'error'
//     });
//     this.dispatchEvent(evt);
// }



// }