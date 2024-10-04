public class PendingFeesNotification {
    
    @InvocableMethod(label='Remaining Fees WhatsApp Notifications' 
                     description='Send Reminder for Remainig Fees')
    public static void sendFeeReminder(List<String> contacts){
        System.debug('contacts from flow: ' + contacts);
        System.debug('No. of contacts from flow: ' + contacts.size());
        //for(String cid : contacts){
            Database.executeBatch(new StudentFeeNotificationBatch(contacts));
        //}
        
    }
    
}