import { LightningElement, track, wire } from 'lwc';
import getDashboardData from '@salesforce/apex/SLCMDashboard.getDashboardData';
import getResponse from '@salesforce/apex/SLCMDashboard.getResponseString';

export default class DashboardPaymentSlcmSap extends LightningElement {
//   @track dashboardData = [];
//     @track error;

//     connectedCallback() {
//         this.fetchDashboardData();
//     }

//     fetchDashboardData() {
//         const url = 'https://sapbone.reva.edu.in/REVA_API_LIVE/API/SLCMDashBoardAPI';
        
//         fetch(url, {
//             method: 'POST',
//             headers: {
//                 'Content-Type': 'application/json'
//                 // Add other headers here if required, like authorization
//             },
//             body:'{}'
//         })
//         .then(response => {
//             if (!response.ok) {
//                 throw new Error('Network response was not ok');
//             }
//             return response.json();
//         })
//         .then(data => {
//             if (data.StatusCode === 1) {
//                 this.dashboardData = data.ResponseData;
//                 console.log('javascript Data ',this.dashboardData);
//             } else {
//                 this.error = data.StatusMessage;
//                 console.log('javascript Error ',this.error);
//             }
//         })
//         .catch(error => {
//             this.error = error;
//         });
//     }

//     get hasData() {
//         return this.dashboardData && this.dashboardData.length > 0;
//     } 

    /*    
        @track data = [];
    @track error;

    columns = [
        { label: 'Period', fieldName: 'Period', type: 'text' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency' },
        { label: 'From Date', fieldName: 'FromDate', type: 'date' },
        { label: 'To Date', fieldName: 'ToDate', type: 'date' }
    ];

    connectedCallback() {
        this.loadDashboardData();
    }

    loadDashboardData() {
        getDashboardData()
            .then(result => {
                if (result.StatusCode === 1) {
                    this.data = result.ResponseData;
                } else {
                    this.error = 'Error: ' + result.StatusMessage;
                }
            })
            .catch(error => {
                this.error = error.body.message;
            });
    }
            */

    // @track data = [];
    // @track error;

    // columns = [
    //     { label: 'Period', fieldName: 'Period', type: 'text' },
    //     { label: 'Amount', fieldName: 'Amount', type: 'currency' },
    //     { label: 'From Date', fieldName: 'FromDate', type: 'text' },
    //     { label: 'To Date', fieldName: 'ToDate', type: 'text' }
    // ];

    // connectedCallback() {
    //     this.loadDashboardData();
    // }

    // loadDashboardData() {
    //     getDashboardData()
    //         .then(result => {
    //           /*  if (result.StatusCode === 1) {
    //                 this.data = result.ResponseData;
    //                 this.error = undefined;
    //             } else {
    //                 this.error = `Error: ${result.StatusMessage || 'Unknown error'}`;
    //                 this.data = [];
    //             } */
    //            console.log('Result ->', result);
               
    //         })
    //         .catch(error => {
    //             this.error = `Error: ${error.body ? error.body.message : error.message}`;
    //             this.data = [];
    //         });
    // }

    @track data;
    @track error;
    isLoading = true;
    @track 
    parsedData;
    @track
    val;

    @track
    removedVal;

    @track
    arrayData;

    @track
    obj1;

    @track
    result = [];

    today;
    yesterday;
    lastWeek;
    currentWeek;
    lastSevenDays;
    lastMonth;
    currentMonth;
    months = [];

