import { LightningElement, track, wire } from 'lwc';
import getPhotoPic from '@salesforce/apex/WhatsAppMsgTriggeredSummery.getPhoto';

export default class PhotoTest extends LightningElement {
   
    @wire(getPhotoPic)
    wiredSchools({ error, data }) {
        if (data) {            
         //   this.receivedSchoolData = data;
            console.log('Photo result>> '+JSON.stringify(data));
           
        } else if (error) {
            console.log('Gotch error while fetching Photo :' + error);
        }
    }
}