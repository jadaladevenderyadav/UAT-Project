public class RemainderFeeNotification {
    
    public static List<Contact> cntList = new List<Contact>();
    public static List<Contact> cnt = new List<Contact>();
    public static List<Student_Fee__c> stuFeeList = new List<Student_Fee__c>();
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
    
       
    public static void sendWhatsAppNotifications(Map<Id, List<Contact>> contactMap, Map<Id,  List<Student_Fee__c>> studentFeeMap ,Map<Id, Decimal> semesterPendingAmountMap){
        
        for (Id contactId : contactMap.keySet()) {
            cnt = contactMap.get(contactId);
            cntList.addAll(cnt);
        }
        for(Id stuFee : studentFeeMap.keySet()){
            stuFeeList = studentFeeMap.get(stuFee);
            //stuFeeList.addAll(stuFee);
        }
        
        // semesterPendingAmountMap for pending amount  KEY = CONTACT ID
        // contactMap for student's name, mobile number KEY = CONTACT ID
        // studentFeeMap for fees due date KEY = Active Semeter
        for(Contact c : cntList){
            for(Student_Fee__c s : stuFeeList){
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = 'fee_reminder_2024_n1_copy';
                notification.params = new Map<String, String>();
                notification.params.put('StudentName', c.Name);
                notification.params.put('Calculated_Amount_Pending', 
                                        String.valueOf(semesterPendingAmountMap.get(c.Id)));
                notification.params.put('Fee_Due_Date', String.valueOf(s.Due_Date__c));
                
                if(c.MobilePhone!=null){
                    String plusRemoved = c.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                    
                } 

                /* Debug_Log__c dLog = new Debug_Log__c();
				dLog.Class_Name__c = 'StudentFeeNotificationBatch';
				dLog.Response__c = responseBody;
				dLog.Status_Code__c = response.getStatusCode();
				debugLogs.add(dLog);*/
            }
            
        }
        System.debug('phoneNumbersToNotifications SIZE' + phoneNumbersToNotifications.size());
        HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
        System.debug('Response=> ' + response);
        
        String responseBody = response.getBody();
        System.debug('responseBody-->> ' + responseBody);
    }
}