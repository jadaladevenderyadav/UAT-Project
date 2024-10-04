Global class WhatsAppFollowUp_Scheduler3 implements Schedulable{
    
    Global void execute(SchedulableContext sc){    
        
        WhatsAppFollowUpBatch3 leadAssign3 = new WhatsAppFollowUpBatch3();
        Database.executeBatch(leadAssign3,100);       
        
    }

}