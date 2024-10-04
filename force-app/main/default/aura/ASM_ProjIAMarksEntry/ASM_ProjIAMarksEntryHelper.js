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
        for(var i=0;i<marksList.length;i++){
            var iam = marksList[i];
            var soTopic = (iam.iaMark.Selection_of_Topic_Secured_Marks__c != -1 && iam.iaMark.Selection_of_Topic_Secured_Marks__c != undefined && iam.iaMark.Selection_of_Topic_Secured_Marks__c != '' && iam.iaMark.Selection_of_Topic_Secured_Marks__c != null) ? iam.iaMark.Selection_of_Topic_Secured_Marks__c : 0;
            var anySynt = (iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c != -1 && iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c != undefined && iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c != '' && iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c != null) ? iam.iaMark.Analysis_and_Synthesis_Secured_Marks__c : 0;
            var liSrvy = (iam.iaMark.Literature_Survey_Secured_Marks__c != -1 && iam.iaMark.Literature_Survey_Secured_Marks__c != undefined && iam.iaMark.Literature_Survey_Secured_Marks__c != '' && iam.iaMark.Literature_Survey_Secured_Marks__c != null) ? iam.iaMark.Literature_Survey_Secured_Marks__c : 0;
            var ethAtt = (iam.iaMark.Ethical_Attitude_Secured_Marks__c != -1 && iam.iaMark.Ethical_Attitude_Secured_Marks__c != undefined && iam.iaMark.Ethical_Attitude_Secured_Marks__c != '' && iam.iaMark.Ethical_Attitude_Secured_Marks__c != null) ? iam.iaMark.Ethical_Attitude_Secured_Marks__c : 0;
            var indLearn = (iam.iaMark.Independent_Learning_Secured_Marks__c != -1 && iam.iaMark.Independent_Learning_Secured_Marks__c != undefined && iam.iaMark.Independent_Learning_Secured_Marks__c != '' && iam.iaMark.Independent_Learning_Secured_Marks__c != null) ? iam.iaMark.Independent_Learning_Secured_Marks__c : 0;
            var oralPrst = (iam.iaMark.Oral_Presentation_Secured_Marks__c != -1 && iam.iaMark.Oral_Presentation_Secured_Marks__c != undefined && iam.iaMark.Oral_Presentation_Secured_Marks__c != '' && iam.iaMark.Oral_Presentation_Secured_Marks__c != null) ? iam.iaMark.Oral_Presentation_Secured_Marks__c : 0;
            var rptWrt = (iam.iaMark.Report_Writing_Secured_Marks__c != -1 && iam.iaMark.Report_Writing_Secured_Marks__c != undefined && iam.iaMark.Report_Writing_Secured_Marks__c != '' && iam.iaMark.Report_Writing_Secured_Marks__c != null) ? iam.iaMark.Report_Writing_Secured_Marks__c : 0;
            var contLrn = (iam.iaMark.Continuous_Learning_Secured_Marks__c != -1 && iam.iaMark.Continuous_Learning_Secured_Marks__c != undefined && iam.iaMark.Continuous_Learning_Secured_Marks__c != '' && iam.iaMark.Continuous_Learning_Secured_Marks__c != null) ? iam.iaMark.Continuous_Learning_Secured_Marks__c : 0;
            iam.iaMark.Total_Secured_Marks_New__c = parseFloat(soTopic)+parseFloat(anySynt)+parseFloat(liSrvy)+parseFloat(ethAtt)+parseFloat(indLearn)+parseFloat(oralPrst)+parseFloat(rptWrt)+parseFloat(contLrn);
            iam.total = parseFloat(soTopic)+parseFloat(anySynt)+parseFloat(liSrvy)+parseFloat(ethAtt)+parseFloat(indLearn)+parseFloat(oralPrst)+parseFloat(rptWrt)+parseFloat(contLrn);
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
            for(var i=0;i<marksList.length;i++){
                var iam = marksList[i];
                //if(iam.iaMark.Id != null ){ //|| (iam.total != undefined && iam.total != '')
                    finalList.push(iam.iaMark);
               // }
            }
            
            if(finalList.length > 0){
                //alert(finalList.length);
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