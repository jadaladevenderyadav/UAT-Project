import { LightningElement,track,wire ,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCaseList from  '@salesforce/apex/ALU_RecordListController.getCaseList';

export default class RevaCaseScreenAlu extends NavigationMixin(LightningElement) {

    @api CaseStatus;

    isOpenCases = false;
    //isCreateCases =true;
    isClosedCases = false;

    //@track caseStatus = 'New';
    @track caseList;
    @track error;

    handleStepClick(event){
        const stepNumber = event.target.dataset.step;
        
        if(stepNumber == 1){
            this.isCreateCases = true;
            this.isOpenCases = false;
            this.isClosedCases = false;
            this.updateStyles(stepNumber);
        }
        if(stepNumber == 2){
            this.caseStatus='New';
            this.isOpenCases = true;
            this.isCreateCases = false;
            this.isClosedCases = false;
            this.updateStyles(stepNumber);
           
        }
        if(stepNumber == 3){
            this.caseStatus = 'Closed';
            this.isCreateCases = false;
            this.isOpenCases = false;
            this.isClosedCases = true;
            this.updateStyles(stepNumber);
        }
    }

    updateStyles(stepNumber){
        const tabs = this.template.querySelectorAll('.tab');
        tabs.forEach(tab => {
            const tabStepNumber = tab.dataset.step;
            if(tabStepNumber!=stepNumber){
                tab.style.color = 'black';
                tab.style.backgroundColor = '#FEF3EA';
            }else{
                tab.style.color = 'white';
                tab.style.backgroundColor = '#F57F26';
            }
        })
    }

    @wire(getCaseList, { caseStatus: "$CaseStatus"})
  wiredCases({ error, data }) {
    console.log('wire status passing ---->'+this.CaseStatus);
    if (data) {
      this.caseList = data;
      this.error = undefined;
     // console.log('cases data--->'+JSON.stringify(this.caseList));
    } else if (error) {
      this.error = error;
      this.caseList = undefined;
      console.log('error cases data--->'+this.error);
    }
  }

  navigateToCaseRecord(event) {
    const recordId = event.currentTarget.dataset.id;
    console.log('recordId--->'+recordId);
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            actionName: 'view'
        }
    });
}

}