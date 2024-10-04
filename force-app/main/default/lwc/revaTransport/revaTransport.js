import { LightningElement, wire, track } from 'lwc';
import revaTransportRegPage from '@salesforce/apex/RevaTransportHandler.revaTransportRegPage'
import revaTransportPortal from '@salesforce/apex/RevaTransportHandler.revaTransportPortal';
import ContactDetails from '@salesforce/apex/RevaTransportHandler.ContactDetails';
import RTR_IMAGE_1 from '@salesforce/resourceUrl/RTR_Image_1';
import RTR_IMAGE_4 from '@salesforce/resourceUrl/RTR_Image_4';


export default class RevaTransport extends LightningElement {
    /* Display Registration information */
    programBatch = [];
    ProgramBatchName;
    //programBatchName;
    @track revaRegistrationPage;
    @track revaReg = [];
    @track revaTransportRecordId;// capturing record Id of revaTransport record
    @track revaTransportRecordName = '';
    @track showStudentTransportForm = false;
    @track showParentComponent = true;
    loginDetails;
    loginUserName;
    ReadytobeTransitioned;
    showCourseData = false;
    @track showData = false;
 
    IMAGES = {
        rtrImage1: RTR_IMAGE_1
    }
    
    IMAGESTR = {
        rtrImage4: RTR_IMAGE_4
    }

    //For Contact Details
    @wire(ContactDetails)
    getContactDetails({ data, error }) {
        if (data) {
            // alert(JSON.stringify(data));
            this.loginDetails = data;
            console.log('loginDetails-->> ', data);
            if (data.Name != null) {
                this.loginUserName = data.Name;
                this.ReadytobeTransitioned = data.Ready_to_be_Transitioned__c;

                console.log('ReadytobeTransitioned-->> ' + this.ReadytobeTransitioned);
                console.log('Name-->> ' + this.loginUserName);
            }

            // if (data.Program_Batch__r.Name != null) {
            //     this.programBatchName = data.Program_Batch__r.Name;
            //     console.log('ProgramBatchName-->>', this.programBatchName);
            // }

            console.log('this.loginDetails.Record_Type_Name__c-->> ', this.loginDetails.Record_Type_Name__c)

            if (this.loginDetails.Record_Type_Name__c === 'Student') {
                this.showCourseData = true;
            }
            else {
                this.showCourseData = false;
            }
        }
        if (error) {
            console.log(error);
        }
    }

    //For Registration Details
    @wire(revaTransportRegPage)
    registrationRecords({ data, error }) {
        if (data) {
            console.log('Registration Details-->> ', data)
            if (data.Id) {
                this.revaRegistrationPage = data;
                //this.showData = true;
                console.log('Data', this.revaRegistrationPage);
            }
            else {
                //this.showData = false;
            }
        }
        else if (error) {
            console.error('Student has not registered for transport ' + error)
        }
    }

    get regStatus() {
        const status = this.revaRegistrationPage.Registration_Status__c;
        if (status === 'Cancelled') {
            return 'slds-text-color_error';
        } else if (status === 'Active') {
            return 'slds-text-color_success';
        }
        else {
            return '';
        }

        //return `${this.revaRegistrationPage.Registration_Status__c === 'Cancelled' ? 'slds-text-color_error' : 'slds-text-color_success'}`
    }

    //For Registration Button
    @wire(revaTransportPortal)
    revaRegistrationRecord({ data, error }) {
        if (data) {
            // this.programType = data[0].Program_Types__r;
            // console.log('programType-->> ', this.programType);
            // if (Array.isArray(this.programType)) {
            //     this.programType.forEach(item => {
            //         if (item) {
            //             if (item.Name) {
            //                 this.ProgramTypeName = item.Name;
            //                 console.log('ProgramTypeName-->> ', this.ProgramTypeName);

            //                 if ((this.loginDetails.Record_Type_Name__c === 'Student')) {
            //                     if (this.ProgramTypeName === this.loginDetails.Program_Batch__r.Name) {
            //                         console.log('inside if block', this.ProgramTypeName)
            //                         console.log('REGISTER Button-->> ', data);
            //                         this.revaReg = data;
            //                         console.log('Registration Records---->>> ' + JSON.stringify(this.revaReg));
            //                     }
            //                     else {
            //                         console.log('Program Batch Name and Program Type is not Matching');
            //                     }
            //                 }
            //                 else {
            //                     console.log('else block entered of non-student i.e professor and non-teaching')
            //                     console.log('REGISTER Button-->> ', data);
            //                     this.revaReg = data;
            //                     console.log('Registration Records---->>> ' + JSON.stringify(this.revaReg));
            //                 }

            //             }
            //         }
            //     })
            // }

            this.programBatch = data[0].Program_Batches__r;
            console.log('programBatch-->> ', this.programBatch);
            if (Array.isArray(this.programBatch)) {
                this.programBatch.forEach(item => {
                    if (item) {
                        if (item.Name) {
                            this.ProgramBatchName = item.Name;
                            console.log('ProgramBatchName-->> ', this.ProgramBatchName);

                            if ((this.loginDetails.Record_Type_Name__c === 'Student')) {
                                if (this.ProgramBatchName === this.loginDetails.Program_Batch__r.Name) {
                                    console.log('inside if block', this.ProgramBatchName)
                                    console.log('REGISTER Button-->> ', data);
                                    this.revaReg = data;
                                    console.log('Registration Records---->>> ' + JSON.stringify(this.revaReg));
                                }
                                else {
                                    console.log('Program Batch Name is not Matching');
                                }
                            }
                            else if (this.loginDetails.Record_Type_Name__c === 'Applicant' && this.ReadytobeTransitioned === true) {
                                console.log('REGISTER Button-->> ', data);
                                this.revaReg = data;
                                console.log('Registration Records---->>> ' + JSON.stringify(this.revaReg));
                            }
                            else if (this.loginDetails.Record_Type_Name__c === 'Professor' || this.loginDetails.Record_Type_Name__c === 'Non Teaching') {
                                console.log('else block entered of non-student i.e professor and non-teaching')
                                console.log('REGISTER Button-->> ', data);
                                this.revaReg = data;
                                console.log('Registration Records---->>> ' + JSON.stringify(this.revaReg));
                            }

                        }
                    }
                })
            }

        }
        else if (error) {
            console.error(error);
        }
    }

    handleNavigation(event) {
        this.revaTransportRecordId = event.target.dataset.key;
        this.revaTransportRecordName = event.target.dataset.name;
        console.log(`Target revaTransport Record Id---->>> ${this.revaTransportRecordId}`)
        console.log(`Target revaTransport RecordName---->>> ${this.revaTransportRecordName}`)
        this.showStudentTransportForm = true
        this.showParentComponent = false;

        // Navigate to revaTransport Registration Page
        //window.location.href = `/StudentPortal/s/transport-registration-page?recordId=${this.revaTransportRecordId}`;
    }
}