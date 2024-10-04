/*trigger RevaHostelRoomRequestTrigger on Reva_Hostel_Request__c (before update, after insert, after update) {
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        //RevaRoomRequestTriggerHandler.TeachingStaffRoomAllocation(Trigger.new);
      
        RevaRoomRequestTriggerHandler.FirstYearStudentRoomAllocation(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            RevaRoomRequestTriggerHandler.sendEmailWhenRequestIsCreated(Trigger.new);
            RevaRoomRequestTriggerHandler.SendRoomAllotmentNotification(Trigger.new);
        }
        if (Trigger.isUpdate) {
            RevaRoomRequestTriggerHandler.sendEmailWhenRoomAllocated(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.HostelRoomRequestUpdate(Trigger.new);
            RevaRoomRequestTriggerHandler.SendRoomAllotmentNotificationOnChange(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.updateJoiningDateInStudentFee(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.createStudentHostelAttachment(Trigger.new);
         if (TriggerControl.isFirstRun) {
        TriggerControl.isFirstRun = false;
        UpdateWardenUser.GetCustomWardenUser(Trigger.new);
    }
        }
    }
    
}*/
/**************************************************************************/
trigger RevaHostelRoomRequestTrigger on Reva_Hostel_Request__c (before update, after insert, after update) {

    HostelDisableTriggers__c disableTriggerSetting = HostelDisableTriggers__c.getInstance('RevaHostelRoomRequestTrigger'); 
    if (disableTriggerSetting != null && disableTriggerSetting.IsRevaHostelRoomRequestTrigger__c) {
        // Trigger logic is disabled, so exit the trigger
        return;
    }
    

    // Continue with the usual trigger logic if the trigger is not disabled
    if(Trigger.isBefore && Trigger.isUpdate) {
        //RevaRoomRequestTriggerHandler.TeachingStaffRoomAllocation(Trigger.new);
        RevaRoomRequestTriggerHandler.FirstYearStudentRoomAllocation(Trigger.newMap, Trigger.oldMap);
    }
    
    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            RevaRoomRequestTriggerHandler.sendEmailWhenRequestIsCreated(Trigger.new);
            RevaRoomRequestTriggerHandler.SendRoomAllotmentNotification(Trigger.new);
        }
        if (Trigger.isUpdate) {
            RevaRoomRequestTriggerHandler.sendEmailWhenRoomAllocated(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.HostelRoomRequestUpdate(Trigger.new);
            RevaRoomRequestTriggerHandler.SendRoomAllotmentNotificationOnChange(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.updateJoiningDateInStudentFee(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.createStudentHostelAttachment(Trigger.new);
            
            // Check if it's the first run for additional logic
            if (TriggerControl.isFirstRun) {
                TriggerControl.isFirstRun = false;
                UpdateWardenUser.GetCustomWardenUser(Trigger.new);
            }
        }
    }
}