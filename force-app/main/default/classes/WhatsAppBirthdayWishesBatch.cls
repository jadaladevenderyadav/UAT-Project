global class WhatsAppBirthdayWishesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Correct query to select contacts with today's birthday
        system.debug('Start');
        return Database.getQueryLocator([
            SELECT Id, Name, MobilePhone, Birthdate 
            FROM Contact 
            WHERE Birthdate != NULL
            AND ID =:'0035j00000PuFxdAAF'
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> listCon) {
        system.debug('Execute method==='+listCon);
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        // Fetching template details
        String templateId = 'completeyourapplicationform_11';
        
         WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];
            
			system.debug('tempalte==='+metadata);        
        for (Contact con : listCon) {
            if (con.MobilePhone != null) {
                system.debug('Birthday==='+con.Birthdate);
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
                notification.params.put('ContactName', con.Name);
                
                String plusRemoved = con.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                phoneNumbersToNotifications.put(correctedWhatsappNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
            }
        }
        
        if (!phoneNumbersToNotifications.isEmpty()) {
            system.debug('phonenumbernotempty==='+phoneNumbersToNotifications);
            try {
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response status: ' + response.getStatusCode());
                System.debug('Response body: ' + response.getBody());
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Finish Method');
    }
}