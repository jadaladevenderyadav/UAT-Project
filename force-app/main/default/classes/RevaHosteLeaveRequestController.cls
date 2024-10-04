public without sharing class RevaHosteLeaveRequestController {
   @AuraEnabled(cacheable = true)
   public static List<ProcessInstanceStep> getApprovalHistory(string targetObjectId){
    List<ProcessInstance> processInstances = [SELECT Status, TargetObjectId, Id, CompletedDate 
                                FROM ProcessInstance
                                WHERE TargetObjectId =: targetObjectId];

    return [SELECT Id, ProcessInstanceId, StepStatus, Comments, StepNodeId, CreatedDate, Actor.Name 
            FROM ProcessInstanceStep
            WHERE ProcessInstanceId IN: processInstances AND StepStatus != 'Started'
            ORDER BY CreatedDate ASC];

   }
}