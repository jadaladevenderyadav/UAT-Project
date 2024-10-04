Global class WhatsAppFollowUp_Scheduler2 implements Schedulable{
    
    Global void execute(SchedulableContext sc){    
        
        WhatsAppFollowUpBatch2 leadAssign2 = new WhatsAppFollowUpBatch2();
        Database.executeBatch(leadAssign2,100);       
        
    }

}