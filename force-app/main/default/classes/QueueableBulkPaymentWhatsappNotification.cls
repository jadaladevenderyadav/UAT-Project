public class QueueableBulkPaymentWhatsappNotification  implements System.Queueable , Database.AllowsCallouts {
    Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> localPhoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

    public QueueableBulkPaymentWhatsappNotification (Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications){
        localPhoneNumbersToNotifications = phoneNumbersToNotifications;
    } 
    
    public void execute(QueueableContext context){
        Yellow_AI_Utility.sendWhatsAppNotifications(localPhoneNumbersToNotifications);
    }
}