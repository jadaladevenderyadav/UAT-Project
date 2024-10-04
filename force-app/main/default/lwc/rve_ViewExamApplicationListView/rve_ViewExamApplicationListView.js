import { LightningElement, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';

// Import from Apex
import getExamApplicationList from '@salesforce/apex/Rve_ViewExamApplicationController.getExamApplicationList';

export default class Rve_ViewExamApplicationListView extends LightningElement {
    recordId = Id; //user ID
    boolShowSpinner = true;
    showTable = false;
    showTableMobile = false;
    showSelectedExamApplication = false;
    selectedId;
    @track examApplicationList = [];

    connectedCallback(){
        let userId = this.recordId;
        getExamApplicationList()
        .then(result => {
            let count = 1;
            this.examApplicationList = result.map(item => {
                return {... item, SN: count++}
            })
            this.boolShowSpinner = false;
            this.showTable = true;
            this.showTableMobile = true;
            console.log('Data >>>>>', this.examApplicationList);
        })
        .catch(error => {
            this.boolShowSpinner = false;
        })
    }

    openSelectedApplication(event){
        this.selectedId = event.target.dataset.id;
        this.showTable = false;
        this.showTableMobile = false;
        this.showSelectedExamApplication = true;
    }

    showListOnBack(){
        this.selectedId = '';
        this.showTable = true;
        this.showTableMobile = true;
        this.showSelectedExamApplication = false;
    }
}