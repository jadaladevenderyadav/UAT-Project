public class HallTicket_Published_what_InElgble {
  
      @InvocableMethod
    public static void trsWhatsappNotification(List<List<String>> recordIds){
        if(recordIds[0]!=null){
      //  makeCalloutAsync(recordIds);
           HallTicket_Published_what_InElgble_Batch batch = new HallTicket_Published_what_InElgble_Batch(recordIds[0]);
           Database.executeBatch(batch,1);
            
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}