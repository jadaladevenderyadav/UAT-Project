Global class WhatsAppFollowUp_Scheduler1 implements Schedulable{
    
    Global void execute(SchedulableContext sc){    
        
        WhatsAppFollowUpBatch1 leadAssign1 = new WhatsAppFollowUpBatch1();
        Database.executeBatch(leadAssign1,100);       
        
    }

}