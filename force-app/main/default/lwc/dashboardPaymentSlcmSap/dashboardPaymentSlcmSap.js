import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/DashboardDemo.getAccounts';
import getStringVal from '@salesforce/apex/DashboardDemo.getResponseString';
import feeOnlinePayments from '@salesforce/apex/DashboardDemo.getOnlineFeePaymentStats';
import feeOfflinePayments from '@salesforce/apex/DashboardDemo.getOfflineFeePaymentStats';
import feeOnlinePaymentsMonth from '@salesforce/apex/DashboardDemo.getOnlineFeePaymentsMonthStats';
import feeOfflinePaymentsMonth from '@salesforce/apex/DashboardDemo.getOfflineFeePaymentsMonthStats';
import getFees from '@salesforce/apex/DashboardDemo.getFees'; 

import getDashboardData from '@salesforce/apex/SLCMDashboard.getDashboardData';

export default class DashboardPaymentSlcmSap extends LightningElement {
    // @wire(getAccounts)
    // accounts

    monthFin = [
        'April', 'May', 'June', 'July', 'August', 
        'September', 'October', 'November', 
        'December', 'January', 'February', 'March'
    ];

    @track monthStats = [];

    @wire(getStringVal)
    someVal

    // @track accounts;
    // @track error;

    @track slcmOnlineData;
    @track slcmOnlineError;

    @track slcmOfflineData;
    @track slcmOfflineError;

    @track slcmMonthOnlineData;
    @track slcmMonthOnlineError;

    @track slcmMonthOfflineData;
    @track slcmMonthOfflineError;

    @track data;
    @track errorSAPBasic;
    isLoading = true;
    
    @track
    resultSAP = [];
    currentFySAP;
    todaySAP;
    yesterdaySAP;
    lastWeekSAP;
    currentWeekSAP;
    lastSevenDaysSAP;
    lastMonthSAP;
    currentMonthSAP;
    monthsSAP = [];

    todaySLCM;
    yesterdaySLCM;
    lastWeekSLCM;
    currentWeekSLCM;
    lastSevenDaysSLCM;
    lastMonthSLCM;
    currentMonthSLCM;

    onlineMonthsPayment;
    monthWiseData = [];
    
    @track fees = [];
    @track totalAmount = 0;

    slcmMonthCollection = [];
    sapMonthCollection = [];
    arrayOfObjects = [];

    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    
    //*************************** SLCM Data Collections **********************************

    @wire(feeOnlinePayments)
    wiredOnlineData({error, data}) {
        if(data){
            this.slcmOnlineData = JSON.stringify(data);
            console.log('Online BASIC DATA :'+this.slcmOnlineData);
            console.log('Online JSON Data :'+JSON.parse(data));
            let item = JSON.parse(data);
            this.todaySLCM = item.today;
            this.yesterdaySLCM = item.yesterdaySLCM;
            this.currentWeekSLCM = item.currentWeek;
            this.lastWeekSLCM = item.lastWeek;
            this.lastSevenDaysSLCM = item.last_seven_days;
            this.currentMonthSLCM = item.current_month;
            this.lastMonthSLCM = item.lastMonth;

        /*    let item = JSON.parse(data);
            console.log('SLCM Online Last Month :'+item.lastMonth);
            console.log('SLCM Online Current Month :'+item.current_month);
            console.log('SLCM Online last_seven_days :'+item.last_seven_days);
            console.log('SLCM Online currentWeek :'+item.currentWeek);
            console.log('SLCM Online lastWeek :'+item.lastWeek);
            console.log('SLCM Online yesterday :'+item.yesterday);
            console.log('SLCM Online today :'+item.today); */

        } else if(error) {
            this.slcmOnlineError = error;
        }
    }

