import { LightningElement, track, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import downloadjs from '@salesforce/resourceUrl/downloadjs';
// Import Apex methods
import GetStudentDetails from '@salesforce/apex/ASM_HallTicketCtrl.GetStudentDetails';
import downloadExamHallTicketPDF from '@salesforce/apex/ASM_HallTicketCtrl.DowloadHallTicket';
import getExamNotification from '@salesforce/apex/Rve_ViewHallTicketController.getExamNotification';
import isHallTicketDownloadEnabled from '@salesforce/apex/Rve_ViewHallTicketController.isHallTicketDownloadEnabled';
import downloadIAHallTicketPDF from '@salesforce/apex/Rve_ViewHallTicketController.getPdfFileAsBase64String';

export default class Rve_ViewHallTicket extends LightningElement {
    @track boolShowSpinner = true;
    @track SRNNumber = '';
    @track PendingServey = '';
    @track HallTicketEnabled = false;
    @track showPendingSurveyTable = false;
    @track showAttendanceTable = false;
    @track showStudentFeeTable = false;
    @track isPrintDisabled = true; // Disabled initially until checks are complete
    @track showErrorMsg = false;
    @track lst_Attendance = [];
    @track lst_StudentFee = [];
    @track lstSurveyPending = [];
    @api hallType; // The type of hall ticket (e.g., IA Notification)

    connectedCallback() {
        this.boolShowSpinner = true;

        // Load external library download.js
        loadScript(this, downloadjs)
            .then(() => {
                // Check if hall ticket download is enabled
                isHallTicketDownloadEnabled()
                    .then(result => {
                        this.isPrintDisabled = !result; // Enable or disable based on result

                        // Proceed with fetching exam notification and student details
                        this.fetchExamNotification();
                    })
                    .catch(() => {
                        this.isPrintDisabled = false; // Keep print disabled if there's an error
                        this.showErrorMsg = true;
                        this.boolShowSpinner = false;
                    });
            })
           /* .catch(() => {
                this.isPrintDisabled = true; // Disable print if there's an error loading the library
                this.showErrorMsg = true;
                this.boolShowSpinner = false;
            });*/
    }

    fetchExamNotification() {
        getExamNotification({ recType: this.hallType })
            .then(response => {
                if (response) {
                    this.fetchStudentDetails();
                } else {
                    this.showErrorMsg = true;
                    this.boolShowSpinner = false;
                }
            })
            .catch(error => {
                console.error('Error fetching exam notification:', error);
                this.showErrorMsg = true;
                this.boolShowSpinner = false;
            });
    }

    fetchStudentDetails() {
        GetStudentDetails()
            .then(result => {
               this.SRNNumber = result.SRNNumber;
                    this.PendingServey = result.SurveyPending;
                    this.lst_Attendance = result.AttendanceWrapper;
                    this.lst_StudentFee = result.StudentFee;
                    this.HallTicketEnabled = result.EnableHallTicket;
                    this.lstSurveyPending = result.lstSurveyPending;
                    this.showPendingSurveyTable = result.lstSurveyPending.length > 0 ? true : false;
                    this.showAttendanceTable = result.AttendanceWrapper.length > 0 ? true : false;
                    this.showStudentFeeTable = result.StudentFee.length > 0 ? true : false;
        
                    this.boolShowSpinner = false;
                    this.showErrorMsg = false;;
            })
            .catch(error => {
                console.error('Error fetching student details:', error);
                this.showErrorMsg = true;
                this.boolShowSpinner = false;
            });
    }

    downloadHallTicket(event) {
        if (this.isPrintDisabled) {
            // If print is disabled, show an error or message to the user
            this.showErrorMsg = true;
            return;
        }

        this.boolShowSpinner = true;

        if (this.hallType === 'hed_IA_Notification') {
            const fileName = `Hall_Ticket_${this.SRNNumber}`;
            downloadIAHallTicketPDF({ StudentSRN: this.SRNNumber })
                .then(response => {
                    const file = `data:application/pdf;base64,${response}`;
                    window.download(file, `${fileName}.pdf`, 'application/pdf');
                    this.boolShowSpinner = false;
                })
                .catch(error => {
                    console.error('Error downloading IA hall ticket:', error);
                    this.showErrorMsg = true;
                    this.boolShowSpinner = false;
                });
        } else {
            downloadExamHallTicketPDF({ StudentSRN: this.SRNNumber })
                .then(response => {
                    window.open(response.url);
                    this.boolShowSpinner = false;
                })
                .catch(error => {
                    console.error('Error downloading exam hall ticket:', error);
                    this.showErrorMsg = true;
                    this.boolShowSpinner = false;
                });
        }
    }
}
/*import { LightningElement, wire, track, api} from 'lwc';
import Id from '@salesforce/user/Id';
import { loadScript } from 'lightning/platformResourceLoader';
import downloadjs from '@salesforce/resourceUrl/downloadjs';
// Import from Apex
import GetStudentDetails from '@salesforce/apex/ASM_HallTicketCtrl.GetStudentDetails';
import downloadExamHallTicketPDF from '@salesforce/apex/ASM_HallTicketCtrl.DowloadHallTicket';
import getExamNotification from '@salesforce/apex/Rve_ViewHallTicketController.getExamNotification';
import isHallTicketDownloadEnabled from'@salesforce/apex/Rve_ViewHallTicketController.isHallTicketDownloadEnabled';
import downloadIAHallTicketPDF from '@salesforce/apex/Rve_ViewHallTicketController.getPdfFileAsBase64String';

export default class Rve_ViewHallTicket extends LightningElement {
    boolShowSpinner = true;
    SRNNumber = '';
    PendingServey = '';
    HallTicketEnabled = false;
    showPendingSurveyTable = false;
    showAttendanceTable = false;
    showStudentFeeTable = false;
    isPrintDisabled = false;
    showErrorMsg = false;
    @track lst_Attendance = [];
    @track lst_StudentFee = [];
    @track lstSurveyPending = [];
    //hallTicketType = 'hed_IA_Notification';
    @api hallType;
    
    connectedCallback(){
        // Load DownloadJS Library
        this.isPrintDisabled = true;
        loadScript(this, downloadjs)
        .then(() => {
            this.isPrintDisabled = false;
            this.boolShowSpinner = false;
        })
        .catch();

        getExamNotification({recType: this.hallType})
        .then(response => {
            if(response != null){
                // Check Type of Hall ticket
                this.hallTicketType = response.RecordType.DeveloperName;
                
                // Get Student Details
                GetStudentDetails()
                .then(result => {
                    this.SRNNumber = result.SRNNumber;
                    this.PendingServey = result.SurveyPending;
                    this.lst_Attendance = result.AttendanceWrapper;
                    this.lst_StudentFee = result.StudentFee;
                    this.HallTicketEnabled = result.EnableHallTicket;
                    this.lstSurveyPending = result.lstSurveyPending;
                    this.showPendingSurveyTable = result.lstSurveyPending.length > 0 ? true : false;
                    this.showAttendanceTable = result.AttendanceWrapper.length > 0 ? true : false;
                    this.showStudentFeeTable = result.StudentFee.length > 0 ? true : false;
        
                    this.boolShowSpinner = false;
                    this.showErrorMsg = false;
                })
                .catch(error => {
                   
                    this.boolShowSpinner = false;
                    this.showErrorMsg = true;
                })

            }
            else {
                this.showErrorMsg = true;
            }
        })
        .catch(error => {
            this.showErrorMsg = true;
        })

    }

    downloadHallTicket(event){
        this.boolShowSpinner = true;
        /*downloadExamHallTicketPDF({StudentSRN : this.SRNNumber}).then(response => {
            this.boolShowSpinner = false;
            
        })*/

        /*
         if(this.hallType == 'hed_IA_Notification'){
             const fileName = 'Hall Ticket '+this.SRNNumber;
            downloadIAHallTicketPDF({StudentSRN : this.SRNNumber}).then(response => {
                 this.boolShowSpinner = false;
                var strFile = "data:application/pdf;base64,"+response;
                 window.download(strFile, fileName+".pdf", "application/pdf");
    
            }).catch(error => {
                 this.boolShowSpinner = false;
             });
         }
         else {
             downloadExamHallTicketPDF({StudentSRN : this.SRNNumber}).then(response => {
                this.boolShowSpinner = false;
                window.open(response.url);
            })
         }
    }
}*/