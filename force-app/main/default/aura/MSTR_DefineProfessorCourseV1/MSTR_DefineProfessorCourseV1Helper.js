({
    doInitHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        var action = component.get("c.DisplaySchools");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var mapAccSchoolValues = [];
                var result = response.getReturnValue().Map_AccSchool;
                for(var key in result){
                    mapAccSchoolValues.push({key: key, value: result[key]});
                }
                
                component.set("v.showProfSchool",response.getReturnValue().ProfSchool);
                component.set("v.showCourseAcross",response.getReturnValue().CourseAcross);                
                component.set("v.LoginuserAccount",response.getReturnValue().LoginUserAccountName);
                component.set("v.MapSchoolName", mapAccSchoolValues);
                
                if(mapAccSchoolValues.length == 1)
                {                    
                    if(response.getReturnValue().ProfSchool == false)
                    {
                        component.set("v.SelectedSchoolId",mapAccSchoolValues[0].key);
                        this.changeSchoolHlpr(component, event, helper);
                    }
                }
                component.set("v.Spinner", false);                
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        
        $A.enqueueAction(action);	
    },
    changeSchoolHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        var SelAccSchoolId = component.get("v.SelectedSchoolId");
        var selectedCourse = component.get("v.showCourseAcross"); 
        var loginAcc = component.get("v.LoginuserAccount");
        var action = component.get("c.DisplayProgram");
        action.setParams({'AccSchoolId':SelAccSchoolId,
                          'SelCourseAcross':selectedCourse,
                          'LoginAccountName':loginAcc});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var mapAccProgramValues = [];
                var result = response.getReturnValue();
                for(var key in result){
                    mapAccProgramValues.push({key: key, value: result[key]});
                }
                component.set("v.MapProgramName", mapAccProgramValues);
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            } 
        });
        $A.enqueueAction(action);	
    },
    changeProgramHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var SelAccProgramId = component.get("v.SelectedProgramId"); 
        var selectedCourse = component.get("v.showCourseAcross");
        var loginAcc = component.get("v.LoginuserAccount");
        var action = component.get("c.DisplayProgramPlan");
        action.setParams({'AccProgramId':SelAccProgramId,
                          'SelCourseAcross':selectedCourse,
                          'LoginAccountName':loginAcc});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var mapAccProgramPlanValues = [];
                var result = response.getReturnValue();
                for(var key in result){
                    mapAccProgramPlanValues.push({key: key, value: result[key]});
                }
                component.set("v.MapProgramPlanName", mapAccProgramPlanValues); 
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);	
    },
    changeProgramPlanHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var SelAccProgramPlanId = component.get("v.SelectedProgramPlanId"); 
        var selectedCourse = component.get("v.showCourseAcross");
        var loginAcc = component.get("v.LoginuserAccount");
        var action = component.get("c.DisplayTerm");
        action.setParams({'AccProgramPlanId':SelAccProgramPlanId,
                          'SelCourseAcross':selectedCourse,
                         'LoginAccountName':loginAcc});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var mapAccTermValues = [];
                var result = response.getReturnValue();
                for(var key in result){
                    mapAccTermValues.push({key: key, value: result[key]});
                }
                component.set("v.MapTermName", mapAccTermValues);
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);	
    },
    changeTermHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        component.set("v.ProfPreference",false);
        var SelAccTermId = component.get("v.SelectedTermId");  
        var CourseAccross = component.get("v.showCourseAcross");
        var LoginAccName = component.get("v.LoginuserAccount");
        var SelAccSchoolId = component.get("v.SelectedSchoolId");
        var action = component.get("c.DisplayCourseOfferingRecords");
        action.setParams({'AccTermId':SelAccTermId,
                          'SelCourseAcross':CourseAccross,
                          'LoginAccountName':LoginAccName,
                          'AccSchoolId':SelAccSchoolId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined && response.getReturnValue().listMainCourse.length >0)
                {
                    var retVal = response.getReturnValue();
                    component.set("v.showCourseOffTable",true);
                    component.set("v.lstHardCore",retVal.listHardCore);
                    component.set("v.lstOpenElective",retVal.listOpenElective);
                    component.set("v.lstProfElective",retVal.listProfElective);
                    component.set("v.lstPractical",retVal.listPractical);
                    component.set("v.lstHcIntegrated",retVal.listHcIntegrated);
                    component.set("v.lstMandatory",retVal.listMandatory);
                    component.set("v.List_CourseMain",retVal.listMainCourse);
                    component.set("v.ProfPreference",retVal.ProfessorPreference); 
                    component.set("v.StrCourseOffCategory",retVal.lst_CourseOffCategory);                     
                    var profschool = component.get("v.showProfSchool");
                    var CourseSchool = component.get("v.showCourseAcross");                   
                    var courseCategory = component.get("v.StrCourseOffCategory");
                    if(profschool == true && CourseSchool == true)
                    {
                        for(var i=0;i<courseCategory.length;i++)
                        {
                            if(courseCategory[i] == 'Hardcore Course')
                                component.set("v.HCourse",false);
                            else if(courseCategory[i] =='Hardcore Integrated Course')
                                component.set("v.HICourse",false);
                                else if(courseCategory[i] =='Practical/Term work')
                                    component.set("v.PracTermwork",false);
                                    else if(courseCategory[i] =='Professional Elective')
                                        component.set("v.ProfEle",false);
                                        else if(courseCategory[i] =='Open Elective')
                                            component.set("v.OpenEle",false);
                                            else if(courseCategory[i] =='Mandatory Course')
                                                component.set("v.ManCourse",false);
                        }
                        
                    }
                    else if(profschool == false)
                    {
                            component.set("v.HCourse",false);
                            component.set("v.HICourse",false);
                            component.set("v.PracTermwork",false);
                            component.set("v.ProfEle",false);
                            component.set("v.OpenEle",false);
                            component.set("v.ManCourse",false);
                    }
                }
                else
                {
                    this.DisplayCourseOfferingHlpr(component, event, helper);
                }
                component.set("v.Spinner", false); 
            }
            else
            {
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
            
        });       
        $A.enqueueAction(action);	
    },
    DisplayCourseOfferingHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var SelAccTermId = component.get("v.SelectedTermId"); 
        var CourseAccross = component.get("v.showCourseAcross");
        var LoginAccName = component.get("v.LoginuserAccount");
        var SelAccSchoolId = component.get("v.SelectedSchoolId");
        var action = component.get("c.DisplayCourseOffering");
        action.setParams({'AccTermId':SelAccTermId,
                         'SelCourseAcross':CourseAccross,
                          'LoginAccountName':LoginAccName,
                          'AccSchoolId':SelAccSchoolId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();
                    component.set("v.showCourseOffTable",true);
                    component.set("v.lstHardCore",retVal.listHardCore);
                    component.set("v.lstOpenElective",retVal.listOpenElective);
                    component.set("v.lstProfElective",retVal.listProfElective);
                    component.set("v.lstPractical",retVal.listPractical);
                    component.set("v.lstHcIntegrated",retVal.listHcIntegrated);
                    component.set("v.lstMandatory",retVal.listMandatory);
                    component.set("v.List_CourseMain",retVal.listMainCourse); 
                    component.set("v.StrCourseOffCategory",retVal.lst_CourseOffCategory);
                    var profschool = component.get("v.showProfSchool");
                    var CourseSchool = component.get("v.showCourseAcross");
                    var courseCategory = component.get("v.StrCourseOffCategory");
                    if(profschool == true && CourseSchool == true)
                    {
                        for(var i=0;i<courseCategory.length;i++)
                        {
                            if(courseCategory[i] == 'Hardcore Course')
                                component.set("v.HCourse",false);
                            else if(courseCategory[i] =='Hardcore Integrated Course')
                                component.set("v.HICourse",false);
                                else if(courseCategory[i] =='Practical/Term work')
                                    component.set("v.PracTermwork",false);
                                    else if(courseCategory[i] =='Professional Elective')
                                        component.set("v.ProfEle",false);
                                        else if(courseCategory[i] =='Open Elective')
                                            component.set("v.OpenEle",false);
                                            else if(courseCategory[i] =='Mandatory Course')
                                                component.set("v.ManCourse",false);
                        }
                        
                    }
                    else if(profschool == false)
                    {
                            component.set("v.HCourse",false);
                            component.set("v.HICourse",false);
                            component.set("v.PracTermwork",false);
                            component.set("v.ProfEle",false);
                            component.set("v.OpenEle",false);
                            component.set("v.ManCourse",false);
                    }
                }
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
            
        });       
        $A.enqueueAction(action);
    },
    ValidationHlpr : function(component, event, helper,Method)
    {
        component.set("v.Spinner", true);
        var action = component.get("c.ValidationPreferences");
        action.setParams({'lstHardCourse':component.get("v.lstHardCore"),
                          'lstHCIntegrated':component.get("v.lstHcIntegrated"),
                          'lstPractical':component.get("v.lstPractical"),
                          'lstOpenElective':component.get("v.lstOpenElective"),
                          'lstProfElective':component.get("v.lstProfElective"),
                          'lstMandatory':component.get("v.lstMandatory"),
                          'mainLst':component.get("v.List_CourseMain"),
                          'ProfSchool':component.get("v.showProfSchool")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {                    
                    if(response.getReturnValue().showsave == true)
                    {                       
                        if(response.getReturnValue().HardDupErrmsg != null)
                        {
                            var retVal = response.getReturnValue().HardDupErrmsg;
                            this.showToast(component,'dismissible','Failed',retVal,'error');
                        }
                        if(response.getReturnValue().MainErrmsg != null)
                        {
                            var retVal = response.getReturnValue().MainErrmsg;
                            this.showToast(component,'dismissible','Failed',retVal,'error');
                        }
                    }
                    if(response.getReturnValue().showsave != true)
                    {
                        if(Method == 'save')
                            this.SaveCourseOfferingHlpr(component, event, helper);                         
                        else if(Method == 'confirm')
                            this.SaveConfrimHlpr(component, event, helper);    
                    }
                }
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });       
        $A.enqueueAction(action);
    },
    
    SaveCourseOfferingHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var profSchool = component.get("v.showProfSchool");
        var CourseSchool = component.get("v.showCourseAcross");
        var SelAccTermId = component.get("v.SelectedTermId");  
        var action = component.get("c.CreateProfessorCourseRecords");
        action.setParams({'lstHc':component.get("v.lstHardCore"),
                          'lstHcIntegrated':component.get("v.lstHcIntegrated"),
                          'lstPract':component.get("v.lstPractical"),
                          'lstOpenEle':component.get("v.lstOpenElective"),
                          'lstProfel':component.get("v.lstProfElective"),
                          'lstMandtry':component.get("v.lstMandatory"),
                          'ProfPreference':false,
                          'AccTermId':SelAccTermId});
        action.setCallback(this, function(response) {
            var state = response.getState();
           // alert('==state---'+state);
            if (state === "SUCCESS") 
            {
                this.showToast(component,'dismissible','success','Professor / Student Course Preference created Successfully..!','success');
                
                if(profSchool == true)
                    component.set("v.SelectedSchoolId",null);
                component.set('v.SelectedProgramId',null);
                component.set('v.SelectedProgramPlanId',null);
                component.set('v.SelectedTermId',null); 
                component.set("v.Spinner", false); 
                var lstCourse =[];
                component.set("v.List_CourseMain",lstCourse);
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });       
        $A.enqueueAction(action);
    },
    SaveConfrimHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var profSchool = component.get("v.showProfSchool");
        var CourseSchool = component.get("v.showCourseAcross");
        var SelAccTermId = component.get("v.SelectedTermId");  
        var action = component.get("c.CreateProfessorCourseRecords");
        action.setParams({'lstHc':component.get("v.lstHardCore"),
                          'lstHcIntegrated':component.get("v.lstHcIntegrated"),
                          'lstPract':component.get("v.lstPractical"),
                          'lstOpenEle':component.get("v.lstOpenElective"),
                          'lstProfel':component.get("v.lstProfElective"),
                          'lstMandtry':component.get("v.lstMandatory"),
                          'ProfPreference':true,
                          'AccTermId':SelAccTermId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                this.showToast(component,'dismissible','success','Professor / Student Course Preference Confirmed Successfully..!','success');
                
                if(profSchool == true)
                    component.set("v.SelectedSchoolId",null);
                component.set('v.SelectedProgramId',null);
                component.set('v.SelectedProgramPlanId',null);
                component.set('v.SelectedTermId',null);                
                component.set("v.Spinner", false); 
                var lstCourse =[];
                component.set("v.List_CourseMain",lstCourse);
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });       
        $A.enqueueAction(action);
    },
    getPreferenceHlpr : function(component, event, helper)
    {        
        var action = component.get("c.getPreference");
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if (state === "SUCCESS")
                               {
                                   var PreferenceMap = [];
                                   var result = response.getReturnValue();
                                   
                                   for ( var key in result ) {
                                       PreferenceMap.push({key: key, value: result[key]});
                                   }
                                   component.set("v.MapPreference",PreferenceMap); 
                               }
                           });
        $A.enqueueAction(action);
    },
    showToast : function(component, mode, title, message, type)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2'
        });
        toastEvent.fire();
    }
})