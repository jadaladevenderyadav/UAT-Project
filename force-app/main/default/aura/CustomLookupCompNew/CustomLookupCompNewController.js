({
    doInit : function(component,event,helper){
        var selectedId = component.get("v.selectedId");
        var action = component.get("c.getObjectDetails");
        action.setParams({'ObjectName' : component.get("v.objectAPIName")});
        action.setCallback(this, function(response) {
            var details = response.getReturnValue();
            component.set("v.IconName", details.iconName);
            component.set("v.objectLabel", details.label);
            component.set("v.objectLabelPlural", details.pluralLabel);
            if (selectedId == null || selectedId.trim().length <= 0) {
            	component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
        
        var returnFields =  component.get("v.returnFields"),
            queryFields =  component.get("v.queryFields");
        
        if (returnFields == null || returnFields.length <= 0) {
            component.set("v.returnFields", ['Name','Offered_By_School__c']);
        }
        
        if (queryFields == null || queryFields.length <= 0) {
            component.set("v.queryFields", ['Name','Offered_By_School__c']);
        }
        
        //help for cancelling the create new record
        //find the latest accessed record for the user
        if (component.get("v.showAddNew")) {
            var action = component.get("c.GetRecentRecords");
            action.setParams({
                'ObjectName' : component.get("v.objectAPIName"),
                'ReturnFields' :  null,
                'MaxResults' : 1,
                'Filter':component.get("v.filter"),
                'filterIds':component.get("v.filterIds")
            });
            action.setCallback(this, function(response) {
                var results = response.getReturnValue();
                if (results != null && results.length > 0) {
					component.lastRecordId = results[0].Id;
                }
            });
            $A.enqueueAction(action);
        }
        if (selectedId != null && selectedId.trim().length > 0) {
            var action = component.get("c.GetRecord"),
                returnFields = component.get("v.returnFields");
            action.setParams({'ObjectName' : component.get("v.objectAPIName"),
                              'ReturnFields': returnFields,
                              'Id': component.get("v.selectedId")});
            action.setCallback(this, function(response) {
                var results = response.getReturnValue();
            //    alert('==='+JSON.stringify(results));
                results = helper.processResults(results, returnFields);
                
                component.set("v.selectedName", results[0].Field0);
                component.set("v.selectedCredit", results[0].Field2);
                component.set("v.selectedAccount", results[0].Field3);
                //component.set("v.selectedAccName",results[0].Field4);                
              //  alert('**selectedAccount***'+results[0].Field3);
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }
    },
    
    onFocus : function(component,event,helper){
        var inputBox = component.find("lookup-input-box"),
            searchText = component.get("v.searchText") || '';
        
        $A.util.addClass(inputBox, 'slds-is-open');
        $A.util.removeClass(inputBox, 'slds-is-close');
        
        if (component.get("v.showRecent") && searchText.trim() == '') {
            component.set("v.isSearching", true);        
            var action = component.get("c.GetRecentRecords"),
                returnFields = component.get("v.returnFields");
            
            action.setParams({
                'ObjectName' : component.get("v.objectAPIName"),
                'ReturnFields' :  returnFields,
                'MaxResults' : component.get("v.maxResults"),
                'Filter':component.get("v.filter"),
                'filterIds':component.get("v.filterIds")
            });
            action.setCallback(this, function(response) {
                var results = response.getReturnValue();
                if (results != null) {
                    component.set("v.statusMessage", results.length > 0 ? null : 'No recent records.' );
                    component.set("v.searchResult", 
                                  helper.processResults(results, returnFields));
                } else {
                    component.set("v.statusMessage", "Search Error!" );
                }
                component.set("v.isSearching", false);
            });
            $A.enqueueAction(action);
        }
        
    },
    
    onBlur : function(component,event,helper){      
        var inputBox = component.find("lookup-input-box");
        $A.util.addClass(inputBox, 'slds-is-close');
        $A.util.removeClass(inputBox, 'slds-is-open');        
        $A.util.removeClass(component.find("lookup-input-box"),'slds-has-focus');
	//	alert('test2');        
    },
    
    onKeyUp : function(component, event, helper) {
     //  alert('test1'); 
        var searchText = component.get('v.searchText');
        //do not repeat the search if nothing changed
        if (component.lastSearchText !== searchText) {
            component.lastSearchText = searchText;
        } else {
            return;
        }
        
        if (searchText == null || searchText.trim().length < 3) {
            component.set("v.searchResult", []);
            component.set("v.statusMessage", null);
            return;
        }
        
        component.set("v.isSearching", true);        
        var action = component.get("c.SearchRecords"),
            returnFields = component.get("v.returnFields");
        
        action.setParams({
            'ObjectName' : component.get("v.objectAPIName"),
            'ReturnFields' :  returnFields,
            'QueryFields' :  component.get("v.queryFields"),
            'SearchText': searchText,
            'SortColumn' : component.get("v.sortColumn"),
            'SortOrder' : component.get("v.sortOrder"),
            'MaxResults' : component.get("v.maxResults"),
            'Filter' : component.get("v.filter"),
            'filterIds' : component.get("v.filterIds")
        });
        
        action.setCallback(this, function(response) {
            var results = response.getReturnValue();
            if (results != null) {
                component.set("v.statusMessage", results.length > 0 ? null : 'No records found.' );
                component.set("v.searchResult", 
                              helper.processResults(results, returnFields, searchText));
            } else {
                component.set("v.statusMessage", 'Search Error!' );
            }
            component.set("v.isSearching", false);
        });
        $A.enqueueAction(action);
        
    },
    
    onSelectItem : function(component, event, helper) {
        var selectedId = event.currentTarget.dataset.id;
        component.set("v.selectedId", selectedId);
        var results = component.get("v.searchResult");
     //   alert('test');
       console.log('---------',selectedId); 
       console.log('---------',JSON.stringify(results));
        for (var i = 0; i < results.length; i++) {
            if (results[i].Id == selectedId) {
                component.set("v.selectedName", results[i].Field0.replace("<mark>","").replace("</mark>",""));
                component.set("v.selectedCredit", results[i].Field2.replace("<mark>","").replace("</mark>",""));
                component.set("v.selectedAccount", results[i].Field3.replace("<mark>","").replace("</mark>",""));
                //component.set("v.selectedAccName",results[i].Field4.replace("<mark>","").replace("</mark>",""));
                component.set("v.i_valueChanged", !component.get("v.i_valueChanged") );
                 
                break;
            }
        }
        component.set("v.isSearching", false);
      //  alert('test1');
        $A.enqueueAction(component.get("c.onBlur"));
    },
    
    removeSelectedOption : function(component, event, helper) {
        component.set("v.selectedId", null);
        component.set("v.selectedName",null);
        component.set("v.selectedCredit",0);
        component.set("v.selectedAccount",null);
        //component.set("v.selectedAccName",null);
        component.set("v.i_valueChanged", !component.get("v.i_valueChanged") );
    },
    
    createNewRecord : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord"),
            objectName = component.get("v.objectAPIName"),
            returnFields = component.get("v.returnFields");
        createRecordEvent.setParams({
            "entityApiName": objectName,
            "navigationLocation" : "LOOKUP",
            "panelOnDestroyCallback": function(event) {
                let action = component.get("c.GetRecentRecords");
                action.setParams({'ObjectName' : objectName,
                                  'MaxResults' : 1,
                                  'ReturnFields': returnFields,
                				  'Filter':component.get("v.filter"),
                				  'filterIds':component.get("v.filterIds")});
                action.setCallback(this, function(response) {
                    var records = response.getReturnValue();
                    if (records != null && records.length > 0) {
                        if (records[0].Id != component.lastRecordId) {
                            component.set("v.selectedId", records[0].Id);
                            component.set("v.selectedName", records[0][returnFields[0]]);
                          //  alert('++++++++',records[0][returnFields[2]]);
                            component.lastRecordId = records[0].Id;
                        }
                    }
                });
                $A.enqueueAction(action);              
            }
        });
        createRecordEvent.fire();
    }

})