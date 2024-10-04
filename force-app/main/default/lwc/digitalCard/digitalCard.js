import { LightningElement, wire, track } from 'lwc';
import getALUData from '@salesforce/apex/ALU_DigitalCard_Ext.getALUData';
export default class DigitalCard extends LightningElement {
    aluData;
    studentImageUrl;

    connectedCallback() {
        this.loadData();
    }
    loadData(){
        getALUData().then(result=>{
            if(result){
                this.aluData=result.objContact;
                this.studentImageUrl=result.studentImageUrl;
            }
        }).catch(error => {
            console.error('Error loading data', error);
        });
    }
    }