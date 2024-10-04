/*import { LightningElement } from 'lwc';

export default class RegAcademicYear extends LightningElement {
 /*   generatePDF() {
        // URL of the Visualforce page
        let vfPageURL = '/apex/GeneratePDFPage';

        // Open the Visualforce page in a new tab/window
        window.open(vfPageURL);
    } */
/*
    pdfUrl;
    showPDF = false;

    generatePDF() {
        // Call the Visualforce page to generate the PDF
        const vfPageName = 'GeneratePDFPage'; //'GeneratePDFPage'; // Replace with your Visualforce page name
        this.pdfUrl = `/apex/${vfPageName}`;
        this.showPDF = true;
    }
} 
*/
import { LightningElement, track, api } from 'lwc';
import uploadFile from '@salesforce/apex/RegFormFileController.uploadFile';
import getFiles from '@salesforce/apex/RegFormFileController.getFiles';
import getRegistrationFormImage from '@salesforce/apex/RegFormFileController.getRegistrationFormImage';
import getContentVersionDownloadUrl from '@salesforce/apex/RegFormFileController.getContentVersionDownloadUrl';
import getImageContent from '@salesforce/apex/RegFormFileController.getImageContent';

export default class RegAcademicYear extends LightningElement {
    @api recordId;
    @track files = [];
    @track filePreview;
    @track regFormImage = [];
    fileData;
    @track
    fileselected = false; // Track file selection state
    @track 
    isModalOpen = false;
    @track
    imageUrlPath = 'https://reva-university--couat1908.sandbox.my.salesforce.com/sfc/p/0T0000000qZR/a/Il000000PBOd/3YbtAyZyAO0OiLrtxH81jjvN9DJu9CClrf69Rp3Mi0U';
    uploading = false;

    connectedCallback() {
        this.loadFiles();
        this.loadRegFormImage();
    }

    loadFiles() {
        getFiles({ contactId: this.recordId })
            .then(result => {
                this.files = result.map(file => ({
                    ...file,
                    previewUrl: `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=${file.LatestPublishedVersionId}`                    
                    //previewUrl : `/sfc/servlet.shepherd/document/download/${file.LatestPublishedVersionId}`
                }));
                this.filePreview = this.files[0].previewUrl;
            })
            .catch(error => {
                console.error('Error loading files', error);
            });
    }

    loadRegFormImage(){
        getRegistrationFormImage()
        .then(result => {
            this.regFormImage = result.map(file => ({
                ...file,
                previewUrl: `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=${file.LatestPublishedVersionId}`
            }));
            
        })
        .catch(error => {
                console.error('Error loading RegFormImage', error);
        })
    }
    /*
    handleFileChange(event) {
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            const reader = new FileReader();
            reader.onload = () => {
                this.fileData = {
                    fileName: file.name,
                   // fileName: 'FilledRegForm',
                    base64: reader.result.split(',')[1],
                    contentType: file.type
                };
            };
            reader.readAsDataURL(file);
        }
    }
    */
    /*
    handleFileChange(event) { 

        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            const reader = new FileReader();
            reader.onload = () => {
                this.fileData = {
                    fileName: 'Filled Registration Form.' + file.name.split('.').pop(), // Rename the file
                    base64: reader.result.split(',')[1],
                    contentType: file.type
                };
                this.fileSelected = false; // Enable upload button
            };
            reader.readAsDataURL(file);
        } else {
            this.fileSelected = true; // Disable upload button if no file is selected
        }
    }
    */

    handleFileChange(event) {
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            if (file.type === 'application/pdf') { // Ensure it's a PDF file
                const reader = new FileReader();
                reader.onload = () => {
                    this.fileData = {
                        fileName: file.name,
                        base64: reader.result.split(',')[1],
                        contentType: file.type
                    };
                };
                reader.readAsDataURL(file);
              //  this.uploading = true;
            } else {
                alert('Please upload a PDF file.');
            }
        }
    }

    uploadFile() {
        if (this.fileData) {
            this.uploading = true;
            uploadFile({
                contactId: this.recordId,
                //fileName: this.fileData.fileName,
                fileName: 'FilledRegForm.pdf',
                base64Data: this.fileData.base64,
                contentType: this.fileData.contentType
            })
                .then(() => {
                    this.fileData = null;
                    this.fileSelected = true; // Reset file selection state
                    this.loadFiles();
                })
                .catch(error => {
                    console.error('Error uploading file', error);
                })
                .finally(() => {
                    this.uploading = false; // Hide uploading indicator or enable button
                });
        }
    }    

    handleImageClick() {
        this.isModalOpen = true;
    }

    handleClose() {
        this.isModalOpen = false;
    }

    downloadFile1(event) {
        const contentVersionId = event.target.dataset.id;
        getContentVersionDownloadUrl({ contentVersionId })
            .then(url => {
                window.open(url, '_blank');
            })
            .catch(error => {
                console.error('Error downloading file', error);
            });
    }

    downloadImage() {
        getImageContent({ imageUrl: 'https://reva-university--couat1908.sandbox.my.salesforce.com/sfc/p/0T0000000qZR/a/Il000000PBOd/3YbtAyZyAO0OiLrtxH81jjvN9DJu9CClrf69Rp3Mi0U'})
            .then(result => {
                this.downloadFile('RegistrationForm.pdf', result);
            })
            .catch(error => {
                console.error('Error fetching image:', error);
            });
    }

    downloadFile(fileName, fileContent) {
        const element = document.createElement('a');
        element.href = URL.createObjectURL(new Blob([fileContent], { type: 'pdf'}));  // { type: 'image/png'}
        element.download = fileName;
        document.body.appendChild(element); // Required for Firefox
        element.click();
        document.body.removeChild(element);
    }
}