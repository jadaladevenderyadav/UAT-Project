({
	doInit : function(component, event, helper) {
        helper.doInitHpr(component, event, helper);
    },
    calcTotal : function(component, event, helper) {
        helper.calcTotalHpr(component, event, helper);
    },
    saveIaMarks : function(component, event, helper) {
        helper.saveIaMarksHpr(component, event, helper);
    },
    backToList : function(component, event, helper) {
        helper.fireRefEvent(component, event, helper);
    },
})