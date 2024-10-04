({
    doInit : function(component, event, helper) 
    {
        helper.getYearTypeHlpr(component, event, helper);       
    },
     //Select all contacts
    handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.progmEnrollmentLst");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact"); 
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
        }
    },
     
    //Process the selected contacts
    handleSelectedContacts : function(component, event, helper) {
         
        var selectedContacts = [];
        var checkvalue = component.find("checkContact");
         
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedContacts.push(checkvalue[i].get("v.text"));
                }
            }
        }
       
        console.log('selectedContacts-' + selectedContacts);
    },
    getEnrollmentDetails : function(component, event, helper) 
    {
        helper.getEnrollmentHlpr(component, event, helper);
    },
    pushToSAP : function(component, event, helper) 
    {
        component.set("v.showConfirmationModal", false);
        helper.pushToSAPHlpr(component, event, helper);
    },
    cancelQuick : function(component, event, helper) 
    {
         $A.get("e.force:closeQuickAction").fire();
    },
   showConfirmationModal: function(component, event, helper) {
        component.set("v.showConfirmationModal", true);
    },

    hideConfirmationDialog: function(component, event, helper) {
        component.set("v.showConfirmationModal", false);
    },

    
    
})