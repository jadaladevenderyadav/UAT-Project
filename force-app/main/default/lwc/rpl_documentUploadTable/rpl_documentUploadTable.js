import { LightningElement, track, wire , api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import uploadAttachment from '@salesforce/apex/Rpl_DocumentUploadClass.uploadAttachment';
import getAttachments from '@salesforce/apex/Rpl_DocumentUploadClass.getAttachments';
import IsDeleted from '@salesforce/schema/Account.IsDeleted';

export default class Rpl_documentUploadTable extends NavigationMixin(LightningElement) {
    @api recordId;
    isSpinner = true;
    @track data = [
        { id: '1', documentName: 'Tenth Marksheet', fileData: null },
        { id: '2', documentName: 'Twelveth Marksheet', fileData: null },
        { id: '3', documentName: 'Resume', fileData: null }
    ];
    
    @track modifiedData = [];

    @wire(getAttachments, { recordId: '$recordId' })
    wiredAttachments({ error, data }) {

    this.isSpinner = true;
    console.log('Inside wired method ; Id ' + this.recordId);
    if (data) {
        console.log('Incoming Data '+JSON.stringify(data));
        // Transform the data received from Apex to match the structure of your component
        this.modifiedData = this.data.map(row => {
            //const matchingAttachment = data.find(attachment => attachment.Name.replace('.pdf', '') === row.documentName);
            const matchingAttachment = data.find(attachment =>   attachment.Name.includes(row.documentName));
            console.log('Matching Data ' + matchingAttachment);
            let isDisabled; 
            if(matchingAttachment){
                //console.log('Matching Attachments ' + JSON.stringify(matchingAttachment));
                if(matchingAttachment.Name.includes('Tenth Marksheet')){
                    isDisabled = matchingAttachment.isTenthVerified;
                }else if(matchingAttachment.Name.includes('Twelveth Marksheet')){
                    isDisabled = matchingAttachment.isTwelvethVerified;
                }else if(matchingAttachment.Name.includes('Resume')){
                    isDisabled = matchingAttachment.isResumeVerified;
                }
            }
            return {
                id: row.id,
                documentName: row.documentName,
                fileData: matchingAttachment ? matchingAttachment.bodyBase64 : null,
                isButtonDisabled : isDisabled
            };
        });
        //this.isSpinner = false;
        console.log('Wired data ' + JSON.stringify(this.modifiedData));
        this.isSpinner = false;
    } else if (error) {
        console.error('Error fetching attachments:', error);
    }
    }



    handleUploadClick(event) {
        this.isSpinner = true;
        const rowId = event.target.dataset.rowId;
        const input = this.template.querySelector(`input[data-row-id="${rowId}"]`);
        console.log(rowId + ' ' + input);
        input.click();
        this.isSpinner = false;
    }

handleFileChange = async (event) => {
    this.isSpinner = true;
    const rowId = event.target.dataset.rowId;
    const selectedRow = this.modifiedData.find(row => row.id === rowId);
    const fileInput = event.target;
    const file = fileInput.files[0];

    if (file) {
        try {
            const fileDataBlob = await this.readFileAsDataURL(file);

            // Update the data array with the Blob for the correct row
            selectedRow.fileData = fileDataBlob;
            
            // Show success toast message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Document uploaded successfully!',
                    variant: 'success'
                })
            );
            this.isSpinner = false;
            console.log('Modified Data ' + JSON.stringify(this.modifiedData));
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
    const selectedRow = this.modifiedData.find(row => row.id === rowId);
    
    // Convert base64 to Blob
    const byteCharacters = atob(selectedRow.fileData);
    const byteNumbers = new Array(byteCharacters.length);

    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }

    const byteArray = new Uint8Array(byteNumbers);
    const blob = new Blob([byteArray], { type: 'application/pdf' }); // Change the type based on your file type

    // Open the Blob in a new tab or window
    const fileURL = URL.createObjectURL(blob);
    window.open(fileURL, '_blank');
    //this.downloadPDF(selectedRow.fileData, selectedRow.documentName);
}

    handleSubmitClick(event) {
        this.isSpinner = true;
        const rowId = event.target.dataset.rowId;
        const selectedRow = this.modifiedData.find(row => row.id === rowId);
        const fileData = selectedRow.fileData;
        let documentName = selectedRow.documentName === 'Tenth Marksheet'? 'Tenth Marksheet.pdf' :  selectedRow.documentName === 'Twelveth Marksheet' ? 'Twelveth Marksheet.pdf' : selectedRow.documentName === 'Resume' ? 'Resume.pdf' : 'Unknown Document'
        if (!fileData) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please upload a document first.',
                    variant: 'error'
                })
            );
            this.isSpinner = false;
            return;
        }

          uploadAttachment({ documentName: documentName , fileData: fileData, recordId: this.recordId })
              .then(result => {
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Success',
                          message: 'Document submitted successfully!',
                          variant: 'success'
                      })
                  );
                  this.isSpinner = false;
                  //location.reload();

              })
              .catch(error => {
                  console.error('Error uploading document: ', error);
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error',
                          message: 'Make sure to upload the pdf file size below 2MB',
                          variant: 'error'
                      })
                  );
                  this.isSpinner = false;
              }); 
    }

    handleSaveButton(event){
        
          this.dispatchEvent(new CustomEvent('documentuploadcompleted',{
            }));
    }
}