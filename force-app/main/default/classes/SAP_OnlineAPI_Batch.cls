global class SAP_OnlineAPI_Batch implements Schedulable,Database.Batchable<sObject>, Database.AllowsCallouts {
     global static final Date specificDate = Date.newInstance(2023, 11, 7);
    global Database.QueryLocator start(Database.BatchableContext bc) {
          
        return Database.getQueryLocator([SELECT Id, Name,Line_Item_Payment_Status__c,Push_to_SAP__c,CreatedDate,
                                         Integrated_with_SAP__c,Mode_of_Payment__c FROM Student_Fee_Payment__c
                                        WHERE Mode_of_Payment__c    = 'Online' AND Line_Item_Payment_Status__c = 'Success'
                                         AND Integrated_with_SAP__c = false AND CreatedDate >=: specificDate]);
    }
    
    global void execute(Database.BatchableContext bc, List<Student_Fee_Payment__c> lst_Std_Fee_Payments) {
        list<Id> lst_Std_Fee_Pay_Ids = new List<Id>();
        
        for(Student_Fee_Payment__c objStdFeePayments:lst_Std_Fee_Payments){
            lst_Std_Fee_Pay_Ids.add(objStdFeePayments.Id);
        }
        if(!lst_Std_Fee_Pay_Ids.isEmpty())
        {
            SAP_OnlineAPI_BatchHandler.OnlineAPIMethod(lst_Std_Fee_Pay_Ids);
        }
    }
    
    global void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new SAP_OnlineAPI_Batch(),30);
    }
    
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
    }
}