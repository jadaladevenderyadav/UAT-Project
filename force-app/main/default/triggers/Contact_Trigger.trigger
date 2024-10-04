trigger Contact_Trigger on Contact (After Insert, After Update, before update) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            MSTR_ContactTrigHndlr.CreateProfessorUser(Trigger.New);
        }
        else if(Trigger.isUpdate && !System.isBatch())
        {
            
            MSTR_ContactTrigHndlr.DeactivateUser(Trigger.New, Trigger.oldMap);
                     
            if(Utility.ContactOwnerUpdate == true) MSTR_ContactTrigHndlr.StudentUserCreation(Trigger.New, Trigger.oldMap);
            //  MSTR_ContactTrigHndlr.AlumniUserCreation(Trigger.New, Trigger.oldMap);
            ASM_ContactTrgHandler.studentsToLogisys(Trigger.New, Trigger.oldMap);
            Appl_ContactTriggerHandler.applicantUserCreation(Trigger.New,Trigger.oldMap); 
            
            ReassignmentSendSMSANdWhatsapp.handleOwnerChangeContact(Trigger.new, Trigger.oldMap);
            
        }
        
        
        if(Trigger.isUpdate && Trigger.isAfter && RecursiveTriggerHandler.isFirstTime)
        {
            list<id> studentIds = new List<id>();
            for(Contact objCon:Trigger.New)
            {
                if(!objCon.Rpl_Is_Placement_Created__c != Trigger.oldMap.get(objCon.id).Rpl_Is_Placement_Created__c && objCon.Push_to_SAP__c){
                    studentIds.add(objCon.Id);                    
                }
            }
            
            if (!studentIds.isEmpty())
                SAP_Student_Master_API.StudentMasterCreationMethod(studentIds); 
        }
        
        
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        
        Appl_ContactTriggerHandler.updateContactSource(Trigger.oldMap, Trigger.new);
        
    }
    
}