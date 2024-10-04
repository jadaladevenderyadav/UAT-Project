import { LightningElement, api, wire, track } from 'lwc';
/* import createNewContentVersion from '@salesforce/apex/TestClassForSaveExcel.createNewContentVersion';
 */// datatable columns
const cols = [
    {label: 'Student Name',fieldName: 'Rpl_Student_Name__c', type:'text'}, 
    {label: 'SRN',fieldName: 'Rpl_SRN__c', type:'text'},
    {label: 'Recruitment Stage Name',fieldName: 'Rpl_Recruitment_Stage_Name__c',type: 'text'}, 
    {label: 'Round',fieldName: 'Rpl_Current_Interview_Round__c',type: 'text'}, 
    {label: 'Account Id',fieldName: 'Rpl_Result__c', type:'text'},  
    {label: 'Drive Name',fieldName: 'Drive_Name__c', type:'text'},  
];
 

export default class GenerateCSVLWC extends LightningElement {
    @track error;
    @api interviewResults = [];
    @track columns = cols;
    @api fileName;
    
    set incomingData(incomingData = []){
        this.interviewResults = [...incomingData];
    }

    @api
    get incomingData(){
        return this.interviewResults;
    }

    // this method validates the data and creates the csv file to download
    @api
    downloadCSVFile() {  
       
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
 
        // getting keys from data
        this.interviewResults.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });
 
        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
         
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
 
        // main for loop to get the data based on key value
        for(let i=0; i < this.interviewResults.length; i++){
            let colValue = 0;
 
            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.interviewResults[i][rowKey] === undefined ? '' : this.interviewResults[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }   
            }
            csvString += rowEnd;
        }
       /*  let encodedCsvString = btoa(csvString);
        createNewContentVersion({ documentName: 'Test Attachment ', fileData: encodedCsvString, recordId: 'a2n0T000000DLXEQA4' })
            .then(result => console.log('File Attached ' + result))
            .catch(error => console.error('Attachment Failed ' + error.body.message)) */
        // Creating anchor element to download
        let downloadElement = document.createElement('a');
       
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = this.fileName + '.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }
 
}