({
    getYearTypeHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getProgramPlans");
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   var result = response.getReturnValue();
                                   var items = [];
                                   for (var i = 0; i < result.length; i++) 
                                   {
                                       var item = {
                                           "label": result[i],
                                           "value": result[i]
                                       };
                                       items.push(item);
                                   }
                                   component.set("v.yearOptions", items);
                                   component.set("v.Spinner",false);
                               }
                               else
                               {
                                   component.set("v.Spinner",false);
                               }
                           });
        $A.enqueueAction(action);
    },
    getEnrollmentHlpr : function(component, event, helper)
    { 
        // alert('feeYear '+component.get("v.studentType"))
        component.set("v.Spinner",true);
        var feYearvar =  component.get("v.studentType");
        component.set("v.feeYearVar",feYearvar);
        var feYearvar2 =  component.get("v.feeYearVar");
      //  alert('feYearvar2==>'+feYearvar2)
        var action = component.get("c.getProgEnrollNoGRN");
        action.setParams({
            "recId": component.get("v.recordId"),
            "feeYear": component.get("v.studentType")
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   var result = response.getReturnValue().lstPrgEnroll;
                                   var resultPushedSap = response.getReturnValue().lstPrgEnrollPushedSap;
                                   if(result.length > 0)
                                   {
                                       component.set("v.progmEnrollmentLst", result);
                                       component.set("v.confStudSRNLst", resultPushedSap);
                                       
                                       
                                   }
                                   else
                                   {
                                       component.set("v.progmEnrollmentLst", result);
                                       component.set("v.confStudSRNLst", resultPushedSap);
                                       
                                       
                                   }
                                   
                                   component.set("v.Spinner",false);
                               }
                           });
        $A.enqueueAction(action);
    },
    getEnrollmentHlpr2 : function(component, event, helper)
    { 
       // alert('enetering 2');
        // alert('feeYear '+component.get("v.studentType"))
        component.set("v.Spinner",true);
        var feYearvar =  component.get("v.feeYearVar");
        
       // alert('feYearvar '+feYearvar)
        component.set("v.studentType",feYearvar);
        var action = component.get("c.getProgEnrollNoGRN");
        action.setParams({
            "recId": component.get("v.recordId"),
            "feeYear": component.get("v.studentType")
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   var result = response.getReturnValue().lstPrgEnroll;
                                   var resultPushedSap = response.getReturnValue().lstPrgEnrollPushedSap;
                                   if(result.length > 0)
                                   {
                                       component.set("v.progmEnrollmentLst", result);
                                       component.set("v.confStudSRNLst", resultPushedSap);
                                       
                                       
                                   }
                                   else
                                   {
                                       component.set("v.progmEnrollmentLst", result);
                                       component.set("v.confStudSRNLst", resultPushedSap);
                                       
                                       
                                   }
                                   
                                   component.set("v.Spinner",false);
                               }
                           });
        $A.enqueueAction(action);
    },
    pushToSAPHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var selectedEnrollments = component.get("v.progmEnrollmentLst").filter(function(enrollment) {
            return enrollment.Push_Check_Box__c === true;
        });
        
        if (selectedEnrollments.length === 0) {
            this.showToast(component, 'sticky', 'Error', 'Select at least one record', 'error');
            component.set('v.Spinner', false);
            
            return;
        }
        var action = component.get("c.PushDemandsToSAP");
        action.setParams({
            "recId": component.get("v.recordId"),
            "lstPrgEnroll": component.get("v.progmEnrollmentLst"),
            "feeYear": component.get("v.studentType")
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   var result = response.getReturnValue();
                                   component.set("v.progmEnrollmentLst", null);
                                   component.set("v.confStudSRNLst", null);
                                   component.set("v.studentType", null);
                                   this.getYearTypeHlpr(component, event, helper);
                                   component.set("v.showProgressBar", true);
                                   this.getPrcsPercentageHelper(component, event, helper);
                                   
                                   component.set("v.Spinner",false);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getPrcsPercentageHelper : function(component, event, helper)
    {  
        //component.set("v.showProcessBar", false);
        
        var interval = setInterval($A.getCallback(function () {
            var jobStatus = component.get("c.getProcessPercentage");
            if(jobStatus != null)
            {
                jobStatus.setCallback(this, function(jobStatusResponse){
                    var state = jobStatus.getState();
                    if (state === "SUCCESS"){
                        var job = jobStatusResponse.getReturnValue();
                        //alert('=== Job ===='+JSON.stringify(job));
                        
                        component.set("v.processedcount",job.AsyncJob_New.JobItemsProcessed);
                        component.set("v.totalcount",job.AsyncJob_New.TotalJobItems);
                        
                        /*alert('==== ProcessedCount ==='+component.get("v.processedcount"));
                                    alert('==== TotalCount ==='+component.get("v.totalcount"));*/
                            var processedPercent = 0;
                            if(job.AsyncJob_New.JobItemsProcessed != 0)
                            {
                                processedPercent = (job.AsyncJob_New.JobItemsProcessed/job.AsyncJob_New.TotalJobItems) * 100;
                            }
                            var progress = component.get('v.progress');
                            /*component.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                            if(progress === 100)
                            {
                                
                                
                                component.set('v.showProgressBar',false);
                                //$A.get('e.force:refreshView').fire();
                                //$A.get("e.force:closeQuickAction").fire();
                                
                            }*/
                        if (progress === 100) {
                            clearInterval(interval);
                            component.set('v.showProgressBar', false);
                            
                            // Call the enrollment helper method here
                            helper.getEnrollmentHlpr2(component, event, helper);
                            
                            // Any other actions you want to perform when progress reaches 100
                        } else {
                            component.set('v.progress', processedPercent);
                        }

                        }
                    });
                    $A.enqueueAction(jobStatus);
                }
            }), 2000);
        },
        showToast : function(component, mode, title, message, type){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": mode,
                "title": title,
                "message": message,
                "type": type,
                "duration":'2'
            });
            toastEvent.fire();
        },
    })