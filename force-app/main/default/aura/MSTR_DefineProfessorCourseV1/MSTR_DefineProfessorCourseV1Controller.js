({
    doInit : function(component, event, helper) 
    {
        helper.doInitHlpr(component, event, helper);
    },
    changeSchool : function(component, event, helper) 
    {
        var schoolProf = component.get("v.showProfSchool");
        helper.changeSchoolHlpr(component, event, helper);        
    },
    changeProgram : function(component, event, helper) 
    {
        helper.changeProgramHlpr(component, event, helper);
        component.set('v.SelectedProgramPlanId',null);
        component.set('v.SelectedTermId',null);
    },
    changeProgramPlan : function(component, event, helper) 
    {
        helper.changeProgramPlanHlpr(component, event, helper); 
        component.set('v.SelectedTermId',null);
    },
    changeTerm : function(component, event, helper) 
    {
        helper.getPreferenceHlpr(component, event, helper);
        helper.changeTermHlpr(component, event, helper);
    },
    
    SaveCourseOffering : function(component, event, helper) 
    {
        helper.ValidationHlpr(component,event,helper,'save');        
    },
    SaveConfrimAction : function(component, event, helper) 
    {
        component.set("v.isModalOpen", true);        
    },
    closeAction : function(component, event, helper) 
    {
        var profSchool = component.get("v.showProfSchool");
        if(profSchool == true)
            component.set("v.SelectedSchoolId",null);
        component.set('v.SelectedProgramId',null);
        component.set('v.SelectedProgramPlanId',null);
        component.set('v.SelectedTermId',null);
        var lstCourse =[];
        component.set("v.List_CourseMain",lstCourse);
    },
    closeModel: function(component, event, helper) 
    {  
        component.set("v.isModalOpen", false);
    },    
    submitDetails: function(component, event, helper) 
    {
        component.set("v.isModalOpen", false);
         helper.ValidationHlpr(component,event,helper,'confirm');  
        //helper.SaveConfrimHlpr(component, event, helper);
    },
})