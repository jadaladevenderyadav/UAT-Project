/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 05-29-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
({
    doInit: function (component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        helper.doInitHelper(component, event, helper);
    },
    selectAllCheckbox: function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        console.log('selectedHeaderCheck-->> ', selectedHeaderCheck);
        var listStuPendingFee = component.get("v.lstPendingFee");
        console.log('listStuPendingFee-->> ', listStuPendingFee);
        var updatedStuRecords = [];
        for (var i = 0; i < listStuPendingFee.length; i++) {
            console.log('Inside');
            if (selectedHeaderCheck == true) {
                listStuPendingFee[i].isChecked = true;
                component.set("v.selectedCount", listStuPendingFee.length);
                //AddedbyRajashekarAug062024
                var listStuPendingFee = component.get("v.lstPendingFee");
                component.set("v.CheckedlstPendingFee",listStuPendingFee);
                //endshere
                
            }
            else {
                listStuPendingFee[i].isChecked = false;
                component.set("v.selectedCount", 0);
                //AddedbyRajashekarAug062024
                var emptyLst = [];
                component.set("v.CheckedlstPendingFee",emptyLst);
                //endshere
            }
            component.set("v.openMultiModel", false);
            updatedStuRecords.push(listStuPendingFee[i]);
            
        }
        component.set("v.lstPendingFee", updatedStuRecords);
        console.log('lstPendingFee', JSON.stringify(component.get("v.lstPendingFee")));
        console.log('updatedStuRecords', JSON.stringify(updatedStuRecords));
        console.log('isChecked',updatedStuRecords.isChecked);
    },
    checkboxSelect: function (component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        console.log('selectedRec-->> ', JSON.stringify(selectedRec));
        var index = event.getSource().get('v.name');
        // console.log('index-->> ', index);
        console.log('selected record Id==>', index);
        var getSelectedNumber = component.get("v.selectedCount");
        console.log('Selected Number', getSelectedNumber);
        
        var listStuPendingFee = component.get("v.lstPendingFee");
        console.log('listStuPendingFee-->> ', listStuPendingFee);
        var updatedStuRecords = [];
        
        //ModifiedbyRajashekarAug062024
        var checkedStuRecords = component.get("v.CheckedlstPendingFee");
        
        for (var i = 0; i < listStuPendingFee.length; i++) {
            console.log('Inside');
            /* 
             //commented if case
            listStuPendingFee[i].isChecked = false;
            if (i == index) {
                listStuPendingFee[i].isChecked = selectedRec;
            }
            */
            //newlyaddedAug062024 if case == instead of row index I'm pulling the record Id of that row.
            
            if(listStuPendingFee[i].Id == index){
                listStuPendingFee[i].isChecked = selectedRec;
                if(selectedRec ==  true){
                    checkedStuRecords.push(listStuPendingFee[i])
                }else if(selectedRec ==  false){
                    let indexinSecondLst = checkedStuRecords.indexOf(listStuPendingFee[i]);
                    checkedStuRecords.splice(indexinSecondLst, 1);
                }
            }
            updatedStuRecords.push(listStuPendingFee[i]);
        }
        component.set("v.CheckedlstPendingFee",checkedStuRecords);
        //Below code is for If all records are checked then header CheckBox will autochecked or else unchecked
        if(listStuPendingFee.length == checkedStuRecords.length){
            component.find("selectAllId").set("v.value", true);
        }else{
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.openMultiModel", false); 
        //Modification ends here
        component.set("v.lstPendingFee", updatedStuRecords);
        
        // if (selectedRec == true) {
        //     getSelectedNumber++;
        // } else {
        //     getSelectedNumber--;
        //     component.find("selectAllId").set("v.value", false);
        // }
        // component.set("v.selectedCount", getSelectedNumber);
        // console.log('Selected Number', getSelectedNumber);
        // if (getSelectedNumber == component.get("v.totalRecordsCount")) {
        //     component.find("selectAllId").set("v.value", true);
        // }
        
        // console.log('Selected Records Count', getSelectedNumber);
        // console.log('Total Records Count', component.get("v.totalRecordsCount"));
        console.log('Updted lstPendingFee ', JSON.stringify(component.get("v.lstPendingFee")));
    },
    MultipleFeeSelect: function (component, event, helper) {
        var checkCmp = component.find("tglListviewbtn").get("v.checked");
        component.set("v.ChangeFeePayment", checkCmp);
    },
    closeModel: function (component, event, helper) {
        component.set("v.openModel", false);
        component.set("v.paytmConfirm", false);
        component.set("v.DisablePayNow", true);
    },
    // onPayNow : function(component, event, helper)
    // {
    //     component.set("v.Spinner", true); 
    //     var index = event.getSource().get("v.name");
    //     var selectLstFee =[];
    //     var lstFeePending = component.get("v.lstPendingFee");
    //     selectLstFee.push(lstFeePending);
    
    //     var selid = lstFeePending[index].ObjStuFeeDeatils.Id;
    //     var seldate =lstFeePending[index].ObjStuFeeDeatils.Due_Date__c;
    //     var selContactid =lstFeePending[index].ObjStuFeeDeatils.Contact__c;
    //     component.set("v.SelectedRecId",selid);
    //     component.set("v.SelectedDueDate",seldate);
    //     component.set("v.SelectedConId",selContactid);
    //     helper.VlaidationHlpr(component, event, helper);
    // },
    // onMultiplePayNow : function(component, event, helper)
    // {   
    //     component.set("v.Spinner", true); 
    //     var updatedStuRecords = [];
    //     var selectedRecords = [];
    //     var lstFeePending = component.get("v.lstPendingFee");
    //     console.log('lstFeePending', lstFeePending);
    //     for (var i = 0; i < lstFeePending.length; i++)
    //     {
    //         //if(lstFeePending[i].isChecked == true)
    //        // {
    //             updatedStuRecords.push(lstFeePending[i]);
    //             selectedRecords.push(lstFeePending[i]);
    //        // }
    //     }
    //     if(selectedRecords == 0)
    //     {
    //         helper.showToast(component,'dismissible','Failed','No Pending fee to pay','error');
    //         component.set("v.Spinner",false);
    //         console.log('Selected Records', selectedRecords.length);
    //     }
    //     else
    //     {  
    //         console.log('Selected Records', selectedRecords.length);
    //         component.set("v.MultiSelectList",updatedStuRecords);
    //         helper.VlaidationMultiHlpr(component, event, helper);
    //     }
    // }, 
    closeMultiModel: function (component, event, helper) {
        component.set("v.openMultiModel", false);
        component.set("v.paytmConfirm", false);
        component.set("v.DisablePayNow", true);
    },
    ChangeAmount: function (component, event, helper) {
        var tamount = component.get("v.EnteredAmount");
        var TotalPayamount;
        var feepayment = component.get("v.lstStuFeePayment");
        for (var i = 0; i < feepayment.length; i++) {
            TotalPayamount = feepayment[i].Amount_Pending__c;
            if (tamount > feepayment[i].Amount_Pending__c) {
                helper.showToast(component, 'dismissible', 'Failed', 'Please Enter Correct Amount', 'error');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
        }
        if (tamount <= TotalPayamount) {
            component.set("v.DisablePayNow", true);
        }
    },
    AfterPaynow: function (component, event, helper) {
        component.set("v.ModelSpinner", true);
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var paymap = component.get("v.PaymentMap");
        for (var key in paymap) {
            if (paymap[key].key == 'RazorPay')
                mapRazorpay = paymap[key].key;
            if (paymap[key].key == 'PayTM')
                mapPaytm = paymap[key].key;
            if (paymap[key].key == 'EazyPay')
                mapEasypay = paymap[key].key;
            if (paymap[key].key == 'BillDesk')
                mapBilldesk = paymap[key].key;
        }
        var rate_value;
        
        if (mapRazorpay == 'RazorPay') {
            if (document.getElementById('radio-66').checked) {
                rate_value = document.getElementById('radio-66').value;
            }
        }
        if (mapPaytm == 'PayTM') {
            // console.log('ggggggg'+mapPaytm); 
            if (document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            } else {
                // console.log('not checked');
            }
        }
        if (mapEasypay == 'EazyPay') {
            if (document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if (mapBilldesk == 'BillDesk') {
            if (document.getElementById('radio-65').checked) {
                rate_value = document.getElementById('radio-65').value;
            }
        }
        var EnteredAmount = component.get("v.EnteredAmount");
        var TotalPayamount;
        if (rate_value == null || rate_value == '' || rate_value == 'undefined') {
            helper.showToast(component, 'dismissible', 'Failed', 'Please Select Payment Gateway', 'error');
            component.set("v.ModelSpinner", false);
        }
        else {
            var feepayment = component.get("v.lstStuFeePayment");
            for (var i = 0; i < feepayment.length; i++) {
                // debugger;
                TotalPayamount = feepayment[i].Amount_Pending__c;
                if (EnteredAmount > feepayment[i].Amount_Pending__c) {
                    // debugger;
                    helper.showToast(component, 'dismissible', 'Failed', 'Please Enter Correct Amount', 'error');
                    component.set("v.ModelSpinner", false);
                }
            }
            if (EnteredAmount <= TotalPayamount)
                // console.log('yyyyyyyyy'+EnteredAmount)
            {
                if (rate_value == 'RazorPay') {
                    if (EnteredAmount != null || EnteredAmount != '') {
                        helper.rezorPayGeneratePaymentLink(component, event, helper, feepayment, EnteredAmount, 'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", false);
                    }
                    else {
                        helper.rezorPayGeneratePaymentLink(component, event, helper, feepayment, TotalPayamount, 'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", false);
                    }
                }
                if (rate_value == 'BillDesk') {
                    if (EnteredAmount != null || EnteredAmount != '') {
                        // debugger;
                        
                        helper.billDeskGeneratePaymentLink(component, event, helper, feepayment, EnteredAmount, 'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", false);
                    }
                    else {
                        // debugger;                   
                        helper.billDeskGeneratePaymentLink(component, event, helper, feepayment, TotalPayamount, 'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", false);
                    }
                }
                if (rate_value == 'EazyPay') {
                    if (EnteredAmount != null || EnteredAmount != '') {
                        helper.EasyPayGeneratePaymentLink(component, event, helper, feepayment, EnteredAmount, 'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", false);
                    }
                    else {
                        helper.EasyPayGeneratePaymentLink(component, event, helper, feepayment, TotalPayamount, 'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", false);
                    }
                }
                if (rate_value == 'PayTM') {
                    // console.log('biiiiiiiiiii'+EnteredAmount);
                    if (EnteredAmount != null || EnteredAmount != '') {
                        helper.paytmGeneratePaymentLink(component, event, helper, feepayment, EnteredAmount, 'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", false);
                    }
                    else {
                        helper.paytmGeneratePaymentLink(component, event, helper, feepayment, TotalPayamount, 'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", false);
                    }
                }
            }
        }
    },
    MultipleAfterPayNow: function (component, event, helper) {
        component.set("v.ModelSpinner", true);
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var Multipaymap = component.get("v.MultiPaymentMap");
        for (var key in Multipaymap) {
            if (Multipaymap[key].key == 'RazorPay')
                mapRazorpay = Multipaymap[key].key;
            if (Multipaymap[key].key == 'PayTM')
                mapPaytm = Multipaymap[key].key;
            if (Multipaymap[key].key == 'EazyPay')
                mapEasypay = Multipaymap[key].key;
            if (Multipaymap[key].key == 'BillDesk')
                mapBilldesk = Multipaymap[key].key;
        }
        var rate_value;
        var totalpayAmount = component.get("v.totalAmount");
        
        if (mapRazorpay == 'RazorPay') {
            if (document.getElementById('radio-66').checked) {
                rate_value = document.getElementById('radio-66').value;
            }
        }
        if (mapPaytm == 'PayTM') {
            console.debug('kkkkkkkkkkk' + mapPaytm);
            if (document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            }
        }
        if (mapEasypay == 'EazyPay') {
            if (document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if (mapBilldesk == 'BillDesk') {
            if (document.getElementById('radio-65').checked) {
                rate_value = document.getElementById('radio-65').value;
            }
        }
        if (rate_value == null || rate_value == '' || rate_value == 'undefined') {
            helper.showToast(component, 'dismissible', 'Failed', 'Please Select Payment Gateway', 'error');
            component.set("v.ModelSpinner", false);
        }
        else {
            var multirecds = component.get("v.lstMultipleRecords");
            if (rate_value == 'RazorPay') {
                
                helper.razorpayGeneratePaymentLink(component, event, helper, multirecds, totalpayAmount, 'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
            if (rate_value == 'BillDesk') {
                
                helper.billDeskGeneratePaymentLink(component, event, helper, multirecds, totalpayAmount, 'Multi');
                
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
            if (rate_value == 'EazyPay') {
                helper.EasyPayGeneratePaymentLink(component, event, helper, multirecds, totalpayAmount, 'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
            if (rate_value == 'PayTM') {
                // console.log('ggggggg'+rate_value);
                //  debugger;
                helper.paytmGeneratePaymentLink(component, event, helper, multirecds, totalpayAmount, 'Multi');
                //  console.log('ffffffffffff'+paytmGeneratePaymentLink);
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
        }
    },
    paytmRedirect: function (component, event, helper) {
        component.find("paymentForm").getElement().submit();
        //  debugger;
    },
    view: function (component, event, helper) {
        var index = event.currentTarget.getAttribute("data-value");
        //   console.log('index', index);
        //var index = event.getSource().get("v.name");    
        var lstStuFeePending = component.get("v.lstStuPaymentPaidFee");
        //   console.log('lstStuFeePending', lstStuFeePending);      
        var selid = lstStuFeePending[index].Id;
        // var url =window.open('/apex/FEE_FeeReceipt?id=' + selid);
        
        // >>>>>> New Code Start <<<<<<
        //   console.log('>>> ' + window.location.href);
        //https://strtsdev23-reva-university.cs31.force.com/StudentPortal/s/student-fee
        var currLocation = window.location.href;
        var siteIndictor = currLocation.indexOf('/s/');
        if (siteIndictor != -1) {
            currLocation = currLocation.substring(0, siteIndictor);
        }
        //   console.log('>>>> Curr Location: ' + currLocation);
        //   console.log('Current Application Fee type =>',lstStuFeePending[index].Fee_Type__c);
        //https://strtsdev23-reva-university.cs31.force.com/StudentPortal
        if (lstStuFeePending[index].Fee_Type__c != 'Application Fee' && lstStuFeePending[index].Payment_Mode_Type__c != 'Paid at KEA') {
            // console.log('Application Fee type 2 =>',lstStuFeePending[index].Fee_Type__c);
            var url = window.open(currLocation + '/apex/ApplicantProvisionalAdmissionFeeReceipt?id=' + selid);
        }
        if (lstStuFeePending[index].Fee_Type__c == 'Application Fee') {
            // console.log('Application Fee type 1 =>',lstStuFeePending[index].Fee_Type__c);
            var url = window.open(currLocation + '/apex/Multiple_Payment_Receipt?id=' + selid);
        }
        // >>>>>> New Code End <<<<<<
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    
    
    
    
    onMultipleUpdatedPayNow: function (component, event, helper) {
        // console.log('inside onMultipleUpdatedPayNow');
        component.set("v.Spinner", true);
        var updatedStuRecords = [];
        var selectedRecords = [];
        var lstFeePending = component.get("v.lstPendingFee");//lstStuPaymentFee  //lstPendingFee
        var SelectedConId;
        console.log('lstFeePending Records', JSON.stringify(lstFeePending));
        for (var i = 0; i < lstFeePending.length; i++) {
            console.log('inside for loop');
            if (lstFeePending[i].isChecked == true) {
                updatedStuRecords.push(lstFeePending[i]);
                selectedRecords.push(lstFeePending[i]);
            }
            SelectedConId = lstFeePending[i].contact__c;
            
        }
        console.log('after for loop');
        console.log('inside 425 ' + SelectedConId);
        if (selectedRecords == 0) {
            helper.showToast(component, 'dismissible', 'Failed', 'No Pending fee to pay', 'error');
            component.set("v.Spinner", false);
            // console.log('Selected Records', selectedRecords.length);
        }
        else {
            // console.log('Selected Records', selectedRecords.length);
            component.set("v.MultiSelectList", updatedStuRecords);
            component.set("v.SelectedConId", SelectedConId);
            
            helper.VlaidationUpdatedMultiHlpr(component, event, helper);
        }
    },
    
    MultipleUpdatedAfterPayNow: function (component, event, helper) {
        console.log('inside MultipleUpdatedAfterPayNow');
        component.set("v.ModelSpinner", true);
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var Multipaymap = component.get("v.MultiPaymentMap");
        var selConId;
        // var SelectedConId = component.get("v.SelectedConId");
        var lstFeePending = component.get("v.MultiSelectList");//lstStuPaymentFee //lstPendingFee //MultiSelectList
        var SelectedConId;
        var updatedStuRecords = [];
        var selectedRecords = [];
        console.log('After Pay Now Pending', lstFeePending);
        for (var i = 0; i < lstFeePending.length; i++) {
            console.log('inside 460 for loop ');
            console.log(lstFeePending[i]);
            SelectedConId = lstFeePending[i].Contact__c;
            selConId = lstFeePending[i].Contact__c;
            console.log('lstFeePending[i].contact__c ' + lstFeePending[i].Contact__c);
            console.log('selConId ' + selConId);
            
            
            // if (lstFeePending[i].isChecked == true) {
            //     updatedStuRecords.push(lstFeePending[i]);
            //     selectedRecords.push(lstFeePending[i]);
            // }
            // SelectedConId = lstFeePending[i].contact__r.Id;
        }
        console.log('outsize for loop controller line 469 ' + selConId);
        component.set("v.SelectedConId", SelectedConId);
        console.log('SelectedConId ' + SelectedConId);
        for (var key in Multipaymap) {
            if (Multipaymap[key].key == 'RazorPay')
                mapRazorpay = Multipaymap[key].key;
            if (Multipaymap[key].key == 'PayTM')
                mapPaytm = Multipaymap[key].key;
            if (Multipaymap[key].key == 'EazyPay')
                mapEasypay = Multipaymap[key].key;
            if (Multipaymap[key].key == 'BillDesk')
                mapBilldesk = Multipaymap[key].key;
        }
        var rate_value;
        var totalpayAmount = component.get("v.totalAmount");
        
        if (mapRazorpay == 'RazorPay') {
            if (document.getElementById('radio-66').checked) {
                rate_value = document.getElementById('radio-66').value;
            }
        }
        if (mapPaytm == 'PayTM') {
            console.debug('kkkkkkkkkkk' + mapPaytm);
            if (document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            }
        }
        if (mapEasypay == 'EazyPay') {
            if (document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if (mapBilldesk == 'BillDesk') {
            if (document.getElementById('radio-65').checked) {
                rate_value = document.getElementById('radio-65').value;
            }
        }
        if (rate_value == null || rate_value == '' || rate_value == 'undefined') {
            helper.showToast(component, 'dismissible', 'Failed', 'Please Select Payment Gateway', 'error');
            component.set("v.ModelSpinner", false);
        }
        else {
            var multirecds = component.get("v.stuFeePayPendingList");
            var selConId = component.get("v.SelectedConId");
            console.log('line 497 ' + selConId);
            if (rate_value == 'RazorPay') {
                
                helper.razorpayUpdatedGeneratePaymentLink(component, event, helper, selConId, totalpayAmount, 'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
            if (rate_value == 'BillDesk') {
                
                helper.billDeskUpdatedGeneratePaymentLink(component, event, helper, selConId, totalpayAmount, 'Multi');
                
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
            if (rate_value == 'EazyPay') {
                helper.EasyPayUpdatedGeneratePaymentLink(component, event, helper, selConId, totalpayAmount, 'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
            if (rate_value == 'PayTM') {
                console.log('ggggggg' + rate_value);
                //  debugger;
                console.log('before calling helper.PaytmUpdatedGeneratePaymentLink');
                // console.log('multirecds ');
                // console.log(multirecds);
                console.log('totalpayAmount ' + totalpayAmount);
                console.log('selConId ' + selConId);
                helper.PaytmUpdatedGeneratePaymentLink(component, event, helper, selConId, totalpayAmount, 'Multi');
                //  console.log('ffffffffffff'+PaytmUpdatedGeneratePaymentLink);
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);
            }
        }
    },
})