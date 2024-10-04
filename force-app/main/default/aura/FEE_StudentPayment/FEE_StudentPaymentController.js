({
    doInit : function(component, event, helper) 
    {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today); 
        component.set('v.isamountReadonly', true); 
        helper.doInitHelper(component, event, helper);	
    },
    selectAllCheckbox: function(component, event, helper)
    {       
        var selectedHeaderCheck = event.getSource().get("v.value");
        var listStuPendingFee = component.get("v.lstPendingFee");
        var updatedStuRecords = [];
        for (var i = 0; i < listStuPendingFee.length; i++)
        {
            if(selectedHeaderCheck == true)
            {
                listStuPendingFee[i].isChecked = true;
                component.set("v.selectedCount", listStuPendingFee.length);
            }
            else
            {
                listStuPendingFee[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedStuRecords.push(listStuPendingFee[i]);
        }
        component.set("v.lstPendingFee", updatedStuRecords);
        console.log('lstPendingFee', JSON.stringify(component.get("v.lstPendingFee")));
    },
    checkboxSelect: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        var index = event.getSource().get('v.name');
        var getSelectedNumber = component.get("v.selectedCount");
        
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        
        // If all records are selected, check the selectAll checkbox
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);            
        }
        
        // Fetch the current selected fee details
        var lstFeePending = component.get("v.lstPendingFee");
        var selectedFee = lstFeePending[index];
        
        // Call server-side method to check for Penalty Fee related to this contact
        var action = component.get("c.getPenaltyFeeForContact");
        action.setParams({
            "contactId": selectedFee.ObjStuFeeDeatils.Contact__c
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var penaltyFee = response.getReturnValue();
                
                // Only proceed with the auto-select logic if a Penalty Fee is found
                if (penaltyFee) {
                    // Penalty Fee found - check if any selected payments match the penalty fee year
                    var penaltyFeeYear = penaltyFee.Fee_Year__c;
                    var autoSelectFlag = false;
                    
                    for (var i = 0; i < lstFeePending.length; i++) {
                        if (lstFeePending[i].isChecked) {
                            if (lstFeePending[i].ObjStuFeeDeatils.Fee_Year__c == penaltyFeeYear) {
                                autoSelectFlag = true;
                                break;
                            }
                        }
                    }
                    
                    // Auto-select all payments with the same fee year as the Penalty Fee
                    if (autoSelectFlag) {
                        for (var i = 0; i < lstFeePending.length; i++) {
                            if (lstFeePending[i].ObjStuFeeDeatils.Fee_Year__c == penaltyFeeYear) {
                                lstFeePending[i].isChecked = true;
                            }
                        }
                        component.set("v.lstPendingFee", lstFeePending);
                    }
                }
                
                // Proceed with the helper function to handle multi-select logic
                helper.multiSelectOnChange(component, event, helper, selectedRec, index);
            } else {
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    MultipleFeeSelect:function(component, event, helper)
    {
        var checkCmp = component.find("tglListviewbtn").get("v.checked");
        component.set("v.ChangeFeePayment",checkCmp);
    },
    closeModel: function(component, event, helper) 
    {      
        component.set("v.openModel", false);
        component.set("v.paytmConfirm",false);
        component.set("v.DisablePayNow",true);
    },
    onPayNow : function(component, event, helper)
    {
        component.set("v.Spinner", true); 
        var index = event.getSource().get("v.name");
        var selectLstFee =[];
        var lstFeePending = component.get("v.lstPendingFee");
        selectLstFee.push(lstFeePending);
        
        var selid = lstFeePending[index].ObjStuFeeDeatils.Id;
        var seldate =lstFeePending[index].ObjStuFeeDeatils.Due_Date__c;
        var selContactid =lstFeePending[index].ObjStuFeeDeatils.Contact__c;
        component.set("v.SelectedRecId",selid);
        component.set("v.SelectedDueDate",seldate);
        component.set("v.SelectedConId",selContactid);
        // helper.VlaidationHlpr(component, event, helper);
        
        //AddedbyRajashekarforValidationofSplitAmount
        if(lstFeePending[index].ObjStuFeeDeatils.Student_Fee_Payments__r != null && lstFeePending[index].ObjStuFeeDeatils.Contact__r.Split_Booking_Fee__c == true && lstFeePending[index].ObjStuFeeDeatils.Student_Fee_Payments__r[0].Student_Payment__r.Split_Validation__c == true){
            //&& lstFeePending[index].ObjStuFeeDeatils.Student_Fee_Payments__r[0].Student_Payment__r.Payment_Status__c != 'Failed' && lstFeePending[index].ObjStuFeeDeatils.Student_Fee_Payments__r[0].Student_Payment__r.Payment_Status__c != 'Pending')
            helper.showToast(component,'dismissible','Failed','Please Contact your Hostel Office and make sure to split the Amount','error');
            component.set("v.Spinner", false);
        }else{
            
            helper.makePaymentHlpr(component, event, helper);
        }
        //helper.makePaymentHlpr(component, event, helper);
    },
    onMultiplePayNow : function(component, event, helper)
    {   
        component.set("v.Spinner", true); 
        var updatedStuRecords = [];
        var selectedRecords = [];
        var lstFeePending = component.get("v.lstPendingFee");
        console.log('afterclickingonMakePayment1==>',component.get("v.lstPendingFee"));
        for (var i = 0; i < lstFeePending.length; i++)
        {
            if(lstFeePending[i].isChecked == true)
            {
                updatedStuRecords.push(lstFeePending[i]);
                selectedRecords.push(lstFeePending[i]);
            }
        }
        if(selectedRecords == 0)
        {
            helper.showToast(component,'dismissible','Failed','Please Select Atleast One Record..!','error');
            component.set("v.Spinner",false);
        }
        else
        {  
            component.set("v.MultiSelectList",updatedStuRecords);
            console.log('afterclickingonMakePayment2==>',component.get("v.MultiSelectList"));
            helper.VlaidationMultiHlpr(component, event, helper);
            
        }
    }, 
    closeMultiModel: function(component, event, helper) 
    {      
        component.set("v.openMultiModel", false);
        component.set("v.paytmConfirm",false);
        component.set("v.DisablePayNow",true);
    },
    handleAmountChange: function(component, event, helper) {
        // Get the changed value from the input field
        var changedValue = parseFloat(event.getSource().get("v.value"));
        if (isNaN(changedValue)) {
            changedValue = 0;  // Fallback if the input is invalid
        }
        var disablePayNow = true;
        changedValue = changedValue % 1 === 0 ? parseInt(changedValue) : changedValue;
        console.log("Changed Value:", changedValue);
        //component.get("v.pendingAmounts", pendingAmounts);
        var feepayment = component.get("v.lstMultipleRecords");  // Get the list of pending fees
        var index = event.getSource().get("v.name");  // Use 'name' attribute to identify the correct record
        
        if (index != null && feepayment[index])  {
            feepayment[index].Amount_Pending__c = changedValue; // Update with the new value
            console.log('Updated Fee Payment:', feepayment[index]);
            if (changedValue === 0) {
                helper.showToast(component, 'dismissible', 'Failed', 'Please Enter Amount Greater than 0.', 'error');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", false);  // Disable Pay Now if the amount is invalid
                return;  // Exit the function if the entered amount is 0
            }else{
                            component.set("v.DisablePayNow",true);
            }
        }
        var pendingTuitionFee = component.get("v.pendingAmounts");  
        console.log('fee==='+pendingTuitionFee);
        var pendingAmount = feepayment[index].pendingAmounts;
        if (changedValue > pendingTuitionFee) {
            helper.showToast(component, 'dismissible', 'Failed', 'Please Enter Correct Amount', 'error');
            component.set("v.ModelSpinner", false);
            component.set("v.DisablePayNow", false);  // Disable Pay Now if amount exceeds pending
            return;
        }else{
                            component.set("v.DisablePayNow",true);
            }
        // Recalculate the total amount
        var totalAmount = 0; 
        for (var i = 0; i < feepayment.length; i++) {
            var pendingAmount = parseFloat(feepayment[i].Amount_Pending__c || 0);  // Ensure it's a number
            totalAmount += pendingAmount;
        }
        
        // Set the recalculated totalAmount in the component
        component.set("v.totalAmount", totalAmount);
        console.log("Updated Total Amount: " + totalAmount);
    },    
    ChangeAmount: function(component, event, helper) {
        var tamount = component.get("v.EnteredAmount");
        var TotalPayamount;
        var feepayment = component.get("v.lstStuFeePayment");
        console.log("feepayment===="+feepayment);
        var disablePayNow = true; // Assume the "Pay Now" button should be enabled by default
        var withPremiumValue = $A.get("$Label.c.WithPremium"); // edited by srinivasu
        var withOutPremiumValue = $A.get("$Label.c.WithoutPremium");
        for (var i = 0; i < feepayment.length; i++) {
            TotalPayamount = feepayment[i].Amount_Pending__c;
            if (tamount > feepayment[i].Amount_Pending__c) {
                helper.showToast(component, 'dismissible', 'Failed', 'Please Enter Correct Amount', 'error');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow", true);
                return; // Exit the function if the entered amount is greater than pending amount
            }
            //AddedbyRajashekar 21stAug else
            else{
                component.set("v.DisablePayNow", false);
            }
            var amountPending = feepayment[i].Amount_Pending__c;
            var feeType = feepayment[i].Fee_Type__c;
            // Check if the fee type is "University Fee" or "Tuition Fee"
            if (feeType === "University Fee" || feeType === "Tuition Fee" || feeType === "Hostel Fee") {
                if (feeType === "University Fee" || feeType === "Tuition Fee"){
                    /***** added for the issue on 23082024**/
                    /* if (amountPending > 50000) {
                    console.log('amountPending--'+amountPending);
                    if (tamount < 50000) {
                        console.log('tamount--'+tamount);
                        helper.showToast(component, 'dismissible', 'Failed', 'Please pay a minimum of 50,000 for the pending amount.', 'error');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", true);
                        return; // Exit the function if the minimum payment condition is not met
                    }
                } else*/
                    if (tamount == 0) {
                        console.log('tamount--'+tamount);
                        helper.showToast(component, 'dismissible', 'Failed', 'Please Enter Amount Greater than 0.', 'error');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow", true);
                        return; // Exit the function if the minimum payment condition is not met
                    }
                    /*else if (amountPending <= 50000) {
                        if (tamount < amountPending ) {
                            helper.showToast(component, 'dismissible', 'Failed', 'Please pay the full pending amount if it is less than 50,000.', 'error');
                            component.set("v.ModelSpinner", false);
                            component.set("v.DisablePayNow", true);
                            return; // Exit the function if the full payment condition is not met
                        }
                    }*/
                }else{
                    if(tamount < TotalPayamount)
                    {
                        var overallAmount=(tamount/TotalPayamount)*100;
                        console.log('overallAmount'+overallAmount);
                        if(overallAmount < 50){
                            helper.showToast(component,'dismissible','Failed','Please Enter Amount more than 50% of pending amount','error'); 
                            component.set("v.ModelSpinner", false); 
                            component.set("v.DisablePayNow",true);
                        }else{
                            component.set("v.DisablePayNow",false); 
                        }
                    }
                    //AddedbyRajashekar 21stAug else
                    else{
                        component.set("v.DisablePayNow", false);
                    }
                    if (tamount == TotalPayamount) {
                        component.set("v.DisablePayNow", false);
                    }
                }
            }
        }
        /* if (tamount <= TotalPayamount) {
            component.set("v.DisablePayNow", false);
        }*/
        var buttonCheck = component.get("v.DisablePayNow");
        console.log('buttonCheck===>'+buttonCheck);
    },
    AfterPaynow : function(component, event, helper)
    {
        component.set("v.ModelSpinner", true);
        // if(component.get('v.openModal') == true){
        //     helper.closeModel(component, event, helper);
        // }else{
        //     helper.closeMultiModel(component, event, helper);
        // }
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var paymap = component.get("v.PaymentMap");
        for (var key in paymap) 
        {            
            if(paymap[key].key == 'RazorPay')
                mapRazorpay = paymap[key].key;
            if(paymap[key].key == 'PayTM')
                mapPaytm = paymap[key].key;
            if(paymap[key].key == 'EazyPay')
                mapEasypay = paymap[key].key;            
            if(paymap[key].key == 'BillDesk')
                mapBilldesk = paymap[key].key;
        }
        var rate_value;
        
        if(mapRazorpay == 'RazorPay')
        { 
            if(document.getElementById('radio-66').checked) 
            {
                rate_value = document.getElementById('radio-66').value;
            }
        }
        if(mapPaytm == 'PayTM')
        { 
            if(document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            }
        }
        if(mapEasypay == 'EazyPay')
        { 
            if(document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if(mapBilldesk == 'BillDesk')
        {        
            if (document.getElementById('radio-65').checked) {
                rate_value = document.getElementById('radio-65').value;
            }
        }
        var EnteredAmount = component.get("v.EnteredAmount");
        var TotalPayamount ; 
        //AddedbyRajashekar
        var SplitAmountPartial ;
        var splitchecked;
        var stuFeePaymentRec;
        var partial;
        var pending;
        //endshere
        if(rate_value == null || rate_value=='' || rate_value =='undefined')
        {
            helper.showToast(component,'dismissible','Failed','Please Select Payment Gateway','error');
            component.set("v.ModelSpinner", false);             
        }
        else
        {
            var feepayment = component.get("v.lstStuFeePayment");
            console.log('feepayment===>',feepayment);
            for(var i=0;i<feepayment.length;i++)
            {
                TotalPayamount = feepayment[i].Amount_Pending__c;
                if(EnteredAmount >feepayment[i].Amount_Pending__c)
                {
                    helper.showToast(component,'dismissible','Failed','Please Enter Correct Amount','error'); 
                    component.set("v.ModelSpinner", false); 
                }
                
                //AddedbyRajshekar
                if(feepayment[i].Fee_Type__c == 'Hostel Fee' && feepayment[i].Student_Fee_Payments__r != null && feepayment[i].Student_Fee_Payments__r[0].Student_Payment__r.Split_Booking_Fee__c == true){
                    
                    if(component.find("PartialCB") != undefined){
                        partial = component.find("PartialCB").get("v.checked");
                    }
                    
                    if(component.find("PendingCB") != undefined){
                        pending = component.find("PendingCB").get("v.checked");
                    }
                    
                    if(feepayment[i].Student_Fee_Payments__r[0].Student_Payment__r.Split_Booking_Fee__c == true){
                        if(partial == true){
                            SplitAmountPartial = feepayment[i].Student_Fee_Payments__r[0].Student_Payment__r.Amount__c;
                            stuFeePaymentRec = feepayment[i].Student_Fee_Payments__r[0].Id;
                        }else if(pending == true){
                            SplitAmountPartial = feepayment[i].Student_Fee_Payments__r[1].Student_Payment__r.Amount__c;
                            stuFeePaymentRec = feepayment[i].Student_Fee_Payments__r[1].Id;
                        }
                        splitchecked = 1;
                        
                    }
                }
                
                //ends here
            }
            if(EnteredAmount <= TotalPayamount)
            {
                if(rate_value == 'RazorPay')
                {
                    if(EnteredAmount != null || EnteredAmount != '')
                    {                    
                        helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                    else
                    {
                        helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                }
                if(rate_value == 'BillDesk')
                {
                    if(EnteredAmount != null || EnteredAmount != '')
                    {                    
                        // helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        //AddedbyRajashekar
                        if(splitchecked == 1){
                            if(partial == false && pending == false){
                                helper.showToast(component,'dismissible','Failed','Please select any one of the Payment','error'); 
                                component.set("v.ModelSpinner", false); 
                            }else if(partial == false && component.find("PendingCB") == undefined){
                                helper.showToast(component,'dismissible','Failed','Please select the Payment','error'); 
                                component.set("v.ModelSpinner", false); 
                            }else{
                                helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,SplitAmountPartial,'single',stuFeePaymentRec);
                            }
                            //endshere   
                        }else{
                            helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        }
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                    else
                    {                     
                        // helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                        //AddedbyRajashekar
                        if(splitchecked == 1){
                            if(partial == false && pending == false){
                                helper.showToast(component,'dismissible','Failed','Please select any one of the Payment','error'); 
                                component.set("v.ModelSpinner", false); 
                            }else if(partial == false && pending == undefined){
                                helper.showToast(component,'dismissible','Failed','Please select the Payment','error'); 
                                component.set("v.ModelSpinner", false); 
                            }else{
                                helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,SplitAmountPartial,'single',stuFeePaymentRec); 
                            }
                            //endshere
                        }else{
                            helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                        }
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                }
                if(rate_value == 'EazyPay')
                {
                    if(EnteredAmount != null || EnteredAmount != '')
                    {     
                        helper.EasyPayGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                    else
                    {          
                        helper.EasyPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                }
                if(rate_value == 'PayTM')
                {
                    if(EnteredAmount != null || EnteredAmount != '')
                    {     
                        helper.paytmGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                    else
                    {          
                        helper.paytmGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                        component.set("v.ModelSpinner", false);
                        component.set("v.DisablePayNow",false);
                    }
                }
            }
        }        
    },
    MultipleAfterPayNow : function(component, event, helper)
    {
        component.set("v.ModelSpinner", true);
        component.set("v.openMultiModel", false);
        component.set("v.paytmConfirm",false);
        component.set("v.DisablePayNow",true);
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var Multipaymap = component.get("v.MultiPaymentMap");
        for (var key in Multipaymap) 
        {
            if(Multipaymap[key].key == 'RazorPay')
                mapRazorpay = Multipaymap[key].key;
            if(Multipaymap[key].key == 'PayTM')
                mapPaytm = Multipaymap[key].key;
            if(Multipaymap[key].key == 'EazyPay')
                mapEasypay = Multipaymap[key].key;
            if(Multipaymap[key].key == 'BillDesk')
                mapBilldesk = Multipaymap[key].key;            
        }
        var rate_value;
        var totalpayAmount = component.get("v.totalAmount");
        
        if(mapRazorpay == 'RazorPay')
        {  
            if(document.getElementById('radio-66').checked) {
                rate_value = document.getElementById('radio-66').value;
            }
        }
        if(mapPaytm == 'PayTM')
        {  
            if(document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            }
        }
        if(mapEasypay == 'EazyPay')
        {  
            if(document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if(mapBilldesk == 'BillDesk')
        {  
            if (document.getElementById('radio-65').checked) {
                rate_value = document.getElementById('radio-65').value;
            }
        }
        if(rate_value == null || rate_value=='' || rate_value =='undefined')
        {
            helper.showToast(component,'dismissible','Failed','Please Select Payment Gateway','error'); 
            component.set("v.ModelSpinner", false);
        }
        else
        {
            var multirecds =  component.get("v.lstMultipleRecords");
            if(rate_value == 'RazorPay') 
            {                
                helper.rezorPayGeneratePaymentLink(component, event, helper,multirecds,totalpayAmount,'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow",false);
            }
            if(rate_value == 'BillDesk')
            {
                helper.billDeskGeneratePaymentLink(component, event, helper,multirecds,totalpayAmount,'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow",false);
            }
            if(rate_value == 'EazyPay')
            {
                helper.EasyPayGeneratePaymentLink(component, event, helper,multirecds,totalpayAmount,'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow",false);
            }
            if(rate_value == 'PayTM')
            {
                helper.paytmGeneratePaymentLink(component, event, helper,multirecds,totalpayAmount,'Multi');
                component.set("v.ModelSpinner", false);
                component.set("v.DisablePayNow",false);
            }
        }
    },
    paytmRedirect : function(component, event, helper) {
        component.find("paymentForm").getElement().submit();
    },
    view : function(component, event, helper)
    {
        try{
        var index = event.currentTarget.getAttribute("data-value");
        //var index = event.getSource().get("v.name");       
        var lstStuFeePending = component.get("v.lstStuPaymentFee");        
        var selid = lstStuFeePending[index].Id;
     //   let vfPageUrl = '/StudentPortal/apex/FEE_FeeReceipt?id=' + selid;
            
        let action = component.get('c.savePdfAsFile');
        action.setParams({ "recordId": selid });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log('state=> ',state);
            if (state === "SUCCESS") {
                let file = response.getReturnValue();
                console.log('file=> ',file);
                // Step 2: Trigger the download
                let vfPageUrl = '/StudentPortal/sfc/servlet.shepherd/version/download/' + file.Id;
                console.log('vfPageUrl=> ',vfPageUrl);
                window.open(vfPageUrl, '_blank');
                // Step 3: Delete the file after download
                let deleteAction = component.get("c.deleteFile");
                deleteAction.setParams({ "contentDocumentId": response.getReturnValue() });
                $A.enqueueAction(deleteAction);  // Perform the delete after download
            } else {
                console.error('Error fetching download URL:', response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }

      //  window.open('vfPageUrl',"_system","location=yes,enableViewportScale=yes,hidden=no");

         //   window.open(vfPageUrl, '_blank');
        // Open the URL in a new window/tab to directly download the file
        // The `download` attribute in the link forces the browser to download it
      /*  let link = document.createElement('a');
        link.href = vfPageUrl;
        link.setAttribute('download', 'FeeReceipt.pdf');  // This forces a download
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link); // Clean up the element*/
          

               catch(exception){
            console.error('Error Message=>',exception.message);
        }
        },
    
    
    partialChecked : function(component, event, helper){
        var a = component.find("PartialCB").get("v.checked");
        if(a == true){
            component.find("PendingCB").set("v.checked", false);
        }
        /*else if(a == false){
            component.find("PartialCB").set("v.value", true);
        }*/
    },
    
    pendingChecked : function(component, event, helper){
        var a = component.find("PendingCB").get("v.checked");
        if(a == true){
            component.find("PartialCB").set("v.checked", false);
        }
        /*else if(a == false){
            component.find("PendingCB").set("v.value", true);
        }*/ 
    }
})