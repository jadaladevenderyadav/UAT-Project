({
	getTermDetailHlp : function(component, event,helper) {
		component.set("v.Spinner",true);
        var action = component.get("c.getTermDetails");
        //component.get("v.recordId")
       // var recId = 'a0P0w000003vefz';
        action.setParams({'termId':component.get("v.recordId")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
            	if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();                    
                    component.set("v.objTerm",retVal.objTerm);
                    component.set("v.filterIds", retVal.filterIds);
                    
                    var mapValues = [];
                    var result = retVal.hcCoursePl;
                    for(var key in result){
                        mapValues.push({label: result[key],value: key});
                    }
                  //  alert(JSON.stringify(result));
                	component.set("v.mapHardCorePl", mapValues);
                    
                    var mapValues = [];
                    var result = retVal.hcIntegratedPl;
                    for(var key in result){
                        mapValues.push({key: key, value: result[key]});
                    }
                	component.set("v.mapHcIntegratedPl", mapValues);
                    
                    var mapValues = [];
                    var result = retVal.pratialPl;
                    for(var key in result){
                        mapValues.push({key: key, value: result[key]});
                    }
                	component.set("v.mapPracticalPl", mapValues);
                    
                    var mapValues = [];
                    var result = retVal.MandatoryPl;
                    for(var key in result){
                        mapValues.push({key: key, value: result[key]});
                    }
                	component.set("v.mapMandatoryPl", mapValues);
                    
                    var mapValues = [];
                    var result = retVal.oElectivePl;
                    for(var key in result){
                        mapValues.push({key: key, value: result[key]});
                    }
                	component.set("v.mapoElectivePl", mapValues);
                    
                    var mapValues = [];
                    var result = retVal.pElectivePl;
                    for(var key in result){
                        mapValues.push({key: key, value: result[key]});
                    }
                	component.set("v.mappElectivePl", mapValues);
                    
                    
                    // alert(retVal.objTerm.Course_Offering_Created__c);
                    if(retVal.objTerm.Course_Offering_Created__c){
                        this.getCourseDetailHelper(component,event,helper);
                    }
                    else{
                        this.getPlanDetailHelper(component,event,helper);
                    }
                    
                    
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
	},
    getPlanDetailHelper: function(component, event,helper) 
    {
    	component.set("v.Spinner",true);
      //  var recId = 'a0P0w000003vefz';
        var action = component.get("c.getPlanRequirement");
        action.setParams({'termId':component.get("v.recordId")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                    
                    component.set("v.lstHardCore",retVal.listHardCore);
                  //  alert(JSON.stringify(retVal.listOpenElective));
                    component.set("v.lstoElective",retVal.listOpenElective);
                    component.set("v.lstpElective",retVal.listProfElective);
                    component.set("v.lstPractical",retVal.listPractical);
                    component.set("v.lstHcIntegrated",retVal.listHcIntegrated);
                    component.set("v.lstMandatory",retVal.listMandatory);
                    component.set("v.totalCredit",retVal.totalCredit);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },    
    getCourseDetailHelper: function(component, event,helper) 
    {
    	component.set("v.Spinner",true);
       // var recId = 'a0P0w000003vefz';
        var action = component.get("c.getcourseOffering");
        action.setParams({'termId':component.get("v.recordId")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                    
                    component.set("v.lstHardCore",retVal.listHardCore);
                  //  alert(JSON.stringify(retVal.listOpenElective));
                    component.set("v.lstoElective",retVal.listOpenElective);
                    component.set("v.lstpElective",retVal.listProfElective);
                    component.set("v.lstPractical",retVal.listPractical);
                    component.set("v.lstHcIntegrated",retVal.listHcIntegrated);
                    component.set("v.lstMandatory",retVal.listMandatory);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
    addHardCoreRecordHelper: function(component, event, helper) {
    	var hcore = component.get("v.lstHardCore");
        var termId = component.get("v.objTerm").id;
        var hcoreSize = hcore.length + 1;
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Hardcore Course' AND hed__Account__c = '"+ program.Program_Plan__r.hed__Account__r.ParentId + "'";
        hcore.push({
            'courseId': '',
            'courseName': '',
            'credits': '',
            'count': hcoreSize,
            'subCount':'',
            'termId':termId,
            'filter':filter
        });
        component.set("v.lstHardCore", hcore);
    
    },
	RemoveHardCoreRecordHelper: function(component, event, helper) {
        var hcore = component.get("v.lstHardCore");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = hcore[index].recordId;
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }    
        hcore.splice(index, 1);
        for(var i=0;i<hcore.length;i++){
            hcore[i].count = i+1;
        }
        component.set("v.lstHardCore", hcore);
    },
    addHcIntegratedRecordHelper: function(component, event, helper) {
    	var hcore = component.get("v.lstHcIntegrated");
        var termId = component.get("v.objTerm").id;
        var hcoreSize = hcore.length + 1;
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Hardcore Integrated Course' AND hed__Account__c = '"+ program.Program_Plan__r.hed__Account__r.ParentId + "'";        
        hcore.push({
            'courseId': '',
            'courseName': '',
            'credits': '',
            'count': hcoreSize,
            'subCount':'',
            'termId':termId,
            'filter':filter
        });
        component.set("v.lstHcIntegrated", hcore);
    
    },
	RemoveHcIntegratedRecordHelper: function(component, event, helper) {
        var hcore = component.get("v.lstHcIntegrated");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = hcore[index].recordId;
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }    
        hcore.splice(index, 1);
        for(var i=0;i<hcore.length;i++){
            hcore[i].count = i+1;
        }
        component.set("v.lstHcIntegrated", hcore);
    },
    addMandatoryRecordHelper: function(component, event, helper) {
    	var hcore = component.get("v.lstMandatory");
        var termId = component.get("v.objTerm").id;
        var hcoreSize = hcore.length + 1;
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Mandatory Course' AND hed__Account__c = '"+ program.Program_Plan__r.hed__Account__r.ParentId + "'";        
        hcore.push({
            'courseId': '',
            'courseName': '',
            'credits': '',
            'count': hcoreSize,
            'subCount':'',
            'termId':termId,
            'filter':filter
        });
        component.set("v.lstMandatory", hcore);
    
    },
	RemoveMandatoryRecordHelper: function(component, event, helper) {
        var hcore = component.get("v.lstMandatory");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = hcore[index].recordId;
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }    
       // alert(hcore);
        hcore.splice(index, 1);
        for(var i=0;i<hcore.length;i++){
            hcore[i].count = i+1;
        }
        component.set("v.lstMandatory", hcore);
    },
	addopenElectiveRecordHelper: function(component, event, helper) {
    	var oEle = component.get("v.lstoElective");
        var oEleSize = oEle.length + 1;
        var oEleName = 'OPEN ELECTIVES'+ oEleSize;
        var termId = component.get("v.objTerm").id;
       // var accIds = component.get("v.filterIds");
        var filter = "Category__c = 'Open Elective' AND hed__Account__c IN: ";        
        oEle.push({'credits':'2','lstPlanLi':[{'courseId':'','courseName':'','credits':'0','termId':termId,'filter':filter}],
                   'Name':oEleName,'parentId':'','count':oEleSize,'termId':termId});
        component.set("v.lstoElective", oEle);
    
    },
	RemoveopenElectiveHelper: function(component, event, helper) {
        var oEle = component.get("v.lstoElective");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = oEle[index].recordId;
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEle.splice(index, 1);
        var oEleName = 'OPEN ELECTIVES';
        for(var i=0;i<oEle.length;i++){
            oEle[i].count = i+1;
            var oeSize = i+1;
            oEle[i].Name = oEleName + oeSize;            
            oEle[i].parentId = '';
            if(!oEle[i].credits){
            	oEle[i].credits = '';
            }    
            for(var j=0;j<oEle[i].lstPlanLi.length;j++){
                if(!oEle[i].lstPlanLi[j].count){
                	oEle[i].lstPlanLi[j].count = '';
                }    
                if(!oEle[i].lstPlanLi[j].credits){
                	oEle[i].lstPlanLi[j].credits = '0';
                }
                if(!oEle[i].lstPlanLi[j].courseId){
                	oEle[i].lstPlanLi[j].courseId = '';
                }   
                if(!oEle[i].lstPlanLi[j].courseName){
                	oEle[i].lstPlanLi[j].courseName = '';
                }    
            }
        }
        component.set("v.lstoElective", oEle);
    },  
    addopenElectiveLiRecHelper: function(component, event, helper) {
    	var oEle = component.get("v.lstoElective");        
        var index = event.getSource().get("v.value");
        var oEleLi = component.get("v.lstoElective")[index].lstPlanLi;
        var termId = component.get("v.objTerm").id;
     //   var accIds = component.get("v.filterIds");
        var filter = "Category__c = 'Open Elective' AND hed__Account__c IN:";        
        oEleLi.push({'courseId':'','courseName':'','credits':'0','termId':termId,'filter':filter});
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstoElective", oEle);    
    },
    RemoveopenElectiveLiHelper: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index1 = selectedItem.dataset.record;
        var index = event.target.id;
      //  alert(event.target.id);
      //  alert(selectedItem);
      //  alert(index1);
        var oEle = component.get("v.lstoElective");        
        var oEleLi = component.get("v.lstoElective")[index].lstPlanLi;
        var recordId = oEleLi[index1].recordId;
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEleLi.splice(index1, 1);
      //  alert(oEleLi);
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstoElective", oEle);
    },
	addProElectiveRecordHelper: function(component, event, helper) {
    	var oEle = component.get("v.lstpElective");
        var oEleSize = oEle.length + 1;
        var oEleName = 'Professional ELECTIVES'+ oEleSize;
        var termId = component.get("v.objTerm").id;
        var program = component.get("v.program");
        var filter = "Category__c = 'Professional Elective' AND hed__Account__c = '"+ program.Program_Plan__r.hed__Account__r.ParentId + "'";        
        oEle.push({'credits':'2','lstPlanLi':[{'courseId':'','courseName':'','credits':'0','termId':termId,'filter':filter}],
                   'Name':oEleName,'parentId':'','count':oEleSize,'termId':termId});
        component.set("v.lstpElective", oEle);
    
    },
	RemoveProElectiveHelper: function(component, event, helper) {
        var oEle = component.get("v.lstpElective");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = oEle[index].recordId;
        alert(JSON.stringify(oEle[index]));
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEle.splice(index, 1);
        var oEleName = 'Professional ELECTIVES';
        for(var i=0;i<oEle.length;i++){            
            oEle[i].count = i+1;
            var oeSize = i+1;
            oEle[i].Name = oEleName + oeSize;            
            oEle[i].parentId = '';
            if(!oEle[i].credits){
            	oEle[i].credits = '';
            }    
            for(var j=0;j<oEle[i].lstPlanLi.length;j++){
                if(!oEle[i].lstPlanLi[j].count){
                	oEle[i].lstPlanLi[j].count = '';
                }    
                if(!oEle[i].lstPlanLi[j].credits){
                	oEle[i].lstPlanLi[j].credits = '0';
                }
                if(!oEle[i].lstPlanLi[j].courseId){
                	oEle[i].lstPlanLi[j].courseId = '';
                }   
                if(!oEle[i].lstPlanLi[j].courseName){
                	oEle[i].lstPlanLi[j].courseName = '';
                }    
            }    
        }
        component.set("v.lstpElective", oEle);
    },  
    addProElectiveLiRecHelper: function(component, event, helper) {
    	var oEle = component.get("v.lstpElective");        
        var index = event.getSource().get("v.value");
        var oEleLi = component.get("v.lstpElective")[index].lstPlanLi;
        var termId = component.get("v.objTerm").id;
        var program = component.get("v.program");
        var filter = "Category__c = 'Professional Elective' AND hed__Account__c = '"+ program.Program_Plan__r.hed__Account__r.ParentId + "'";        
        oEleLi.push({'courseId':'','courseName':'','credits':'0','termId':termId,'filter':filter});
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstpElective", oEle);    
    },
    RemoveProElectiveLiHelper: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index1 = selectedItem.dataset.record;
        var index = event.target.id;
        var oEle = component.get("v.lstpElective");        
        var oEleLi = component.get("v.lstpElective")[index].lstPlanLi;
        var recordId = oEleLi[index1].recordId;
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEleLi.splice(index1, 1);
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstpElective", oEle);
    }, 
    addPraticalRecordHelper: function(component, event, helper) {
    	var hcore = component.get("v.lstPractical");
        var termId = component.get("v.objTerm").id;
        var hcoreSize = hcore.length + 1;
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Practical/Term Work' AND hed__Account__c = '"+ program.Program_Plan__r.hed__Account__r.ParentId + "'";        
        hcore.push({
            'courseId': '',
            'courseName': '',
            'credits': '',
            'count': hcoreSize,
            'subCount':'',
            'termId':termId,
            'filter':filter
        });
        component.set("v.lstPractical", hcore);
    },
	RemovePraticalHelper: function(component, event, helper) {
        var hcore = component.get("v.lstPractical");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = hcore[index].recordId;
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }    
        hcore.splice(index, 1);
        for(var i=0;i<hcore.length;i++){
            hcore[i].count = i+1;
        }
        component.set("v.lstPractical", hcore);
    },
    saveRecordHelper: function(component, event,helper,boolType) 
    {
    	component.set("v.Spinner",true);
      //  console.log(JSON.stringify(component.get("v.lstoElective")));
      //  console.log(JSON.stringify(component.get("v.lstpElective")));
        var action = component.get("c.savePlanRequiement");
        action.setParams({'termId':component.get("v.recordId"),
                          'lstHc':component.get("v.lstHardCore"),
                          'lstHcIntegrated':component.get("v.lstHcIntegrated"),
                          'lstPra':component.get("v.lstPractical"),
                          'lstOe':component.get("v.lstoElective"),
                          'lstPe':component.get("v.lstpElective"),
                          'lstMandatory':component.get("v.lstMandatory"),
                          'deletedIds':component.get("v.deletedRecordIds"),
                          'type':boolType
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();  
          //  alert(JSON.stringify(response.getError()));
            if (state === "SUCCESS") {
            	if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();                    
                    if(retVal == 'Success'){
                    	this.showToast(component,'dismissible','Success','Record Updated..!!','success');
                        $A.get("e.force:closeQuickAction").fire();
        				$A.get('e.force:refreshView').fire();
                    }
                    else{
                    	this.showToast(component,'dismissible','Failed',retVal,'error');    
                    }
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
    calculateCreditHelper: function(component, event,helper) 
    {
        var tc = 0; 
        var hc = component.get("v.lstHardCore");
        for(var i=0;i<hc.length;i++){ 
            if(hc[i].credits){
            	tc = tc + parseInt(hc[i].credits);     
            }
        }
        var hi = component.get("v.lstHcIntegrated");
        for(var i=0;i<hi.length;i++){ 
            if(hi[i].credits){
            	tc = tc + parseInt(hi[i].credits);     
            }
        }
        var pra = component.get("v.lstPractical");
        for(var i=0;i<pra.length;i++){ 
            if(pra[i].credits){
            	tc = tc + parseInt(pra[i].credits);     
            }
        }
        var mna = component.get("v.lstMandatory");
        for(var i=0;i<mna.length;i++){ 
            if(mna[i].credits){
            	tc = tc + mna[i].credits;     
            }
        }
        var oe = component.get("v.lstoElective");
        for(var i=0;i < oe.length;i++){ 
			if(oe[i].credits){
				tc = tc + parseInt(oe[i].credits);
		   }
        }
        var pe= component.get("v.lstpElective");
        for(var i=0;i < pe.length;i++){ 
			if(pe[i].credits){
				tc = tc + parseInt(pe[i].credits);
		   }
        }
        component.set("v.totalCredit", tc);
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