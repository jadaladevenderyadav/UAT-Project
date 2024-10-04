import { LightningElement, track, wire , api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchStudentRegDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails';
import updateStudentRegDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.updateStudentRegDetails';
import uploadAttachment from '@salesforce/apex/Rpl_DocumentUploadClass.uploadAttachment';
import getAttachments from '@salesforce/apex/Rpl_DocumentUploadClass.getAttachments';
import {refreshApex} from '@salesforce/apex';
import {NavigationMixin} from 'lightning/navigation';
import Static_Resources from '@salesforce/resourceUrl/RPL_Static_Resources';

export default class Rpl_RevaDoucmentUpload extends NavigationMixin(LightningElement){
    @api recordId;
    isSpinner = true;
     @api placementRegistrationText;
    studentRegistration = {};
    programType;
    activeSemester;
    wiredStudentData;
    keyForWire = 0;
    wiredAttachmentResult;
    successIcon = Static_Resources + '/Reva_Placement_Static_Resources/Icons/success.png';
    clearIcon = Static_Resources + '/Reva_Placement_Static_Resources/Icons/clear.png';
    isDiplomaStudent;

    data = [
        { id: '1', documentName: 'Tenth Marksheet', fileData: null },
        { id: '2', documentName: 'Twelveth Marksheet', fileData: null },
        { id: '3', documentName: 'Resume', fileData: null }
    ];
    
    modifiedData = [];

   @wire(fetchStudentRegDetails, { recordId: '$recordId' })
    wiredFetchStudentDetails(result) {
        this.wiredStudentData = result;
        if (result.data) {
            this.studentRegistration = { ...result.data[0] };
            this.programType = this.studentRegistration.Rpl_Program_Type__c;
            this.activeSemester = this.studentRegistration.Rpl_Active_Semester__c;
            this.isDiplomaStudent = this.studentRegistration.Rpl_Is_Diploma_Student__c;
            this.generateDocumentData();
            /* this.fetchAttachments(); */
        } else if (result.error) {
            console.error(result.error);
        }
   }
    
    generateDocumentData() {     
        console.log('Diploma Marksheet ' + JSON.stringify(this.isDiplomaStudent));
        //Check whether the student pursued Diploma or not.
        if (this.isDiplomaStudent) {
               this.data = [
        { id: '1', documentName: 'Tenth Marksheet', fileData: null },
        { id: '2', documentName: 'Diploma Marksheet', fileData: null },
        { id: '3', documentName: 'Resume', fileData: null }
    ];
        } else {
              this.data = [
        { id: '1', documentName: 'Tenth Marksheet', fileData: null },
        { id: '2', documentName: 'Twelveth Marksheet', fileData: null },
        { id: '3', documentName: 'Resume', fileData: null }
    ];
        }
       
        // Generate documents based on Program Type
        if (this.programType === 'UG') {
            for (let i = 1; i <= this.activeSemester - 1; i++) {
                this.data.push({
                    id: i + 3,
                    documentName: `UG Semester ${i} Marksheet`,
                    fileData: null
                });
            }
        } else if (this.programType === 'PG') {
            this.data.push({
                id: '4',
                documentName: 'UG Cumulative Marksheet',
                fileData: null
            });

            for (let i = 1; i < this.activeSemester; i++) {
                this.data.push({
                    id: i + 4,
                    documentName: `PG Semester ${i} Marksheet`,
                    fileData: null
                });
            }
        }
    }

    @wire(getAttachments, { recordId: '$recordId' })
    async wiredAttachments(result) {
        this.isSpinner = true;
        this.wiredAttachmentResult = result;
        if (result.data) {
            this.modifiedData = [];
            this.modifiedData = this.data.map((row) => {
                let iconName = 'utility:spinner';
                let iconSize = 'medium';
                let imgSrc = this.clearIcon;
                const matchingAttachment = result.data.find((attachment) =>
                    attachment.Name.includes(row.documentName)
                );

                let isDisabled = false;
                if (matchingAttachment) {                     
                        iconName = 'action:approval';
                        iconSize = 'x-small';
                        imgSrc = this.successIcon;
                        if (matchingAttachment.Name.includes('Tenth Marksheet')) {
                            isDisabled = matchingAttachment.isTenthVerified;
                        } else if (matchingAttachment.Name.includes('Twelveth Marksheet')) {
                            isDisabled = matchingAttachment.isTwelvethVerified;
                        } else if (matchingAttachment.Name.includes('Diploma Marksheet')) {
                            isDisabled = matchingAttachment.isDiplomaVerified;
                        } else if (matchingAttachment.Name.includes('Resume')) {
                            isDisabled = matchingAttachment.isResumeVerified;
                        } else if (matchingAttachment.Name.includes('UG Semester')) {
                            const semesterNumber = this.extractSemesterNumber(matchingAttachment.Name);
                            if (semesterNumber) {
                                isDisabled = this.isSemesterVerified(matchingAttachment.ugVerifiedSemesterMarksheets , semesterNumber);
                            }
                        } else if (matchingAttachment.Name.includes('UG Cumulative Marksheet')) {
                            isDisabled = matchingAttachment.isUgAggregateVerified;
                        } else if (matchingAttachment.Name.includes('PG Semester')) {
                            const semesterNumber = this.extractSemesterNumber(matchingAttachment.Name);
                            if (semesterNumber) {
                                isDisabled = this.isSemesterVerified(matchingAttachment.pgVerifiedSemesterMarksheets , semesterNumber);
                            }
                        } 
                    }
                return {
                    id: row.id,
                    documentName: row.documentName,
                    fileData: matchingAttachment ? matchingAttachment.bodyBase64 : null,
                    isButtonDisabled: isDisabled,
                    contentDocumentId: matchingAttachment ? matchingAttachment.id : null,
                    iconName,
                    iconSize,
                    imgSrc,
                };
            });
            this.isSpinner = false;
        } else if (result.error) {
            console.error('Error fetching attachments:', result.error);
            const evnt = new ShowToastEvent({
                title: "Error Occurred While Processing",
                message : result.error.body.message
            })
            this.dispatchEvent(evnt);
            this.isSpinner = false;
        }
    
    }
    extractSemesterNumber(documentName) {
    const match = documentName.match(/\d+/);
    return match ? parseInt(match[0], 10) : null;
    }

    isSemesterVerified(verifiedSemesterField, semesterNumber) {
        // Check if the semesterNumber is present in the verified semester field
        return verifiedSemesterField.includes(semesterNumber.toString());
    }


    handleUploadClick(event) {
        this.isSpinner = true;
        const rowId = event.target.dataset.rowId;
        const selectedRow = this.modifiedData.find(row => row.id == rowId);
        const input = this.template.querySelector(`input[data-row-id="${rowId}"]`);
        input.click();
        this.isSpinner = false;
    }

handleFileChange = async (event) => {
    this.isSpinner = true;
    const rowId = event.target.dataset.rowId;
    const selectedRow = this.modifiedData.find(row => row.id == rowId);
    const fileInput = event.target;
    const file = fileInput.files[0];
    const fileExtension = file ? file.name.split('.').pop() : '';
    console.log('File Extendsion ' + fileExtension);
    if (file) {
        if (fileExtension != 'pdf') {
            this.isSpinner = false;
             this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Upload only PDF files',
                    variant: 'error'
                })
            );
            return;
        }
        if (file.size > 2097152) {
            const fileSizeInMB = (file.size / (1024 * 1024)).toFixed(2);
            this.isSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'File size exceeds the allowed limit of 2MB. Your file size is ' +fileSizeInMB +' MB',
                    variant: 'error'
                })
            );
            return; // Stop further processing
        }
        try {
            const fileDataBlob = await this.readFileAsDataURL(file);
            // Update the data array with the Blob for the correct row
            selectedRow.fileData = fileDataBlob;
            
            // Show success toast message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Document attached successfully!',
                    variant: 'success'
                })
            );
            this.isSpinner = false;
        } catch (error) {
            this.isSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({    
                    title: 'Error',
                    message: error.body.message,
                    variant: 'destructive'
                })
            );
            console.error('Error reading file: ', error);
        }
    }
}