    @wire(feeOfflinePayments)
    wiredOfflineData({error, data}) {
        if(data){
            this.slcmOfflineData = JSON.stringify(data);
            console.log('Offline BASIC DATA :'+this.slcmOfflineData);
            console.log('Offline JSON Data :'+JSON.parse(data));
        /*    let item = JSON.parse(data);
            console.log('SLCM Offline Last Month :'+item.lastMonth);
            console.log('SLCM Offline Current Month :'+item.current_month);
            console.log('SLCM Offline last_seven_days :'+item.last_seven_days);
            console.log('SLCM Offline currentWeek :'+item.currentWeek);
            console.log('SLCM Offline lastWeek :'+item.lastWeek);
            console.log('SLCM Offline yesterday :'+item.yesterday);
            console.log('SLCM Offline today :'+item.today); */

        } else if(error) {
            this.slcmOfflineError = error;
        }
    }
    //OLD response :  Months ->{2024-04=41933197.00, 2024-05=60244723.00, 2024-06=102097675.00, 2024-07=198765077.00, 2024-08=771709203.00, 2024-09=499579949.00}
    //NEW response :  Months ->{Apr=41933197.00, Aug=771709203.00, Jul=198765077.00, Jun=102097675.00, May=60244723.00, Sep=499579949.00}
    //NEW+ RESPONSE:  Months ->{Apr=41934197, Aug=772167203, Dec=0, Feb=0, Jan=0, Jul=198621077, Jun=102366675, Mar=0, May=60344723, Nov=0, ...}
    // @wire(feeOnlinePaymentsMonth)
    // wiredOnlineMonthPayments({error, data}) {
    //     if(data){
    //         this.slcmMonthOnlineData = JSON.stringify(data);
    //         console.log('feeOnlinePaymentsMonth BASIC DATA :'+this.slcmMonthOnlineData);
    //         console.log('feeOnlinePaymentsMonth JSON Data :'+JSON.parse(data));
    //         this.onlineMonthsPayment = JSON.parse(data);
            
    //     }else if(error){
    //         this.slcmMonthOnlineError = error;
    //     }
    // }

    @wire(feeOfflinePaymentsMonth)
    wiredStats({ error, data }) {
        if (data) {
            const parsedData = JSON.parse(data);
            this.monthStats = Object.keys(parsedData).map(month => ({
                month: month,
                amount: parsedData[month].toFixed(2) // Format to two decimal places
            }));
            for(let i of this.monthFin){
                // To adjust the month name ex : Apr,Sep
                let month1 = i.slice(0, 3);
            //    if(parsedData[month1]){
                    this.slcmMonthCollection.push(parsedData[month1]);
            //    }
                console.log('sliced month :'+month1+" : "+parsedData[month1]);
            }
            console.log('Offline Array >>'+this.slcmMonthCollection);
        } else if (error) {
            console.error('Error retrieving month stats', error);
        }
    }

    @wire(feeOfflinePaymentsMonth)
    wiredOfflineMonthPayments({error, data}) {
        if(data){
            this.slcmMonthOfflineData = JSON.stringify(data);
            console.log('feeOfflinePaymentsMonth DATA :'+this.slcmMonthOfflineData);
            console.log('feeOfflinePaymentsMonth JSON Data :'+JSON.parse(data));
        }else if(error){
            this.slcmMonthOfflineError = error;
        }
    }

    //******************************* SAP Data Collection **********************************

    @wire(getDashboardData)
    wiredData({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.data = data;
            this.errorSAPBasic = undefined;
            console.log('First item in array: ', this.data[0]);
        /*
            // Log the first object in the array
            console.log('First item in array: ', this.data[0]);
            this.obj1 = JSON.parse(this.data[0]);
            //  console.log('Test 123',obj1.FromDate);
                console.log('Test ',this.obj1.FromDate);
                console.log('Test ',this.obj1.ToDate);
                console.log('Test ',this.obj1.Amount);
                console.log('Test ',this.obj1.Period);  */
                
                for (let key in this.data) {
                    let item = JSON.parse(this.data[key]);
                 //   console.log('loop Item '+key, item.FromDate);
                    // updating amount to indian format
                 //   item['Amount'] = item.Amount.toLocaleString();
                    this.resultSAP.push(item);
                    // In the JSON response array from 7th position onwards Month data is available
                    if(key > 6 && key < 19){                    
                    //    if(parseInt(item.Amount) > 0){
                            // Adding month data to an array
                            this.monthsSAP.push(item); 
                            this.sapMonthCollection.push(item.Amount);
                    //    }
                    }
                    this.currentFySAP = item.Amount;
                }
                console.log('Array of Months ',this.monthsSAP[0].Period);
                console.log('Array of items ',this.resultSAP);
                console.log('Array Item 1 ',this.resultSAP[1].FromDate);
                this.todaySAP = '₹' + this.resultSAP[0].Amount;
                this.yesterdaySAP = '₹' + this.resultSAP[1].Amount;
                this.lastWeekSAP = '₹' + this.resultSAP[2].Amount;
                this.currentWeekSAP = '₹' + this.resultSAP[3].Amount;
                this.lastSevenDaysSAP = '₹' + this.resultSAP[4].Amount;
                this.lastMonthSAP = '₹' + this.resultSAP[5].Amount;
                this.currentMonthSAP = '₹' + this.resultSAP[6].Amount;

                console.log('Result ', this.todaySAP +" ,"+
                    this.yesterdaySAP +" ,"+
                    this.lastWeekSAP +" ,"+
                    this.currentWeekSAP +" ,"+
                    this.lastSevenDaysSAP +" ,"+
                    this.lastMonthSAP +" ,"+
                    this.currentMonthSAP );
                } else if (error) {
                    this.errorSAPBasic = error.body.message;
                    this.data = undefined;
                    console.log('Out put error ::: '+this.errorSAPBasic);
        }
    } 

