import { LightningElement, track } from 'lwc';
import formFactorPropertyName from "@salesforce/client/formFactor";
import fetchData from '@salesforce/apex/ASM_StdIAMarksViewv2.fetchData';

export default class Rve_ViewIAMarks extends LightningElement {
    boolShowSpinner = true;
    @track screen = formFactorPropertyName;
    smallscreen = false;
    IATypesOptionSelected = 'IA1';
    showIAMarks = false;
    activeSem = '';

    @track iaMarksRecords = [];
    @track iaMarks = {
        activeSem: '',
        crsType: '',
        list_IAMarks: {
            Course_Offering__r: {
                hed__Course__r: {}
            }
        },
    };

    get IATypesOptions() {
        return [
            { label: 'IA1', value: 'IA1' },
            { label: 'IA2', value: 'IA2' }
        ];
    }

    connectedCallback() {
        if (this.screen === 'Small') {
            this.smallscreen = true;
        }
        this.fetchIAData(this.IATypesOptionSelected);
    }

    fetchIAData(iaType) {
        this.showIAMarks = false;
        this.boolShowSpinner = true;
        fetchData({ iaType: iaType })
            .then(result => {
                // Check if the result is empty
                if (!result || !result.list_crsWpr || result.list_crsWpr.length === 0) {
                    this.showIAMarks = false;
                    this.boolShowSpinner = false;
                    return; // Stop further processing if no data is returned
                }

                this.activeSem = result.activeSem;
                this.iaMarksRecords = result?.list_crsWpr.map(item => {
                    let isTheoryCRSType = item.crsType == 'Theory' ? true : false;
                    let isProjectCRSType = item.crsType == 'Project' ? true : false;
                    let isPracticalCRSType = item.crsType == 'Practical' ? true : false;
                    let hedCourse = item?.list_IAMarks[0]?.Course_Offering__r?.hed__Course__r;
                    let showTable = hedCourse != null ? true : false;
                    return { 
                        ...item, 
                        isTheoryCRSType: isTheoryCRSType, 
                        isProjectCRSType: isProjectCRSType, 
                        isPracticalCRSType: isPracticalCRSType, 
                        hedCourse: hedCourse, 
                        showTable: showTable 
                    };
                });
                this.showIAMarks = result?.list_crsWpr.length > 0 ? true : false;
                this.boolShowSpinner = false;
            })
            .catch(error => {
                this.boolShowSpinner = false;
                console.error('Error fetching IA Marks:', error);
            });
    }

    handleChangeIATypes(event) {
        this.IATypesOptionSelected = event.detail.value;
        this.fetchIAData(this.IATypesOptionSelected);
    }
}




/*import { LightningElement, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import formFactorPropertyName from "@salesforce/client/formFactor";

// Import from Apex
import fetchData from '@salesforce/apex/ASM_StdIAMarksViewv2.fetchData';


export default class Rve_ViewIAMarks extends LightningElement {
    boolShowSpinner = true;
    @track screen = formFactorPropertyName;
    smallscreen = false;
    IATypesOptionSelected = 'IA1';
    showIAMarks = false;
    showProjectIA = false;
    showTheoryIA = false;
    activeSem = '';
    
    @track iaMarksRecords = []
    @track iaMarks = {
        activeSem: '',
        crsType: '',
        list_IAMarks: {
            Course_Offering__r: {
                hed__Course__r: {}
            }
        },
    };

    get IATypesOptions() {
        return [
            { label: 'IA1', value: 'IA1' },
            { label: 'IA2', value: 'IA2' }
        ];
    }

    connectedCallback() {
        if (this.screen === 'Small') {
            this.smallscreen = true;
        }
        this.fetchIAData(this.IATypesOptionSelected);
    }

    fetchIAData(iaType) {
        this.showIAMarks = false;
        this.boolShowSpinner = true;
        fetchData({ iaType: iaType })
            .then(result => {
                if(!result || !result.list_crsWpr || result.list_crsWpr.length===0){
                this.showIAMarks=false;
                this.boolShowSpinner=true;
                return;
            }
                this.activeSem = result.activeSem;
                this.iaMarksRecords = result?.list_crsWpr.map(item => {
                    let isTheoryCRSType = item.crsType === 'Theory';
                    let isProjectCRSType = item.crsType === 'Project';
                    let isPracticalCRSType = item.crsType === 'Practical';
                    let hedCourse = item?.list_IAMarks[0]?.Course_Offering__r?.hed__Course__r || {};
                    let showTable = hedCourse != null && Object.keys(hedCourse).length > 0;
                    return {
                        ...item,
                        isTheoryCRSType: isTheoryCRSType,
                        isProjectCRSType: isProjectCRSType,
                        isPracticalCRSType: isPracticalCRSType,
                        hedCourse: hedCourse,
                        showTable: showTable
                    };
                });
                this.showIAMarks = result?.list_crsWpr.length > 0;
                this.boolShowSpinner = false;
            })
            .catch(error => {
                this.boolShowSpinner = false;
                console.error('Error fetching data', error);
            });
    }

    handleChangeIATypes(event) {
        this.IATypesOptionSelected = event.detail.value;
        this.fetchIAData(this.IATypesOptionSelected);
    }
}























/*import { LightningElement, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import formFactorPropertyName from "@salesforce/client/formFactor";

// Import from Apex
import fetchData from '@salesforce/apex/ASM_StdIAMarksViewv2.fetchData';


export default class Rve_ViewIAMarks extends LightningElement {
    boolShowSpinner = true;
    @track screen=formFactorPropertyName;
    smallscreen =false;
    IATypesOptionSelected = 'IA1';
    showIAMarks = false;
    showProjectIA = false;
    showTheoryIA = false;
    activeSem = '';
    @track iaMarksRecords = []
    @track iaMarks = {
        activeSem : '',
        crsType : '',
        list_IAMarks : {
            Course_Offering__r : {
                hed__Course__r : {}
            }
        },
    };


    get IATypesOptions() {
        return [
            { label: 'IA1', value: 'IA1' },
            { label: 'IA2', value: 'IA2' }
        ];
    }

    connectedCallback(){
        if(this.screen==='Small'){
            this.smallscreen=true;
        }
        this.fetchIAData(this.IATypesOptionSelected);
    }

    fetchIAData(iaType){
        this.showIAMarks = false;
        this.boolShowSpinner = true;
        fetchData({iaType : iaType})
        .then(result => {
            this.activeSem = result.activeSem;
            this.iaMarksRecords = result?.list_crsWpr.map(item => {
                let isTheoryCRSType = item.crsType == 'Theory' ? true : false;
                let isProjectCRSType = item.crsType == 'Project' ? true : false;
                let isPracticalCRSType = item.crsType == 'Practical' ? true : false;
                let hedCourse = item?.list_IAMarks[0]?.Course_Offering__r?.hed__Course__r;
                let showTable = hedCourse != null ? true : false;
                return {...item, isTheoryCRSType : isTheoryCRSType, isProjectCRSType : isProjectCRSType, isPracticalCRSType : isPracticalCRSType, hedCourse : hedCourse, showTable : showTable}
            })
            this.showIAMarks = result?.list_crsWpr.length > 0 ? true : false;
            this.boolShowSpinner = false;
        })
        .catch(error => {
            this.boolShowSpinner = false;
        })
    }

    handleChangeIATypes(event){
        this.IATypesOptionSelected = event.detail.value;
        this.fetchIAData(this.IATypesOptionSelected);
    }
}*/