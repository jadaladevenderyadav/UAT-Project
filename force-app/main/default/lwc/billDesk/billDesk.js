import { LightningElement } from 'lwc';
 
export default class BillDesk extends LightningElement {
    handleOnClick() {
        debugger
        try {
            // Open the URL in a new tab
            window.open('https://pgi.billdesk.com/pgidsk/PGIMerchantPayment?msg=REVAECOMSF%7C8953872216%7CNA%7C10000.00%7CNA%7CNA%7CNA%7CINR%7CNA%7CR%7Crevaecomsf%7CNA%7CNA%7CF%7CTest Sumit|24140600353@reva.edu.in|938831096789|8953872216|24140600353|NA|NA|https://reva-university.my.salesforce-sites.com/BillDeskResponse%7CBE7BF17EC1E5E805B732E3737E0716FB60ADD0250E50595C900E14387F8CAA9C', '_blank');
            window.alert('Button clicked');
        } catch (error) {
            console.log('ERROR: ', error.message);
            window.alert(error.message);
        }
    }

    handleOnClick2(){
        debugger
        try {
            // Open the URL in a new tab
            window.open('https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=BDUATV1E07%257C8953872216%257CNA%257C10000.00%257CNA%257CNA%257CNA%257CINR%257CNA%257CR%257Crevaecomsf%257CNA%257CNA%257CF%257CTest%20Sumit%7C24140600353%40reva.edu.in%7C938831096789%7C8953872216%7C24140600353%7CNA%7CNA%7Chttps%3A%2F%2Freva-university--couat1908.sandbox.my.salesforce-sites.com%2FBillDeskResponse%257CBE7BF17EC1E5E805B732E3737E0716FB60ADD0250E50595C900E14387F8CAA9C', '_blank');
            window.alert('Button clicked');
        } catch (error) {
            console.log('ERROR: ', error.message);
            window.alert(error.message);
        }
    }
}