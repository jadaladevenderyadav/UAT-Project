global class RTREarlypickupBatchNotification implements Database.Batchable<sobject>, Database.AllowsCallouts {

    // RecordIds property to store the input parameter
    public String RecordIds { get; set; }

    // Constructor to initialize RecordIds
    global RTREarlypickupBatchNotification(String contactIds) {
        this.RecordIds = contactIds;
    }

    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, RTR_Number_of_Minutes__c, RTR_Date__c, RTR_Descriptions__c 
            FROM RTR_Reva_Transport_Request__c 
            WHERE Id = :RecordIds 
        ]);
    }

    // Execute method to process the records
    global void execute(Database.BatchableContext bc, List<RTR_Reva_Transport_Request__c> requestList) {
        try {
            // Lists to store data for notifications
            List<String> dateValues = new List<String>();
            List<String> numberOfMinutes = new List<String>();
            List<String> descriptions = new List<String>();

            // Iterate through the records and gather data
            for (RTR_Reva_Transport_Request__c request : requestList) {
                numberOfMinutes.add(String.valueOf(request.RTR_Number_of_Minutes__c));
                descriptions.add(request.RTR_Descriptions__c);
                dateValues.add(String.valueOf(request.RTR_Date__c));
            }

            // Query to fetch related contacts
            List<Contact> contactList = [SELECT Id, Name, MobilePhone FROM Contact WHERE Id IN (SELECT Contact__c FROM Transport_Registeration__c WHERE Registration_Status__c = 'Active' AND Reva_Transport__r.Active__c = true) AND MobilePhone != NULL  ];

            // Fetching template details
            String templateId = 'early_pickup_single_day_student_staff';
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];

            List<Debug_Log__c> debugLogs = new List<Debug_Log__c>();
            system.debug('contactList'+contactList);
            // Iterate through contacts to create notifications
            for (Contact con : contactList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();

                // Set dynamic values for each key based on related record
                notification.params.put('name', con.Name);
                notification.params.put('numberofminutes', String.join(numberOfMinutes, ','));
                notification.params.put('Date', String.join(dateValues, ','));
                notification.params.put('Reason', String.join(descriptions, ','));
				Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                // Add notification to map
                phoneNumbersToNotifications.put(con.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);
                
                String responseBody = response.getBody();
                System.debug('responseBody-->> '+responseBody);
                
                Debug_Log__c dLog = new Debug_Log__c();
        		dLog.Class_Name__c = 'RTREarlypickupBatchNotification';
                //dLog.Request__c = request.getBody();
            	dLog.Response__c = responseBody;
            	dLog.Status_Code__c = response.getStatusCode();
                
                debugLogs.add(dLog);
            	
                
            }
            insert debugLogs;
            System.debug('debuglogId-->> '+debugLogs);
          
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }

    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}