    @wire(getFees)
    wiredFees({ error, data }) {
        if (data) {
            this.fees = data.map(fee => ({
                ...fee,
                isEditable: fee.feeType === 'Tuition Fee' // Only allow editing for Tuition Fee
            }));
            this.calculateTotal();
        } else if (error) {
            console.error(error);
        }
    }

    handleAmountChange(event) {
        const feeType = event.target.dataset.id;
        const newValue = parseFloat(event.target.value);
        const fee = this.fees.find(f => f.feeType === feeType);
        
        if (fee) {
            fee.amount = newValue;
            this.calculateTotal();
        }
    }

    calculateTotal() {
        this.totalAmount = this.fees.reduce((total, fee) => total + fee.amount, 0);
    }

    renderedCallback() {
         console.log('Component has been renderedCallback in the DOM');
         console.log('renderedCallback currentFySAP:',this.currentFySAP);

        this.arrayOfObjects = this.monthFin.map(month => ({
            month: month,
            sap: 0,
            slcm: 0
        }));

        this.arrayOfObjects.forEach((obj, index) => {
            /*if (index < slcmValues.length) { this.slcmMonthCollection
                obj.slcm = slcmValues[index]; // Update slcm value
            }
            if (index < sapValues.length) {
                obj.sap = sapValues[index]; // Update sap value
            }*/
             //   console.log('Month name'+obj.month);
          //      let filterObj = arrayOfObjects.find(item => item.month === obj.month);
            //    console.log(filterObj.month+" : "+filterObj.sap+" : "+filterObj.slcm);

            if (index < this.slcmMonthCollection.length) { 
                obj.slcm = this.slcmMonthCollection[index]; // Update slcm value
            }
            if (index < this.sapMonthCollection.length) {
                obj.sap = this.sapMonthCollection[index]; // Update sap value
            }

        });
        console.log('Clubbed array val :'+this.arrayOfObjects[0].month+' : '+this.arrayOfObjects[0].sap+' : '+this.arrayOfObjects[0].slcm);
        console.log('Offline Array renderedCallback'+this.slcmMonthCollection);

        let novemberData = this.arrayOfObjects.find(item => item.month === 'April');
        console.log(novemberData.slcm);
        console.log(novemberData.sap);
        console.log('Initial Array:', this.arrayOfObjects[4].month);

         if(this.data){
            console.log('renderedCallback -data', this.monthsSAP[0].Period);
            // let dataObj = JSON.parse(this.data);
            // let filterObj1 = dataObj.find(item => item.Period === 'May');
            // console.log(filterObj1);
            // console.log(filterObj1.Period+" : "+filterObj1.Amount);

            /*
            this.data.forEach((obj, index) => {
                let objItem = JSON.parse(this.data[index]);
              //  let filterObj = arrayOfObjects.find(item => item.month === objItem.Period);                
              //  console.log(filterObj.Period+" : "+filterObj.Amount);
            });
            console.log('month wise collection :'+this.sapMonthCollection); */

            // for (var key in this.data) {
            //     let obj = JSON.parse(this.data[key]);
            //     let filterObj = arrayOfObjects.find(item => item.month === obj.Period); 
            //     console.log(filterObj.Period+" : "+filterObj.Amount);
            // }

         }
        // this.monthWiseData = this.monthsSAP.map(item =>({

        // }))
    }

   

}