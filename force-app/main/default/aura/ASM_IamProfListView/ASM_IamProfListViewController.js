({
	doInit : function(component, event, helper) {
        helper.doInitHpr(component, event, helper);
    },
    selectCon : function(component, event, helper) {
        var cConList = component.get("v.courseList");
        var index = event.getSource().get("v.name");
        
        component.set("v.selectedConId",cConList[index].Id);
        component.set("v.selectedCrsType",cConList[index].hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c);
        component.set("v.isSelected",true);
    },
    goBack : function(component, event, helper) {
        component.set("v.selectedConId","");
        component.set("v.selectedCrsType","");
        component.set("v.isSelected",false);
    },
    handleRefEvent : function(component, event, helper) {
        helper.handleRefEventHpr(component, event, helper);
    },
})