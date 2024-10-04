({
    doInitHpr : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action = component.get("c.fetchData");
        action.setParams({'iaType':component.get("v.selectedIAtype")});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS'){
                if(result.getReturnValue() != undefined){
                    var retVal = result.getReturnValue();
                    component.set("v.isAllowed",retVal.isAllowed);
                    component.set("v.errorMessage",retVal.message);
                    component.set("v.courseList",retVal.list_CrsCons);
                    
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
    handleRefEventHpr : function(component, event, helper) {
        //alert(event.getParam("iaType"));
        component.set("v.selectedIAtype",event.getParam("iaType"));
        component.set("v.selectedConId","");
        component.set("v.selectedCrsType","");
        component.set("v.isSelected",false);
        helper.doInitHpr(component, event, helper);
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