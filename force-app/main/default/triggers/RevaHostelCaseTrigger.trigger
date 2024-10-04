trigger RevaHostelCaseTrigger on Case (after insert, after update) {
    if(trigger.isafter){
        if(Trigger.isInsert){
            RevaHostelCaseTriggerHandler.updateStudentContact(Trigger.New);
            RevaHostelCaseTriggerHandler.notifyStudentOnCaseCreation(Trigger.New);
        }if(trigger.isupdate){     
            RevaHostelCaseTriggerHandler.notifyStudentOnStatusChange(Trigger.New, Trigger.OldMap);
            RevaHostelCaseTriggerHandler.handleOwnerChangeContact(Trigger.New, Trigger.OldMap);
            /*********Newly added**********/
            RevaHostelCaseTriggerHandler.shareCasesAfterOwnershipChange(Trigger.New, Trigger.OldMap);
            /*************************/
        }
    }
}