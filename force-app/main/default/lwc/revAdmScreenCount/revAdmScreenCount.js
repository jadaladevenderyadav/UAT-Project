import { LightningElement, api } from 'lwc';

export default class RevAdmScreenCount extends LightningElement {
    @api screenValue;
    sendData() {
        const selectedEvent = new CustomEvent('senddata', { detail: this.screenValue });
        alert('Screen Value' + this.screenValue);
        this.dispatchEvent(selectedEvent);
    }
    @api
    getFlowVariable() {
        alert('sss' + '$screenValue');
        return this.screenValue;
    }


}