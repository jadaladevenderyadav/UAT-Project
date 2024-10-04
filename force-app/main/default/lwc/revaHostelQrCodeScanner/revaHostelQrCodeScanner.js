import { LightningElement, track, wire } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateMealStatus from '@salesforce/apex/RevaMealBookingController.updateMealStatus';
export default class RevaHostelQrCodeScanner extends LightningElement {
    @track scannedItems = [];
    myScanner;
    error;
    jsonFormat;
    updateStatusInApex;
    recordId;
    barCode;


    connectedCallback() {
        this.myScanner = getBarcodeScanner();
    }

    handleBarcodeClick(event) {
        if (this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [
                    this.myScanner.barcodeTypes.QR,
                    this.myScanner.barcodeTypes.UPC_E,
                    this.myScanner.barcodeTypes.EAN_13,
                    this.myScanner.barcodeTypes.CODE_39
                ],
                instructionText: 'Scan a QR', //UPC, EAN 13, Code 39',
                successText: 'Scanning complete.'
                
            };
            

            this.myScanner.beginCapture(scanningOptions)
                .then((result) => {
                    this.handleScannedBarcode(result.value);
          
                })
                .catch((error) => {
                    this.error = error + 'Line 34';
                    this.showError('Error', error);
                })
                .finally(() => {
                    this.myScanner.endCapture();
                });
        } else {
           this.showError('Error', 'Scanner not supported on this device');
           
        }
    }

    handleScannedBarcode(barcode) {
        try {
            this.barCode = barcode;
            let [recordId, timestamp] = barcode.split('-');
            this.recordId = recordId;
            this.updateMealStatus(recordId);
        } catch (error) {
            this.error = `Error: ${error.message} ${error.stack}`;
            this.showError("Error", this.error);
            console.error('Error:', this.error);
        }
    }

    updateMealStatus(recordId) {
        updateMealStatus({ recordId: recordId , status: "Availed"})
            .then((result) => {
                this.showSuccess('Success', 'updated successfully.');
             
            })
            .catch((error) => {
                this.error = JSON.stringify(error.body.message);
                this.showError('Update Failed', error.body.message);
            });
    }
   

    showError(title, msg) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    showSuccess(title, msg) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'success'
        });
        this.dispatchEvent(event);
    } 
}