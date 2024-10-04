({
    doInitHpr : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action = component.get("c.fetchData");
        action.setParams({'prfConId':component.get("v.profCrsConId"),
                          'iaType':component.get("v.iaType")});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS'){
                if(result.getReturnValue() != undefined){
                    var retVal = result.getReturnValue();
                    
                    component.set("v.studentList",retVal.list_marksWpr);
                    component.set("v.crsConnection",retVal.mainCrsConn);
                    helper.calcTotalHpr(component, event, helper);
                    component.set("v.Spinner",false);
                }else{
                    component.set("v.Spinner",false);
                    this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                }
            }else{
                component.set("v.Spinner",false);
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    calcTotalHpr : function(component, event, helper) {
        var marksList = component.get("v.studentList");
       // alert(JSON.stringify(marksList));
        for(var i=0;i<marksList.length;i++){
            var iam = marksList[i];
            var knldg = (iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c != -1 && iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c != undefined && iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c != '' && iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c != null) ? iam.iaMark.Knowledge_of_Exercise_Secured_Marks__c : 0;
            var exec = (iam.iaMark.Execution_of_Exercise_Secured_Marks__c != -1 && iam.iaMark.Execution_of_Exercise_Secured_Marks__c != undefined && iam.iaMark.Execution_of_Exercise_Secured_Marks__c != '' && iam.iaMark.Execution_of_Exercise_Secured_Marks__c != null) ? iam.iaMark.Execution_of_Exercise_Secured_Marks__c : 0;
            var desc = (iam.iaMark.Description_of_Experiment_Secured_Mark__c != -1 && iam.iaMark.Description_of_Experiment_Secured_Mark__c != undefined && iam.iaMark.Description_of_Experiment_Secured_Mark__c != '' && iam.iaMark.Description_of_Experiment_Secured_Mark__c != null) ? iam.iaMark.Description_of_Experiment_Secured_Mark__c : 0;
            var viva = (iam.iaMark.Viva_Voce_Practical_Secured_Marks__c != -1 && iam.iaMark.Viva_Voce_Practical_Secured_Marks__c != undefined && iam.iaMark.Viva_Voce_Practical_Secured_Marks__c != '' && iam.iaMark.Viva_Voce_Practical_Secured_Marks__c != null) ? iam.iaMark.Viva_Voce_Practical_Secured_Marks__c : 0;
            var punc = (iam.iaMark.Punctuality_Secured_Marks__c != -1 && iam.iaMark.Punctuality_Secured_Marks__c != undefined && iam.iaMark.Punctuality_Secured_Marks__c != '' && iam.iaMark.Punctuality_Secured_Marks__c != null) ? iam.iaMark.Punctuality_Secured_Marks__c : 0;
            var result = (iam.iaMark.Results_Secured_Marks__c != -1 && iam.iaMark.Results_Secured_Marks__c != undefined && iam.iaMark.Results_Secured_Marks__c != '' && iam.iaMark.Results_Secured_Marks__c != null) ? iam.iaMark.Results_Secured_Marks__c : 0;
            iam.iaMark.Total_Secured_Marks_New__c = parseFloat(knldg)+parseFloat(exec)+parseFloat(desc)+parseFloat(viva)+parseFloat(punc)+parseFloat(result);
            iam.total = parseFloat(knldg)+parseFloat(exec)+parseFloat(desc)+parseFloat(viva)+parseFloat(punc)+parseFloat(result);
        }
        component.set("v.studentList",marksList);
    },
    saveIaMarksHpr : function(component, event, helper) {
        component.set("v.Spinner",true);
        var errorCount = 0;
        var allReqFields = component.find('inputReq');
        if(allReqFields){
            if(allReqFields.length) {
                var allValid = allReqFields.reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                if (!allValid) {
                    errorCount++;
                }
            }else{
                var allValid = allReqFields;
                if (!allValid.get('v.validity').valid) {
                    errorCount++;
                }
            }
        }
        if(errorCount > 0){
            this.showToast(component,'dismissible','Error','Please check below messages..','error');
            component.set("v.Spinner",false);
        }else{
            var marksList = component.get("v.studentList");
            var finalList = [];
            for(var i=0;i<marksList.length;i++) {
                var iam = marksList[i];
               // if(iam.iaMark.Id != null){ // || (iam.total != undefined && iam.total != null)
                    finalList.push(iam.iaMark);
               // }
            }
            
            if(finalList.length > 0){
               // alert(JSON.stringify(finalList));
                var action = component.get("c.saveData");
                action.setParams({'list_IaMarks':finalList});
                action.setCallback(this,function(result){
                    //alert(result.getState());
                    if(result.getState() === 'SUCCESS'){
                        this.showToast(component,'dismissible','Success','IA Marks updated succesfully','success');
                        component.set("v.Spinner",false);
                        helper.fireRefEvent(component, event, helper);
                    }else{
                        component.set("v.Spinner",false);
                        this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                    }
                });
                $A.enqueueAction(action);
            }else{
                this.showToast(component,'dismissible','Error','Enter marks for atleast one Student','error');
                component.set("v.Spinner",false);
            }
        }
    },
    fireRefEvent : function(component, event, helper) {
        var refreshEvt = component.getEvent("ASM_RefreshProfView");
        refreshEvt.setParams({"iaType": component.get("v.iaType")});
        refreshEvt.fire();
    },
    showToast : function(component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2000'
        });
        toastEvent.fire();
    },
})