trigger MM_TermTrigger on hed__Term__c (After Update) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
            MM_TermTriggerHandler.mentorMapping(trigger.New,trigger.oldMap);
            ASM_TermTrigger_Handlr.PushIAMarksToLogisys(Trigger.New, Trigger.oldMap);
        }
    }
}