readFileAsDataURL(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();

        // Set up an event handler for when the reading is completed
        reader.onload = () => {
            // Resolve with the result of reading the file as data URL
            resolve(reader.result.split(',')[1]);
        };

        // Set up an event handler for errors
        reader.onerror = error => {
            reject(error);
        };  

        // Read the file as a data URL
        reader.readAsDataURL(file);
    }); 
}
handlePreviewClick(event){

    const rowId = event.target.dataset.rowId;
    const selectedRow = this.modifiedData.find(row => row.id == rowId);
    const byteCharacters = atob(selectedRow.fileData);
    const byteNumbers = new Array(byteCharacters.length);

    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }

    const byteArray = new Uint8Array(byteNumbers);
    const blob = new Blob([byteArray], { type: 'application/pdf' }); 
    const fileURL = URL.createObjectURL(blob);
    window.open(fileURL, '_blank');  
 
}

    handleSubmitClick(event) {
        this.isSpinner = true;
        const rowId = event.target.dataset.rowId;
        const selectedRow = this.modifiedData.find(row => row.id == rowId);
        const fileData = selectedRow.fileData;

        if (!fileData) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please attach a document before trying to submit it.',
                    variant: 'info'
                })
            );
            this.isSpinner = false;
            return;
        }

        let documentName;
        if (selectedRow.documentName === 'Tenth Marksheet') {
            documentName = 'Tenth Marksheet.pdf';
        } else if (selectedRow.documentName === 'Twelveth Marksheet') {
            documentName = 'Twelveth Marksheet.pdf';
        } else if (selectedRow.documentName === 'Diploma Marksheet') {
            documentName = 'Diploma Marksheet.pdf';
        } else if (selectedRow.documentName === 'Resume') {
            documentName = 'Resume.pdf';
        } else if (selectedRow.documentName.includes('UG Semester')) {
            // Handling UG Semester Marksheet
            documentName = `${selectedRow.documentName}.pdf`;
        } else if (selectedRow.documentName === 'UG Cumulative Marksheet') {
            documentName = 'UG Cumulative Marksheet.pdf';
        } else if (selectedRow.documentName.includes('PG Semester')) {
            // Handling PG Semester Marksheet
            documentName = `${selectedRow.documentName}.pdf`;
        } else {
            documentName = 'Unknown Document';
        }
        const srnNo = this.studentRegistration.Rpl_SRN__c ? this.studentRegistration.Rpl_SRN__c : '';
        documentName = srnNo + ' - ' + documentName;
       
        uploadAttachment({ documentName: documentName , fileData: fileData, recordId: this.recordId })
              .then(result => {
                this.showSuccessToast();
              })
              .catch(error => {
                  console.error('Error uploading document: ', error);
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error',
                          message: error.body.message,
                          variant: 'error'
                      })
                  );
                  this.isSpinner = false;
              });
    }
    async showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Document submitted successfully!',
            variant: 'success',
        });
        this.dispatchEvent(event);
        this.isSpinner = true;
        await refreshApex(this.wiredAttachmentResult);
        this.isSpinner = false;
        return;
    }

  

    handleNext(){
        const event = new CustomEvent('shownextstage');
        this.dispatchEvent(event);
    }

}