    @wire(getDashboardData)
    wiredData({ error, data }) {
        this.isLoading = false;
        if (data) {
            

            this.data = data;
            this.error = undefined;

            

           this.val =  JSON.stringify(this.data);
          // this.removedVal = this.val.map(item => JSON.parse(item.replace(/\\/g, '')));
           console.log('Removed / ',this.Val);

            // Log the first object in the array
            console.log('First item in array: ', this.data[0]);
              this.obj1 = JSON.parse(this.data[0]);
            //  console.log('Test 123',obj1.FromDate);
                console.log('Test ',this.obj1.FromDate);
                console.log('Test ',this.obj1.ToDate);
                console.log('Test ',this.obj1.Amount);
                console.log('Test ',this.obj1.Period);
                
                for (var key in this.data) {
                    let item = JSON.parse(this.data[key]);
                    console.log('loop Item '+key, item.FromDate);
                    // updating amount to indian format
                    item['Amount'] = item.Amount.toLocaleString();
                    this.result.push(item);
                    // In the JSON response array from 7th position onwards Month data is available
                    if(key > 6){
                        // updating amount to indian format
                    //    item['Amount'] = item.Amount.toLocaleString();
                        this.months.push(item); 
                    }
                }
                console.log('Array of Months ',this.months[0].Period);
                console.log('Array of items ',this.result);
                console.log('Array Item 1 ',this.result[1].FromDate);
                this.today = '₹' + this.result[0].Amount;
                this.yesterday = '₹' + this.result[1].Amount;
                this.lastWeek = '₹' + this.result[2].Amount;
                this.currentWeek = '₹' + this.result[3].Amount;
                this.lastSevenDays = '₹' + this.result[4].Amount;
                this.lastMonth = '₹' + this.result[5].Amount;
                this.currentMonth = '₹' + this.result[6].Amount;

                console.log('Result ', this.today +" ,"+
                    this.yesterday +" ,"+
                    this.lastWeek +" ,"+
                    this.currentWeek +" ,"+
                    this.lastSevenDays +" ,"+
                    this.lastMonth +" ,"+
                    this.currentMonth );
                              

            this.val = JSON.stringify(this.data[0]).replace(/\\/g, '');
            console.log('After replace / : ', this.val);

            // const obj2 = JSON.parse(this.val);
            // console.log('Parse Array ',obj2);

            const inputString = this.val;

            console.log('After replace / : ', inputString);

            if (inputString.length > 1 && inputString.charAt(0) === '"' && inputString.charAt(inputString.length - 1) === '"') {
                // Remove the first and last characters and replace them with single quotes
             //   return "'" + inputString.slice(1, -1) + "'";

                const doubleQuoteRemoved = "'" + inputString.slice(1, -1) + "'";
                console.log('After replace /| : ', doubleQuoteRemoved);
             //   const obj1 = JSON.parse(doubleQuoteRemoved);
                // console.log('Test ',obj1.FromDate);
                // console.log('Test ',obj1.ToDate);
                // console.log('Test ',obj1.Amount);
                // console.log('Test ',obj1.Period);
            }

            // let res = eval('(' + this.val + ')');
            // console.log(res.Amount);

          //  const obj = JSON.parse(this.val);
            // console.log('Amount :: ',this.result);

            // Check specific properties to ensure they're correctly populated
            console.log('First Period: ', JSON.stringify(this.data[0]));
            console.log('First Amount: ', this.data[0].Amount);

            console.log('First item in array as string: ', JSON.stringify(this.data).replace(/\\/g, ''));
        //    console.log('Keys of first item: ', Object.keys(this.data[0]));

            this.val = JSON.stringify(this.data).replace(/\\/g, '');

            // this.arrayData = JSON.parse(this.val);

            console.log('Aftre parsing : ', this.val[0]);

            const text = '{"ToDate":"11-09-2024","FromDate":"11-09-2024","Amount":16160623.0,"Period":"today"}';   
                         '{"ToDate":"11-09-2024","FromDate":"11-09-2024","Amount":16160623.0,"Period":"today"}'         
            const obj = JSON.parse(text);
            console.log('Test ',obj.ToDate);           

        } else if (error) {
            this.error = error.body.message;
            this.data = undefined;
            console.log('OUt put error ::: '+this.error);
        }
    } 

    
 //   @track data = [];
    @track dataV ;
    @track error1;

    @wire(getResponse)
    wiredData({ error, dataVal }) {
        if (dataVal) {
         //   this.data = JSON.parse(data);
            this.dataV = dataVal;
            this.error1 = undefined;
            console.log('SLCM Dashboard Data :',this.dataV);
        } else if (error) {
            this.error1 = error;
            this.dataV = undefined;
        }
    }

    get hasData() {
        return this.data && this.data.length > 0;
    } 
}