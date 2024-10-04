import { LightningElement, wire, api, track } from 'lwc';
import fetchData from '@salesforce/apex/ASM_StdResultListView.fetchData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rve_StudentResultView extends LightningElement {
    @api summaryId;
    @api semName;
    @track Spinner = true;
    @track showDetailView = false;
    @track resultDataList = []; // Ensure it's tracked
    @track summaryRec;
    @track feePending = false;

    connectedCallback() {
        this.doInit();
    }

    async doInit() {
        try {
            console.log('SummaryId=> ' + this.summaryId);
            const result = await fetchData({ summaryId: this.summaryId });
            console.log('Fetched Result:', result);
            if (result && result.length > 0) {
                this.resultDataList = result;
                this.summaryRec = this.extractSummaryRec(result);
                this.feePending = false;
                console.log("Result Data List:", JSON.stringify(this.resultDataList)); 
                console.log("Summary Record:", JSON.stringify(this.summaryRec)); 
            } else {
                this.resultDataList = [];
                this.summaryRec = null;
                this.feePending = true;
                this.showToast('dismissible', 'Fees Pending', 'You have pending fees for the current year. Please clear the dues to view results.', 'warning');
            }
        } catch (error) {
            this.Spinner = false;
            this.feePending = false;
            this.showToast('dismissible', 'Failed', error.message, 'error');
        } finally {
            this.Spinner = false;
        }
    }

    extractSummaryRec(result) {
        if (result && result.length > 0) {
            console.log('Result length:', result.length);
            console.log('Result Id:', result[0].Id);
            console.log('Remarks:', result[0].Remarks__c);
            console.log('CGPA:', result[0].CGPA__c);
            console.log('SGPA:', result[0].SGPA__c);
            console.log('Passing Criteria:', result[0].Passing_Criteria__c);
            console.log('Examination Month Year:', result[0].Examination_Month_Year__c);

            return {
                Id: result[0].Id,
                Remarks__c: result[0].Remarks__c,
                CGPA__c: result[0].CGPA__c,
                SGPA__c: result[0].SGPA__c,
                Passing_Criteria__c: result[0].Passing_Criteria__c,
                Examination_Month_Year__c: result[0].Examination_Month_Year__c,
            };
        }
        return null;
    }

    showToast(mode, title, message, type) {
        const evt = new ShowToastEvent({
            mode: mode,
            title: title,
            message: message,
            variant: type,
            duration: '2000'
        });
        this.dispatchEvent(evt);
    }

    toggleDetail(event) {
        this.showDetailView = !this.showDetailView;
    }
}


/*
import { LightningElement, wire, api, track } from 'lwc';
import fetchData from '@salesforce/apex/ASM_StdResultListView.fetchData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rve_StudentResultView extends LightningElement {
    @api summaryId;
    @api semName;
    Spinner = true;
    @track showDetailView = false;
    resultDataList;
    summaryRec;
    @track feePending = false;

    connectedCallback() {
        this.doInit();
    }

    async doInit() {
        try {
            console.log('SummaryId=> ' + this.summaryId);
            const result = await fetchData({ summaryId: this.summaryId });
            console.log('result is==>'+JSON.stringify(result));
            console.log('result length'+result.length());
            
            if (result && result.length > 0) {
                this.resultDataList = result;
                this.summaryRec = this.extractSummaryRec(result);
                this.feePending = false;
            } else {
                // If result is empty, it indicates that fees are pending
                this.resultDataList = [];
                this.summaryRec = null;
                this.feePending = true;
                this.showToast('dismissible', 'Fees Pending', 'You have pending fees for the current year. Please clear the dues to view results.', 'warning');
            }
        } catch (error) {
            this.Spinner = false;
            this.feePending = false;
            this.showToast('dismissible', 'Failed', error.message, 'error');
        } finally {
            this.Spinner = false;
        }
    }

    extractSummaryRec(result) {
        if (result && result.length > 0) {
            return {
                Id: result[0].Id,
                Remarks__c: result[0].Remarks__c,
                CGPA__c: result[0].CGPA__c,
                SGPA__c: result[0].SGPA__c,
                Passing_Criteria__c: result[0].Passing_Criteria__c,
                Examination_Month_Year__c: result[0].Examination_Month_Year__c,
            };
        }
        return null;
    }

    showToast(mode, title, message, type) {
        const evt = new ShowToastEvent({
            mode: mode,
            title: title,
            message: message,
            variant: type,
            duration: '2000'
        });
        this.dispatchEvent(evt);
    }

    toggleDetail(event) {
        this.showDetailView = !this.showDetailView;
    }
}






/*import { LightningElement,wire,api,track } from 'lwc';
import fetchData from '@salesforce/apex/ASM_StudentResultView.fetchData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Rve_StudentResultView extends LightningElement {
    @api summaryId;
    @api semName;
    Spinner = true;
    @track showDetailView =false;
    resultDataList;
    summaryRec;
    @track feePending =false;
    connectedCallback() {
        this.doInit();
    }

    async doInit() {
        try {

            console.log('SummaryId=> '+this.summaryId);
            const result = await fetchData({ summaryId: this.summaryId });
            if (result) {
                this.resultDataList = result.list_Results;
                console.log('this.summaryRec=> '+JSON.stringify(result.summaryRec));
                this.summaryRec = result.summaryRec;
                this.Spinner = false;
                this.feePending = false;

            }
        } catch (error) {
            this.Spinner = false;
            this.feePending = false;
            this.showToast('dismissible', 'Failed', error.message, 'error');
        }
    }

    showToast(mode, title, message, type) {
        const evt = new ShowToastEvent({
            mode: mode,
            title: title,
            message: message,
            variant: type,
            duration: '2000'
        });
        this.dispatchEvent(evt);
    }
    toggleDetail(event){
        this.showDetailView=!this.showDetailView;

    }
}
*/