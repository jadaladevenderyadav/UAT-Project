public class StudentPaymentNotificationHandler {
     Private Static final String SMS_TYPE = 'Application_Number';
    Private Static final String SMS_TYPE1 = 'Reset_Password_for_Application_Portal';
    
    public static void sendPaymentNotification(List<Student_Payment__c> newPayments ) {   //Map<Id, Student_Payment__c> oldPayments
        String Paymentlink = 'https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/payment-page?contactId= ';

        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'resetlinknew2';
        // Fetch keys from custom metadata based on templateId
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        set<Id> setConId = new set<Id>();
        map<String,string>mapPaymentlink=new map<String,string>();
        for(Student_Payment__c objStudentPayment: newPayments ) {
            if(objStudentPayment.Contact__c !=null && objStudentPayment.Payment_Mode_Type__c =='Online' && objStudentPayment.Amount__c !=null) {
                Paymentlink=Paymentlink+objStudentPayment.Contact__c;
                setConId.add(objStudentPayment.Contact__c);
               // mapPaymentlink.put(objStudentPayment.Contact__c,Paymentlink);
                System.debug ('Paymentlink==>'+Paymentlink);		
        	}     
    	}
        List<Contact> conRecs = [select id, Name, Email, Application_Fee_Paid__C, Record_Type_Name__c, MobilePhone, Country_Code__c, Application_Number__C 
                                 from Contact where Id in : setConId];

        for( contact stu : conRecs ){
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                String plusRemoved = stu.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                string mobile = stu.MobilePhone;
                mobile = mobile.remove('+91-');
                List<String> requiredVariables =  new List<String>();
                List<String> requiredVariables1 =  new List<String>();
                if(stu.Country_Code__c == 'India (+91)'){
                    requiredVariables.add(stu.Application_Number__c);
                    //requiredVariables1.add(stu.Name);
                    requiredVariables1.add(stu.Application_Number__c);
                    requiredVariables1.add(Paymentlink);
                    //requiredVariables1.add(Paymentlink);
                    if(!system.isbatch()){
                        // RegistrationFormUtility.futureSMS(SMS_TYPE, mobile, requiredVariables);
                        RegistrationFormUtility.futureSMS(SMS_TYPE1, mobile, requiredVariables1);
                    }
                }
        }
        //System.enqueueJob(new 'QueueableBulkWhatsappNotification'(phoneNumbersToNotifications));
    }
    
}