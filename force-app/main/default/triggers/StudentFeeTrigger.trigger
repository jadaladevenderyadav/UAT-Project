trigger StudentFeeTrigger on Student_Fee__c (before insert,before update, After update,After Insert) 
{
      System.debug('LINE#32 StudentFeeTrigger');
    if(trigger.IsBefore)
    {
        if(trigger.IsInsert)
        {
            FEE_StudentFeeTriggerHandler.updateFeePaymentCriteria(trigger.new,null);
            FEE_StudentFeeTriggerHandler.updateStudentFeeProgramEnrollment(trigger.new,null);
            FEE_StudentFeeTriggerHandler.displayOrderNoMapping(trigger.new);
            //FEE_StudentFeeTriggerHandler.updateFeeRecords(Trigger.new);
        }
        if(trigger.IsUpdate)
        {
            FEE_StudentFeeTriggerHandler.updateFeePaymentCriteria(trigger.new,trigger.oldmap);
            FEE_StudentFeeTriggerHandler.updateStudentFeeProgramEnrollment(trigger.new,trigger.oldmap);
           // FEE_StudentFeeTriggerHandler.updateFeeRecords(Trigger.new);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isUpdate)
        {
            /*List<Id> contIdList = new List<Id>();
            for(Student_Fee__c sf: trigger.new){
                contIdList.add(sf.Contact__c);
            }
            ChangeBalanceFee.InsertStudentFeePay(contIdList);*/ 
            System.debug('Calling after update');
            for(Student_Fee__c sf: trigger.new){
                if(sf.Fee_Type__c =='Hostel Fee'){
                    FEE_StudentFeeTriggerHandler.updateHostelRequest(Trigger.new);
                }
            }
            // FEE_StudentFeeTriggerHandler.EligibilityForScholarship(trigger.new);
          //  FEE_StudentPaymentEmail_TriggerHandler.StudentPaymentEmail(trigger.new, trigger.oldMap);
          Set<Id> stufeeIdSet = new Set<Id>();
          for(Student_Fee__c objStdFee:Trigger.new){
            if(objStdFee.Calculated_Amount_Pending__c != (Trigger.oldMap.get(objStdFee.Id)).Calculated_Amount_Pending__c ||
                objStdFee.Calculated_Total_Amount__c != (Trigger.oldMap.get(objStdFee.Id)).Calculated_Total_Amount__c){
                    stufeeIdSet.add(objStdFee.Id);
            }
          }
          if(stufeeIdSet.size() > 0){
              System.debug('LINE#32 StudentFeeTrigger');
            FEE_StudentFeeTriggerHandler.updateStudentFeePending(stufeeIdSet);
          }
          List<Id> demandIds = new List<Id>();
            for(Student_Fee__c objStdFee:Trigger.new)
            {
                if(objStdFee.Pushed_to_SAP__c == true && trigger.OldMap.get(objStdFee.Id).Pushed_to_SAP__c != objStdFee.Pushed_to_SAP__c)
                {
                    demandIds.add(objStdFee.Id);
                }
            }
            if(!demandIds.isEmpty())
            {
                SAP_DemandAPI_Handler.createDemands(demandIds);
            } 
        }
      if(trigger.isInsert)
        {
            List<Id> demandIds = new List<Id>();
            Set<Id> stufeeIdSet = new Set<Id>();
            for(Student_Fee__c objStdFee:Trigger.new)
            {
               /* if(objStdFee.Fee_Type__c !='University Fee' && objStdFee.Fee_Type__c !='Tuition Fee'){
                    demandIds.add(objStdFee.Id);
                } */
                if(objStdFee.Amount_Pending__c != objStdFee.Calculated_Amount_Pending__c){
                    stufeeIdSet.add(objStdFee.Id);
                }
            }
           /* if(!demandIds.isEmpty())
            {
                SAP_DemandAPI_Handler.createDemands(demandIds);
            } */ 
            if(stufeeIdSet.size() > 0){
                System.debug('Hello');
                FEE_StudentFeeTriggerHandler.updateStudentFeePending(stufeeIdSet);
              }
        }
    }
    
}